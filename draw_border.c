#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xutil.h>

#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

struct xywh {
	int x, y, width, height;
};

int main(int argc, char* argv[]) {
   if(argc != 5) {
      return -1;
   }

   int x,y, width, height;

   x = atoi(argv[1]);
   y = atoi(argv[2]);
   width = atoi(argv[3]);
   height = atoi(argv[4]);

   Display *d;
   Window w;
   XEvent e;
   int s;

   d = XOpenDisplay(NULL);
   if (d == NULL) {
      fprintf(stderr, "Cannot open display\n");
      exit(1);
   }

   s = DefaultScreen(d);
   Screen *screen = ScreenOfDisplay(d, s);

   //normalize coordinates
   x = MIN(MAX(x, 1), screen->width-3);
   y = MIN(MAX(y, 1), screen->height-3);
   width=MAX(width, 1);
   height=MAX(height, 1);
   
   if(x+width >= screen->width-1) {
      width = screen->width-x-2;
   }
   
   if(y+height >= screen->height-1) {
      height = screen->height-y-2;
   }

   struct xywh borders[4] = {
	   // Top
	   { x-1, y-1, width + 2, 1 },
	   // Bottom
	   { x-1, y + height + 1, width + 2, 1 },
	   // Left
	   { x-1, y, 1, height },
	   // Right
	   { x + width + 1, y, 1, height }
   };

   for (int i = 0; i < 4; ++i) {
	   w = XCreateSimpleWindow(d, RootWindow(d, s), borders[i].x, borders[i].y, borders[i].width, borders[i].height, 0,
			   BlackPixel(d, s), WhitePixel(d, s));

	   XStoreName(d, w, "capture-border");

	   XMapWindow(d, w);
   }

   while (1) {
      XNextEvent(d, &e);
   }

   XCloseDisplay(d);
   return 0;
}
