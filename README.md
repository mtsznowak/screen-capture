# Screen-Capture
Simple script for screen capturing based on GStreamer.
Designed to work on ArchLinux with i3.
Should work also on other X environments, but it was not tested.

## Installation
### Get the dependencies
Run:
```
yaourt -S gstreamer gst-plugins-ugly gst-plugins-good gst-plugins-base 
``` 

### Build
Then compile and install with:
```
make
sudo make install
```

## Usage
Just run `./screen_capture.sh` and select some rectangle area with your mouse.
To stop capturing run `./screen_capture.sh` script again.

By default, .mp4 file is saved in $HOME/Pictures
