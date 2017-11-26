mencoder -vf scale=640:480 -ofps 25 ????.avi -o merged.avi -ovc lavc -oac mp3lame -lavcopts vcodec=mpeg4:vbitrate=2000:vhq -lameopts q=6 
