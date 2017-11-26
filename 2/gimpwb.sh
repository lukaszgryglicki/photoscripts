#!/bin/sh
fname_nef="$1"
fname_jpg1="out.jpeg"
fname_jpg2=`echo "wbjpg/$1" | cut -f 1 -d .`.jpg
ufraw-batch --embedded-image --overwrite --output "$fname_jpg1" "$1"
gimp -f -i -d -b "(define (aceq-image filename-in filename-out) (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename-in \"\"))) (drawable (car (gimp-image-active-drawable image)))) (gimp-levels-stretch drawable) (gimp-file-save RUN-NONINTERACTIVE image drawable filename-out \"\"))) (aceq-image \"$fname_jpg1\" \"$fname_jpg2\")" -b "(gimp-quit 0)"
#jpegwb "$fname_jpg1" "$fname_jpg2" "$2" "$3"
rm -f "$fname_jpg1"
