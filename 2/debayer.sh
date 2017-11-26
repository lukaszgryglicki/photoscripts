#!/bin/sh
#dcraw -o 0 -D -g 1 1 -r 1 1 1 1 -6 -T "$1"
dcraw -g 1 1 -j -t 0 -o 0 -D -r 1 1 1 1 -T -6 "$1"

