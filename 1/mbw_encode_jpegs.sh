mkdir mbw
for f in *.[jJ][pP]*
do 
    maxbw "$f" "mbw/$f"
done

