#!/usr/bin/env bash

# Check if we are already capturing.
GPID=$(ps -e -o pgrp,comm | awk '/draw_line/ {print $1;}' | head -n1) 

if [[ $GPID = *[!\ ]* ]]; then
    echo "Process already running."
    
	# Interrupt draw_line so that the first process is unblocked and completes.
	pkill -f --signal 2 draw_line
    exit
fi

FRAMERATE="24/1"
OUTPUT_DIR=$HOME"/Pictures"
OUTPUT_FILENAME_PREFFIX="screen_capture"
EXTENSION=$1

if [[ -z $EXTENSION ]]
then
	echo "Usage: screen_capture.sh mp4|gif on_output_file"
	exit
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

pushd $OUTPUT_DIR
file_index=0

while true
do
	FREE_FILENAME=${OUTPUT_FILENAME_PREFFIX}_${file_index}.$EXTENSION
    if [ ! -f $FREE_FILENAME ]; then
	break
    fi
    file_index=$(($file_index+1))
done

OUTPUT_PATH=${OUTPUT_DIR}/${FREE_FILENAME}

echo "Started recording to:"
echo $OUTPUT_PATH

popd

# start recording
gst-launch-1.0 -e ximagesrc use-damage=0 startx=$x_start starty=$y_start endx=$x_end endy=$y_end \
    ! videorate \
    ! videoconvert  \
    ! "video/x-raw,framerate="$FRAMERATE \
    ! x264enc \
    ! qtmux \
    ! filesink location=$OUTPUT_PATH > /dev/null 2>&1 &!


# Block on the last one. It will be interrupted by the subsequent call to screen_capture.sh
/usr/local/screen_capture/draw_line $x_start $y_start $width $height

echo "Interrupt received. Saving the recording."

# Interrupt the GStreamer process.
pkill -f --signal 2 gst-launch

# Interrupt all processes responsible for drawing borders.
pkill -f --signal=SIGKILL draw_line

# This glitches out sometimes, so kill it as well.
pkill -f --signal=SIGKILL get_coordinates

echo "Finished interruption."

ON_OUTPUT_CALLBACK=$2

if [[ ! -z $ON_OUTPUT_CALLBACK ]]
then
	CALLBACK_COMMAND="$ON_OUTPUT_CALLBACK$OUTPUT_PATH"
	echo "Callback was passed. Running:"

	echo $CALLBACK_COMMAND
	eval $CALLBACK_COMMAND

	exit
fi
