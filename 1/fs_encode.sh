#!/bin/sh
for f in *.NEF
do
    ls -l "$f"
    ./fsnef2jpg.sh "$f"
done
mkdir fsjpg
mv *.jpg ./fsjpg/

