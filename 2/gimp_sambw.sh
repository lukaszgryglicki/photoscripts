gimp -f -i -d -b "(define (aceq-image filename-in filename-out) (let* ((image (car (gimp-file-load RUN-NONINTERACTIVE filename-in \"\"))) (drawable (car (gimp-image-active-drawable image)))) (plug-in-c-astretch RUN-NONINTERACTIVE image drawable) (gimp-levels-stretch drawable) (plug-in-colors-channel-mixer RUN-NONINTERACTIVE image drawable FALSE -1.0 0.0 2.0 -0.5 2.0 -0.5 2.0 0.0 -1.0) (gimp-file-save RUN-NONINTERACTIVE image drawable filename-out \"\"))) (aceq-image \"$1\" \"$2\")" -b "(gimp-quit 0)"