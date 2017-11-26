fname_nef="$1"
fname_jpg=`echo "$1" | cut -f 1 -d .`.JPG
ufraw-batch "$fname_nef" --overwrite --embedded-image --output=$fname_jpg
