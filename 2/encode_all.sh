#!/bin/sh
mkdir ufwb
for f in *.NEF
do
    ./ufwb.sh "$f"
done

