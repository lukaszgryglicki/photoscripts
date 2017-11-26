#!/bin/sh
for f in *.NEF
do
    ls -l "$f"
    ./fswb2jpg.sh "$f"
done
mkdir fswb_jpg
mv *.jpg ./fswb_jpg/

