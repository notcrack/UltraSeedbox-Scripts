#!/bin/bash
#USB Flood Uninstaller
#Written by Alpha#5000

echo "Stopping Flood..."
systemctl --user stop flood

echo "Removing Files..."
rm -rf ~/.apps/flood

if [ ! -f "$HOME/.nvm" ]
then
    read -p "Uninstall Node? (y/n) " input
    if [ "$input" = "y" ]
    then
        rm -rf ~/.nvm
    fi
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
