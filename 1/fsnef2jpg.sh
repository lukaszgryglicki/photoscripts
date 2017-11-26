#!/bin/sh
fname_nef="$1"
fname_png=`echo "$1" | cut -f 1 -d .`.png
fname_jpg=`echo "$1" | cut -f 1 -d .`.jpg
ufraw-batch --wb=auto --restore=hsv --wavelet-denoising-threshold=50 --exposure=auto --linearity=0.10 --interpolation=ahd --saturation=1.0 --out-type=png --out-depth=16 --overwrite --output "$fname_png" "$fname_nef"
#gimp -f -i -d -b "(define (aceq-image filename-in filename-out) (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename-in \"\"))) (drawable (car (gimp-image-active-drawable image)))) (gimp-levels-stretch drawable) (plug-in-colors-channel-mixer RUN-NONINTERACTIVE image drawable FALSE 1 0 0 0 1 0 1 0 0) (gimp-file-save RUN-NONINTERACTIVE image drawable filename-out \"\"))) (aceq-image \"$fname_png\" \"$fname_jpg\")" -b "(gimp-quit 0)"
gimp -f -i -d -b "(define (aceq-image filename-in filename-out) (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename-in \"\"))) (drawable (car (gimp-image-active-drawable image)))) (gimp-levels-stretch drawable) (gimp-file-save RUN-NONINTERACTIVE image drawable filename-out \"\"))) (aceq-image \"$fname_png\" \"$fname_jpg\")" -b "(gimp-quit 0)"
rm -f "$fname_png"
