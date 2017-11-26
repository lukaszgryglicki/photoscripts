#!/bin/sh
mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=4000 -fps 59.94 -ofps 60.0

