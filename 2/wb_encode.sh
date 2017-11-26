#!/bin/sh
mkdir wbjpg
for f in *.NEF
do
    ls -l "$f"
    ./wbchmix.sh "$f" "$1" "$2"
done

