#!/bin/sh
mkdir mbw
for f in *.NEF
do
    ls -l "$f"
    ./mbw.sh "$f"
done

