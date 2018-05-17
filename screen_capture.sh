#!/usr/bin/env bash

FRAMERATE="24/1"
OUTPUT_DIR=$HOME"/Pictures"
OUTPUT_FILENAME_PREFFIX="screen_capture"
EXTENSION=$1

if [[ -z $EXTENSION ]]
then
	echo "Usage: screen_capture.sh mp4|gif on_output_file"
	exit
fi

# check if already capturing
GPID=$(ps -e -o pgrp,comm | awk '/draw_line/ {print $1;}' | head -n1) 

if [[ $GPID = *[!\ ]* ]]; then
    echo "Process already running."
    
    # softly kill the gstreamer process
    kill -INT -$GPID

    # kill processes responsible for drawing borders
    for pid in $(ps -ef | grep 'line' | awk '/draw_lin/ {print $2}'); do 
	kill $pid; 
    done
    
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


# Find the first available path within the output directory.
file_index=0

while true
do
	FREE_OUTPUT_PATH=${OUTPUT_DIR}/${OUTPUT_FILENAME_PREFFIX}_${file_index}.$EXTENSION
    if [ ! -f $FREE_OUTPUT_PATH ]; then
	break
    fi
    file_index=$(($file_index+1))
done

echo "Started recording to:"
echo $FREE_OUTPUT_PATH

# start recording
gst-launch-1.0 -e ximagesrc use-damage=0 startx=$x_start starty=$y_start endx=$x_end endy=$y_end \
    ! videorate \
    ! videoconvert  \
    ! "video/x-raw,framerate="$FRAMERATE \
    ! x264enc \
    ! qtmux \
    ! filesink location=$FREE_OUTPUT_PATH > /dev/null 2>&1 &!


/usr/local/screen_capture/draw_line $x_start $y_start $width 1&
/usr/local/screen_capture/draw_line $x_start $y_end $width 1&
/usr/local/screen_capture/draw_line $x_start $y_start 1 $height&
/usr/local/screen_capture/draw_line $x_end $y_start 1 $height& 
