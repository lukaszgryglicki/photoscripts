#!/bin/bash
R=1 G=1 B=1 LO=1 HI=1 O='.JPG:.png' PQ=1 jpegbw $*
for f in bw_*.png
do
  b="${f%.png}"
  s="${b#bw_}"
  magick "$f" -colorspace Gray -quality 90 "$b.jpg" && rm -f "$f" && exiftool -TagsFromFile "$s.JPG" -overwrite_original "$b.jpg"
done

