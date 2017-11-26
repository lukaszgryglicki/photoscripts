#!/bin/sh
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=1500 -ofps 30.0
mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=7:vbr=2 -lavcopts vcodec=mpeg4:vhq -ofps 25.0

