#!/bin/sh
umount -f /Volumes/ramdisk/
diskutil erasevolume HFS+ 'ramdisk' `hdiutil attach -nomount ram://819200`
