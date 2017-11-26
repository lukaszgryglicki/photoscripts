echo 'usage pars: infile partnum from len'
mencoder -ovc lavc -oac copy -lavcopts vcodec=mpeg4:vbitrate=10000:vhq $1 -o parts/$2.avi -ss $3 -endpos $4
