#!/bin/sh
out="`echo "out_$1" | cut -d'.' -f1`.avi"
#mencoder "$1" -oac lavc -ovc lavc -lavcopts acodec=ac3:abitrate=128:vcodec=mpeg4:vqmin=3:vqmax=10:vhq:vbitrate=6000 -o "out_$1"
#mencoder "$1" -oac pcm -ovc lavc -lavcopts acodec=vorbis:vcodec=mpeg4 -o "out_$1"
#ffmpeg -i "$1" -f mp4 -vcodec h264 -mbd 2 -qmin 3 -qmax 10 -acodec mp3 "$out"
ffmpeg -i "$1" -vcodec mpeg4 -mbd 2 -vqmin 3 -vqmax 10 -acodec mp3 -b:a 128k -b:v 6000k -f avi "$out"
