#!/bin/sh
#pwcview -hkr -s vga -f 30 
pwcview -hkr -s qsif -f 5 -q 50 | mencoder -really-quiet -demuxer rawvideo -rawvideo fps=5:w=160:h=120:i420 - -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=15 -o $1

