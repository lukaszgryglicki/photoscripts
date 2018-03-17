#!/bin/bash
/Applications/GIMP.app/Contents/MacOS/GIMP -f -i -d -b "(define (aceq-image filename-in filename-out) (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename-in \"\"))) (drawable (car (gimp-image-active-drawable image)))) (gimp-levels-stretch drawable) (gimp-file-save RUN-NONINTERACTIVE image drawable filename-out \"\"))) (aceq-image \"$1\" \"$2\")" -b "(gimp-quit 0)"
