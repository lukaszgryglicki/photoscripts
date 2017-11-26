#!/bin/sh
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=3500 -fps 27.0 -ofps 30.0
mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=8:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=6666
ls -l "$1"
ls -l "$1.avi"
#rm -f "$1"

