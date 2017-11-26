#!/bin/sh
fname_nef="$1"
fname_jpg1="out.jpeg"
fname_jpg2=`echo "mbw/$1" | cut -f 1 -d .`.jpg
ufraw-batch --embedded-image --overwrite --output "$fname_jpg1" "$1"
maxbw "$fname_jpg1" "$fname_jpg2"
rm -f "$fname_jpg1"

