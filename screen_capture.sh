#!/usr/bin/env bash

FRAMERATE="24/1"
OUTPUT_DIR=$HOME"/Pictures/"
FILENAME_PREFIX="screen_capture_"
EXTENSION=".mp4"
TMP_FILE="/tmp/screen_capture"

# check if already capturing
if [ -f $TMP_FILE ]; then
    echo "exiting"
    echo $GST_PID
    GST_PID=$(cat $TMP_FILE) 
    kill -INT $GST_PID
    rm $TMP_FILE
    exit
fi


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
    FILENAME=$OUTPUT_DIR$FILENAME_PREFIX$file_index$EXTENSION
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

GST_PID=$!
echo "pid:"
echo $GST_PID

echo -n $GST_PID > $TMP_FILE 

