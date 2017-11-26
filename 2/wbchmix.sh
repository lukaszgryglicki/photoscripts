#!/bin/sh
fname_nef="$1"
fname_jpg1="out.jpeg"
fname_jpg2=`echo "wbjpg/$1" | cut -f 1 -d .`.jpg
ufraw-batch --embedded-image --overwrite --output "$fname_jpg1" "$1"
jpegwb "$fname_jpg1" "$fname_jpg2" "$2" "$3"
rm -f "$fname_jpg1"

