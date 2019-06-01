#!/bin/bash
#USB Jellyfin Uninstaller
#Written by Alpha#5000

echo "Stopping Jellyfin..."
systemctl --user stop jellyfin

echo "Removing directories..."
rm -r $HOME/.apps/jellyfin
rm -r $HOME/.config/jellyfin

echo "Updating nginx..."
rm $HOME/.apps/nginx/proxy.d/jellyfin.conf

echo "Restarting nginx..."
app-nginx restart

echo "Removing service..."
rm $HOME/.config/systemd/user/jellyfin.service
systemctl --user daemon-reload

echo "Cleaning up..."

rm -- "$0"

echo "Done!"
