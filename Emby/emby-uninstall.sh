#!/bin/bash
#USB Emby Uninstaller
#Written by Alpha#5000

echo "Stopping Emby..."
systemctl --user stop emby

echo "Removing directories..."
rm -r $HOME/.apps/emby
rm -r $HOME/.config/emby

echo "Updating nginx..."
rm $HOME/.apps/nginx/proxy.d/emby.conf

echo "Restarting nginx..."
app-nginx restart

echo "Removing service..."
rm $HOME/.config/systemd/user/emby.service
systemctl --user daemon-reload

echo "Cleaning up..."

rm -- "$0"

echo "Done!"
