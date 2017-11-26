#!/bin/sh
echo "usage invert.sh file_in fps"
ffmpeg -i "$1" %08d.png -ab 128k audio.mp2
find . -name "00*.png" > flist.txt
inv_fns flist.txt png
sox audio.mp2 audio2.mp2 reverse
ffmpeg -r $2 -i %08d.png -i audio2.mp2 -ab 128k -b:v 1800k "inv_$1"
echo "All done safe, remove unneeded files"

