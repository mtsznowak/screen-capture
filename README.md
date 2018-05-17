# Screen-Capture

Screen recording script based on GStreamer.  

Supported output formats:
- ``mp4`` (records audio as well!)
- ``gif`` via [gifski](https://gif.ski/)

Tested on:
- Arch Linux with [i3 window manager](https://i3wm.org/). 

## Installation

### Get the dependencies

Run:
```
yaourt -S gstreamer gst-plugins-ugly gst-plugins-good gst-plugins-base gifski
``` 

### Build

Compile and install with:
```
make
sudo make install
```

### Configure i3

The script uses floating windows to display borders indicating the currently captured area.
For this to work, you must add the following lines to your ``i3/config``:

```
floating_minimum_size 1 x 1
for_window[title="capture-border"] floating enabled
```

## Usage

```
screen_capture.sh mp4|gif on_output_file
```

The first argument specifies the output extension.
The second argument specifies a script to be run on the output file when the recording has completed successfully.
Usually, you'll want to do something with the file right away, e.g. copy it to clipboard, copy just its path to clipboard, upload to imgur, etc.

The script will grab the mouse pointer so that you can select the screen region you wish to record.
To finish capturing and save the result, just run `screen_capture.sh` again with the same arguments or with none at all.  
The arguments passed to ``screen_capture.sh`` matter only for the invocation which **starts** the recording.
On the second run, the script will detect that another instance is running already and signal it to complete.

The output videos are saved in ``$HOME/Pictures``.

### Example configurations

Save to mp4 and play the result right away, in [mpv](https://github.com/mpv-player/mpv):

```
bindsym $mod+shift+r exec screen_capture.sh mp4 "mpv "
```

Save to mp4 and right away highlight the result in [ranger](https://github.com/ranger/ranger):

```
bindsym Shift+Print exec screen_capture.sh mp4 "alacritty -e ranger --selectfile="
```
