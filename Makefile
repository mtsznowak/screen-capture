local_path = /usr/local/screen_capture
bin_path = /usr/bin

all:
	gcc get_coordinates.c -lX11 -o get_coordinates

install:
	test -d $(local_path) || mkdir -p $(local_path)
	cp get_coordinates $(local_path)
	cp screen_capture.sh $(bin_path)

uninstall:
	rm -r $(local_path)
	rm $(bin_path)/screen_capture.sh

clean:
	rm get_coordinates
