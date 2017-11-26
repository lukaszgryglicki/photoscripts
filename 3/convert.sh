#!/bin/sh
# convert "$1" -type grayscale -normalize 1 -quality 94% -depth 8 "$2"
# convert "$1" -type grayscale -auto-gamma -linear-stretch 1%x2% -quality 94% -depth 8 "$2"
convert "$1" -type grayscale -gamma 2.3 -linear-stretch 2%x3% -quality 94% -depth 8 "$2"
