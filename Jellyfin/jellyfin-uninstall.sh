#!/bin/bash
#USB Jellyfin Uninstaller
#Written by Alpha#5000

echo "Stopping Jellyfin..."
systemctl --user stop jellyfin

echo "Removing Files..."
rm -r $HOME/.apps/jellyfin
rm -r $HOME/.config/jellyfin

echo "Restoring nginx..."
rm $HOME/.apps/nginx/proxy.d/jellyfin.conf
app-nginx restart

echo "Removing Service..."
rm $HOME/.config/systemd/user/jellyfin.service
systemctl --user daemon-reload

echo "Cleaning Up..."

rm -- "$0"

echo "Done!"
