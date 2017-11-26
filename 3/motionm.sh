#!/bin/sh
#pwcview -hkr -s vga -f 30 
pwcview -hkr -s cif -f 15 -q 70 | mencoder -really-quiet -demuxer rawvideo -rawvideo fps=15:w=352:h=288:i420 - -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=300 -o $1

