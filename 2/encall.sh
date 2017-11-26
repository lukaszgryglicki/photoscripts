#!/bin/sh
mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=9:vbr=2 -lavcopts vcodec=mpeg4:vhq

