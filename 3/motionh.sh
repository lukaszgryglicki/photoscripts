#!/bin/sh
#pwcview -hkr -s vga -f 30 
pwcview -hkr -s vga -f 30 -q 90 | mencoder -really-quiet -demuxer rawvideo -rawvideo fps=30:w=640:h=480:i420 - -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=3000 -o $1

