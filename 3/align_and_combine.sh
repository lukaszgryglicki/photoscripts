#!/bin/bash
if ( [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] )
then
  echo "$0: you need to specify 3 images for R, G, B channels respectively and PNG file name base"
  echo "$0: example 1.jpg 2.jpg 3.jpg output -> will generate output.png for R=1.jpg, G=2.jpg, B=3.jp aligning them first"
  exit 1
fi
align.py "$1" "$2" "$3" aligned || exit 2
convert aligned_red.png aligned_green.png aligned_blue.png -set colorspace RGB -combine -define png:compression-level=9 -define png:compression-strategy=2 "${4}.png" || exit 3
rm -f aligned_red.png aligned_green.png aligned_blue.png
