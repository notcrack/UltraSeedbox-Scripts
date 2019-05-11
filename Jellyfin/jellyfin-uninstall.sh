#!/bin/bash
#USB Jellyfin Uninstaller
#Written by Alpha#5000

systemctl --user stop jellyfin

rm -r $HOME/jellyfin
rm -r $HOME/jellydata

rm $HOME/.apps/nginx/proxy.d/jellyfin.conf
app-nginx restart

rm $HOME/.config/systemd/user/jellyfin.service
systemctl --user daemon-reload

echo "Done!"
