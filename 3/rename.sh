#!/bin/bash
if [ -z "${1}" ]
then
  echo "${0}: you need to specify 1st extension, for example HIF"
  exit 1
fi
if [ -z "${2}" ]
then
  echo "${0}: you need to specify 2nd extension, for example heic"
  exit 2
fi
for f in *.${1}
do
  f2="${f%.${1}}.${2}"
  if [ ! -f "${f}" ]
  then
    echo "${0}: '${f}' does not exist, skipping"
    continue
  fi
  if [ -f "${f2}" ]
  then
    echo "${0}: '${f2}' already exists, skipping"
    continue
  fi
  mv "${f}" "${f2}"
done
