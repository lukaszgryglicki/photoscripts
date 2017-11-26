#!/bin/sh
rm *.jpeg
rm result.avi spy.mp3 spy.avi
mixer mic 100
mixer rec 100
pwcsnap -s vga -k -f 5 -q 85 -c $1 -o ./%s.jpeg -i 1000 &
AUDIODRIVER=oss rec -b 16 -r 16000 -c 1 -t mp3 spy.mp3 trim 0 $1
sleep 1
mencoder  "mf://*.[jJ][pP]*[gG]" -mf fps=1 -o spy.avi -ovc lavc -lavcopts vcodec=mpeg4:vhq:vbitrate=200 -ofps 1.0
ffmpeg -i spy.mp3 -i spy.avi result.avi
rm *.jpeg
rm spy.mp3 spy.avi
file result.avi
ls -l result.avi

