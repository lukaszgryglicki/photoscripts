mencoder $1 -o $2 -oac mp3lame -ovc lavc -vf scale=640:360 -lameopts q=9:vbr=2 -lavcopts vcodec=mpeg4:vhq:vbitrate=400
