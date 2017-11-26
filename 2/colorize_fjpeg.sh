mkdir color_fjpeg
for f in SAM_*
do
    ./sambwfjpeg.sh "$f" "color_fjpeg/$f"
    ls -l "color_fjpeg/$f"
done

