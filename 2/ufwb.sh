#!/bin/sh
fname_nef="$1"
fname_jpg=`echo "ufwb/$1" | cut -f 1 -d .`.JPG
ufraw-batch --wb=auto --exposure=auto --restore=lch --clip=film --wavelet-denoising-threshold=50 --interpolation=bilinear --color-smoothing "$fname_nef" --out-type=jpg --compression=80 --overwrite --output="$fname_jpg"

