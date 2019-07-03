#!/bin/bash
mkdir -p ~/tmp
wget https://github.com/trapexit/mergerfs/releases/download/2.28.1/mergerfs_2.28.1.debian-stretch_amd64.deb -P ~/tmp
dpkg -x ~/tmp/mergerfs_2.28.1.debian-stretch_amd64.deb ~/tmp
mv ~/tmp/usr/bin/* ~/.local/bin
rm -rf ~/tmp
rm -rf ~/.rclone-tmp
rclone version
