#!/bin/bash
mkdir -p ~/.rclone-tmp
cd ~/.rclone-tmp
wget -O rclone-current-linux-amd64.zip https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip -o ~/bin
cp rclone-v*/rclone ~/bin
cd ~
rm -rfv .rclone-tmp/
which rclone
