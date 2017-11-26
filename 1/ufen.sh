#!/bin/sh
fname_1="$1"
fname_2=`echo "ufen/$1" | cut -f 1 -d .`.JPG
maxbw "$fname_1" "$fname_2" 0 3 2

