#!/bin/sh
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=1500 -ofps 30.0
#mencoder "$1" -o "$1.avi" -oac mp3lame -ovc lavc -lameopts q=6:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=2700 -ofps 24.0
ffmpeg -threads 2 -i "$1" -y -c:v mpeg4 -c:a mp2 -b:v 2200k -b:a 64k -r 29 "$1.avi"

