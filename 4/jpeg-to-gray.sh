#!/bin/bash
if [ -z "$Q" ]
then
  export Q='86'
fi
echo "quality: $Q%"
for f in "$@"
do
  echo -n "'$f' -> 'bw_$f' ..."
  magick "$f" -colorspace Gray -quality "$Q" "bw_$f"
  echo ' done.'
done

