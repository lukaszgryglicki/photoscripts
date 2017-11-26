fname_nef="$1"
fname_jpg1=`echo "ufwb/col_$1" | cut -f 1 -d .`.JPG
fname_jpg2=`echo "ufwb/bw_$1" | cut -f 1 -d .`.JPG
ufraw-batch "$fname_nef" --overwrite --embedded-image --output=out.jpeg
maxbw out.jpeg "$fname_jpg1" 0 1 2
maxbw out.jpeg "$fname_jpg2"
rm out.jpeg
