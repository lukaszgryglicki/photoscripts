#!/bin/bash
# TIFF - keep tiff file
# NOJPG - don't generate JPG file
# PNG - generate 16bit png file
# AVIF - generate 12bit AVIF file
# CONTRAST - defaults to '1%x1%'
# GAMMA - defaults to 2.222
# QUALITY - defaults to 87%
if [ -z "${1}" ]
then
  echo "$0: missing file name"
  exit 1
fi
if [ -z "${CONTRAST}" ]
then
  export CONTRAST='1%x1%'
fi
if [ -z "${GAMMA}" ]
then
  export GAMMA='2.222'
fi
if [ -z "${QUALITY}" ]
then
  export QUALITY='87%'
fi
tif=`echo "$1" | cut -f 1 -d .`.tiff
dcraw -o 0 -g 1 0 -j -D -T -6 -W "${1}"
res=$?
if [ "${res}" != "0" ]
then
  echo "$0: $1 is probably compressed, trying with dcraw_emu, this does not support skipping demosaicing"
  dcraw_emu -a -o 0 -g 1 0 -j -T -6 -W "${1}" || exit 2
  mv "${1}.tiff" "${tif}" || exit 3
fi
if [ -z "${NOJPG}" ]
then
  jpg=`echo "$1" | cut -f 1 -d .`.jpg
  convert "${tif}" -contrast-stretch "${CONTRAST}" -gamma "${GAMMA}" -quality "${QUALITY}" "${jpg}" || exit 3
fi
if [ ! -z "${AVIF}" ]
then
  avif=`echo "$1" | cut -f 1 -d .`.avif
  convert "${tif}" -contrast-stretch "${CONTRAST}" -gamma "${GAMMA}" -depth 12 -quality "${QUALITY}" "${avif}" || exit 4
fi
if [ ! -z "${PNG}" ]
then
  png=`echo "$1" | cut -f 1 -d .`.png
  convert "${tif}" -contrast-stretch "${CONTRAST}" -gamma "${GAMMA}" -depth 16 -define png:compression-level=9 -define png:compression-strategy=2 "${png}" || exit 5
fi
if [ -z "${TIFF}" ]
then
  rm -f "${tif}" || exit 6
fi
