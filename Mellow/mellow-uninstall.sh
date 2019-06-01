#!/bin/bash
#USB Mellow Uninstaller
#Written by Alpha#5000

echo "Stopping Mellow..."
systemctl --user stop mellow

echo "Removing directories..."
rm -r $HOME/.apps/nodejs
rm -r $HOME/.apps/mellow

echo "Updating nginx..."
rm $HOME/.apps/nginx/proxy.d/mellow.conf

echo "Restarting nginx..."
app-nginx restart

echo "Removing service..."
rm $HOME/.config/systemd/user/mellow.service
systemctl --user daemon-reload

echo "Cleaning up scripts..."

rm -- "$0"
rm -f mellow-upgrade.sh

echo "Done!"
