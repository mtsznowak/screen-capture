#!/usr/bin/env bash

FRAMERATE="24/1"
OUTPUT_DIR=$HOME"/Pictures/"
FILENAME_PREFIX="screen_capture_"
EXTENSION=".mp4"

# Encoder preset. Allowed values:
#  "Profile Baseline"
#  "Profile High"
#  "Profile Main"
#  "Profile YouTube"
#  "Quality High"
#  "Quality Low"
#  "Quality Normal"
X264_PRESET="Profile Main"  
coordinates=$(./get_coordinates)

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
    ! x264enc preset=$X264_PRESET \
    ! qtmux \
    ! filesink location=$FILENAME > /dev/null 2>&1 &

GST_PID=$!

# wait for escape
while true
do
    read -s -n1  key

    case $key in $'\e') break;;
    esac
done


# stop recording
kill -INT $GST_PID
