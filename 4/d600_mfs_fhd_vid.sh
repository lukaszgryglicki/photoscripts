#!/bin/sh
#out="`echo "out_$1" | cut -d'.' -f1`.avi"
out="`echo "out_$1" | cut -d'.' -f1`.mp4"
#ffmpeg -i "$1" -vcodec mpeg4 -mbd 2 -vqmin 3 -vqmax 10 -acodec mp3 -b:a 128k -b:v 6000k -f avi "$out"
#ffmpeg -i "$1" -vcodec h264 -mbd 2 -qmin 4 -qmax 29 -pix_fmt yuvj420p -acodec aac -b:a 128k -ac 1 -f mp4 "$out"
#ffmpeg -i "$1" -vcodec h264 -preset veryslow -crf 17 -acodec aac -b:a 128k -ac 1 -ar 22050 -f mp4 "$out"
ffmpeg -i "$1" -vcodec h264 -mbd 2 -preset slower -crf 19 -acodec aac -ac 1 -ar 22050 -f mp4 "$out"
