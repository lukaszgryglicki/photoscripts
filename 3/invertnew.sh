#!/bin/sh
echo "usage invert.sh file_in fps"
rm audio.mp2 audio2.mp2 flist.txt
for f in 00*.png; do rm -f $f; done
ffmpeg -i "$1" %08d.png -ab 128k audio.mp2
find . -name "00*.png" > flist.txt
inv_fns flist.txt png
rm flist.txt
sox audio.mp2 audio2.mp2 reverse
rm audio.mp2
ffmpeg -r $2 -i %08d.png -i audio2.mp2 -ab 128k -b:v 1800k "inv_$1"
rm audio2.mp2
for f in 0*.png; do rm -f $f; done
echo "All done"

