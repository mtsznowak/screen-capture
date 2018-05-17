#!/usr/bin/env bash

FRAMERATE="24/1"
OUTPUT_DIR=$HOME"/Pictures"
FILENAME_PREFIX="screen_capture"
EXTENSION="mp4"


# check if already capturing
GPID=$(ps -e -o pgrp,comm | awk '/draw_line/ {print $1;}' | head -n1) 

if [[ $GPID = *[!\ ]* ]]; then
    echo "exiting"
    
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


# find first available filename
file_index=0

while true
do
	FILENAME=${OUTPUT_DIR}/${FILENAME_PREFIX}_${file_index}.$EXTENSION
    if [ ! -f $FILENAME ]; then
	break
    fi
    file_index=$(($file_index+1))
done

echo "recording to "$FILENAME

# start recording
gst-launch-1.0 -e ximagesrc use-damage=0 startx=$x_start starty=$y_start endx=$x_end endy=$y_end \
    ! videorate \
    ! videoconvert  \
    ! "video/x-raw,framerate="$FRAMERATE \
    ! x264enc \
    ! qtmux \
    ! filesink location=$FILENAME > /dev/null 2>&1 &!


/usr/local/screen_capture/draw_line $x_start $y_start $width 1&
/usr/local/screen_capture/draw_line $x_start $y_end $width 1&
/usr/local/screen_capture/draw_line $x_start $y_start 1 $height&
/usr/local/screen_capture/draw_line $x_end $y_start 1 $height& 
