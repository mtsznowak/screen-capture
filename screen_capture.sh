#!/usr/bin/env bash

# Check if we are already capturing.
GPID=$(ps -e -o pgrp,comm | awk '/draw_border/ {print $1;}' | head -n1) 

if [[ $GPID = *[!\ ]* ]]; then
    echo "Process already running."
    
	# Interrupt gst-launch so that the first process is unblocked and completes.
	pkill -f --signal SIGINT gst-launch
    exit
fi

FRAMERATE="24/1"
OUTPUT_DIR="$HOME/Pictures"
OUTPUT_FILENAME_PREFFIX="screen_capture"
EXTENSION=$1

AUDIO_DEVICE=`pacmd list-sources | grep name | grep output | cut -d "<" -f2 | cut -d ">" -f1`


if [[ $EXTENSION != "mp4" ]] && [[ $EXTENSION != "gif" ]]
then
    echo "Invalid extension"
    echo "Usage: screen_capture.sh mp4|gif [on_output_file]"
    exit 1
fi

if [[ -z $AUDIO_DEVICE ]]
then
   echo "Could not find output audio device or PulseAudio is not available"
   exit 1
fi

sleep 0.25

coordinates=$(/usr/local/screen_capture/get_coordinates)

# capture coordinates
width=$(echo $coordinates | cut -f1 -dx)
height=$(echo $coordinates | cut -f2 -dx)
x_start=$(echo $coordinates | cut -f3 -dx)
y_start=$(echo $coordinates | cut -f4 -dx)

x_end=$((x_start + width))
y_end=$((y_start + height))


# Find the first available filename within the output directory.

pushd "$OUTPUT_DIR"
file_index=0

while true
do
    FREE_FILENAME=${OUTPUT_FILENAME_PREFFIX}_${file_index}.$EXTENSION
    if [ ! -f $FREE_FILENAME ]; then
	break
    fi
    file_index=$(($file_index+1))
done

OUTPUT_PATH="${OUTPUT_DIR}/${FREE_FILENAME}"

echo "Started recording to:"
echo "$OUTPUT_PATH"

popd

/usr/local/screen_capture/draw_border $x_start $y_start $width $height &


if [ "$EXTENSION" == "mp4" ]
then
    # start recording
    gst-launch-1.0 -e ximagesrc use-damage=false startx=$x_start starty=$y_start endx=$x_end endy=$y_end \
	! videorate \
	! videoconvert  \
	! "video/x-raw,framerate="$FRAMERATE \
	! x264enc \
	! queue2 max-size-bytes=0 max-size-buffers=0 max-size-time=0 \
	! muxer.video_0 \
	pulsesrc device=$AUDIO_DEVICE \
	! queue max-size-bytes=0 max-size-buffers=0 max-size-time=0 \
	! lamemp3enc \
	! muxer.audio_0 \
	mp4mux name=muxer \
	! filesink location="$OUTPUT_PATH"
elif [ "$EXTENSION" == "gif" ]
then
    TMP_PATH="`mktemp -d`/"
    PNG_LOCATION=$TMP_PATH"part%.6d.png"
    PNG_FILES_REGEX=$TMP_PATH"part*.png"
    echo $TMP_PATH
    # start recording
    gst-launch-1.0 -e ximagesrc use-damage=false startx=$x_start starty=$y_start endx=$x_end endy=$y_end \
	! videorate \
	! videoconvert  \
	! "video/x-raw,framerate="$FRAMERATE \
	! pngenc \
	! multifilesink location=$PNG_LOCATION

    gifski -o "$OUTPUT_PATH" $PNG_FILES_REGEX  
    rm -r $TMP_PATH
fi


# Interrupt the GStreamer process.
pkill -f --signal 2 gst-launch

# Kill all processes responsible for drawing borders.
pkill -f --signal=SIGKILL draw_border

# This glitches out sometimes, so kill it as well.
pkill -f --signal=SIGKILL get_coordinates

echo "Finished interruption."

ON_OUTPUT_CALLBACK=$2

if [[ ! -z $ON_OUTPUT_CALLBACK ]]
then
	CALLBACK_COMMAND="$ON_OUTPUT_CALLBACK\"$OUTPUT_PATH\""
	echo "Callback was passed. Running:"

	echo $CALLBACK_COMMAND
	eval $CALLBACK_COMMAND

	exit
fi
