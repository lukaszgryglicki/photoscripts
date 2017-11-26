#!/bin/sh
fname_nef="$1"
fname_tif1="/Volumes/ramdisk/temp1.tif"
fname_tif2="/Volumes/ramdisk/temp2.tif"
fname_jpg=`echo "$1" | cut -f 1 -d .`.jpg
ufraw-batch --wb=auto --restore=hsv --wavelet-denoising-threshold=50 --exposure=auto --linearity=0.10 --interpolation=ahd --saturation=1.0 --out-type=tiff --out-depth=16 --overwrite --output "$fname_tif1" "$fname_nef"
tiffwb16 "$fname_tif1" "$fname_tif2"
convert "$fname_tif2" "$fname_jpg"
rm -f "$fname_tif1" "$fname_tif2"

