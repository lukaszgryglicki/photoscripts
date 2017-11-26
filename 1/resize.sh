#!/bin/sh
for f in *.NEF
do
	ufraw-batch --embedded-image "$f" --exif --overwrite --output "$f.JPG"
done

for f in *.JPG
do
    convert "$f" -geometry 50% -quality 80% "small_$f"
done

