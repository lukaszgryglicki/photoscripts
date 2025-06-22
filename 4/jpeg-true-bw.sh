#!/bin/bash
if [ -z "$LO" ]
then
  export LO='.5'
fi
if [ -z "$HI" ]
then
  export HI='.5'
fi
if [ -z "$Q" ]
then
  export Q='88'
fi
R=1 G=1 B=1 LO="$LO" HI="$HI" O='.JPG:.png' PQ=1 jpegbw $*
for f in bw_*.png
do
  b="${f%.png}"
  s="${b#bw_}"
  magick "$f" -colorspace Gray -quality "$Q" "$b.jpg" && rm -f "$f" && exiftool -TagsFromFile "$s.JPG" -overwrite_original "$b.jpg"
done

