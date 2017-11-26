mkdir color
for f in SAM_*
do
    ./gimp_sambw.sh "$f" "color/$f"
    ls -l "color/$f"
done

