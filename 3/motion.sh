#!/bin/sh
#pwcview -hkr -s vga -f 30 
pwcview -hkr -s vga -f 25 -q 80 | mencoder -really-quiet -demuxer rawvideo -rawvideo fps=25:w=640:h=480:i420 - -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=1200 -o $1

