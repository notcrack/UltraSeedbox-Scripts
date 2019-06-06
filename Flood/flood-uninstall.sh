#!/bin/bash
#USB Flood Uninstaller
#Written by Alpha#5000

echo "Stopping Flood..."
systemctl --user stop flood

echo "Removing Files..."
rm -rf ~/.apps/flood

read -p "Uninstall NodeJS? (y/n) " input
if [ "$input" = "y" ]
then
    rm -rf ~/bin/n
    rm -rf ~/.apps/node
    sed -i '/export PATH=$PATH:~\/.apps\/node\/bin/d' ~/.bashrc
fi

echo "Restoring nginx..."
rm -rf ~/.apps/nginx/proxy.d/flood.conf
app-nginx restart

echo "Removing Service..."
rm $HOME/.config/systemd/user/flood.service
systemctl --user daemon-reload

echo "Cleaning Up..."

rm -- "$0"

echo "Done!"
