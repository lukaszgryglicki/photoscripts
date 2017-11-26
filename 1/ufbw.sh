#!/bin/sh
fname_1="$1"
fname_2=`echo "ufbw/$1" | cut -f 1 -d .`.JPG
maxbw "$fname_1" "$fname_2" 1 3 1

