#!/bin/sh
#ufraw-batch --output=1.ppm --out-depth=8 --overwrite $1
fname=`echo "$1" | cut -f 1 -d .`.tiff
fname2=`echo "$1" | cut -f 1 -d .`.jpg
dcraw -a -T $1
convert $fname -quality 95 $fname2
rm -f $fname

