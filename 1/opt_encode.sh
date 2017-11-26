#!/bin/sh
mkdir opthist
for f in *.NEF
do
    ls -l "$f"
    ./opt.sh "$f" "nhy000000000LaaaLaaaL" "109050"
done

