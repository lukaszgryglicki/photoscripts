#!/bin/bash
if [ -z "${1}" ]
then
  echo "$0: missing file name"
  exit 1
fi
tif=`echo "$1" | cut -f 1 -d .`.tiff
jpg=`echo "$1" | cut -f 1 -d .`.jpg
png=`echo "$1" | cut -f 1 -d .`.png
avif=`echo "$1" | cut -f 1 -d .`.avif
# dcraw -o 0 -g 1 0 -j -D -T -4 "${1}" || exit 2
dcraw -o 0 -g 1 0 -j -D -T -6 -W "${1}" || exit 2
# convert "${tif}" -auto-level -gamma 2.222 -quality 88% "${jpg}"
# convert "${tif}" -normalize -gamma 2.2 -quality 88% "${jpg}"
convert "${tif}" -contrast-stretch '2%x2%' -gamma 2.6 -quality 85% "${jpg}" || exit 3
convert "${tif}" -contrast-stretch '2%x2%' -gamma 2.6 -depth 12 -quality 85% "${avif}" || exit 4
convert "${tif}" -contrast-stretch '2%x2%' -gamma 2.6 -depth 16 -define png:compression-level=9 -define png:compression-strategy=2 "${png}" || exit 5
rm -f "${tif}" || exit 6
ls -l "${jpg}" "${avif}" "${png}"
