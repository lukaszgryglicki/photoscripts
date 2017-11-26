#!/bin/sh
#pwcview -hkr -s vga -f 30 
pwcview -hkr -s sif -f 10 -q 60 | mencoder -really-quiet -demuxer rawvideo -rawvideo fps=10:w=320:h=240:i420 - -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=80 -o $1

