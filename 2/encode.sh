#!/bin/sh
for f in *.NEF
do
    ls -l "$f"
    ./nef2jpg.sh "$f"
done
mkdir jpg
mv *.jpg ./jpg/

