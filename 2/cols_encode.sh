#!/bin/sh
mkdir ufwb
for f in *.NEF
do
    ls -l "$f"
    ./cols.sh "$f"
done

