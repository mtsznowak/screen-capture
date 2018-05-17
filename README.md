# Screen-Capture

Simple script for screen capturing based on GStreamer.  
Designed to work on Arch Linux with [i3 window manager](https://i3wm.org/).  
It should work also on other X environments, but it was not tested.  

Supported output formats:
- ``mp4`` (records audio as well!)
- ``gif`` via [gifski](https://gif.ski/)

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

After installation, run `screen_capture.sh` and select some rectangle area with your mouse.
To finish capturing and save the result, just run `screen_capture.sh` again - the script will detect that its instance is running already.

By default, the output videos are saved in ``$HOME/Pictures``.
