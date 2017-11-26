mencoder "$1" -o "$2" -ss $3 -endpos $4 -vf scale=640:360 -oac mp3lame -ovc lavc -lameopts q=8:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=666:vqmin=8

