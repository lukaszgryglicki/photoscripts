#!/bin/sh
mkdir ufwb
for f in *.NEF
do
    ls -l "$f"
    ./ufwb.sh "$f"
done

