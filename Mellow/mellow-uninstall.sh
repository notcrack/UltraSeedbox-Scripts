#!/bin/bash
#USB Mellow Uninstaller
#Written by Alpha#5000

echo "Stopping Mellow..."
systemctl --user stop mellow

echo "Removing directories..."
rm -rf $HOME/.apps/nodejs
rm -rf $HOME/.apps/mellow
sed -i '/export PATH=$PATH:~\/.apps\/nodejs\/bin/d' ~/.bashrc

echo "Removing service..."
rm $HOME/.config/systemd/user/mellow.service
systemctl --user daemon-reload

echo "Cleaning up scripts..."

rm -- "$0"
rm -f mellow-upgrade.sh

echo "Done!"