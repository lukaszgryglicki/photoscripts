#!/bin/sh
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=1500 -ofps 30.0
mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=9:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=300 -fps 11.0 -ofps 30.0
#mencoder "$1" -o "$1.avi" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vhq
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc copy -lameopts q=9:vbr=2
#mencoder "$1" -o "$1.avi" -oac copy -ovc copy

