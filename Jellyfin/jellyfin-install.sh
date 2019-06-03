#!/bin/bash
#USB Jellyfin Installer
#Written by Alpha#5000

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
        exit
fi

if [ "$(quota -s | awk 'END {gsub(/[^0-9 ]/, ""); print $3}')" -le "1200" ]
then
        echo "Error: Unsupported plan"
        exit
fi

release=$(curl -s "https://repo.jellyfin.org/releases/server/linux/" | grep -oE "jellyfin_([0-9\.]+)\.portable\.tar\.gz" | head -1)
if [ -z "$release" ]
then
	echo "Error: Unable to download Jellyfin"
	exit
fi

mkdir ~/.apps/jellyfin
cd ~/.apps/jellyfin

echo "Downloading Jellyfin..."
wget -q "https://repo.jellyfin.org/releases/server/linux/$release"
tar --strip-components=1 -zxf $release
rm $release

port=$(( 11002 + (($UID - 1000) * 50)))

echo "Updating nginx..."
echo "location /emby {
    # Proxy main Jellyfin traffic
    proxy_pass http://127.0.0.1:$port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Protocol \$scheme;
    proxy_set_header X-Forwarded-Host \$http_host;

    # Disable buffering when the nginx proxy gets very resource heavy upon streaming
    proxy_buffering off;
}

location /emby/embywebsocket {
    # Proxy Jellyfin Websockets traffic
    proxy_pass http://127.0.0.1:$port;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Protocol \$scheme;
    proxy_set_header X-Forwarded-Host \$http_host;
}" >> ~/.apps/nginx/proxy.d/jellyfin.conf
chmod 755 ~/.apps/nginx/proxy.d/jellyfin.conf

echo "Restarting nginx..."
app-nginx restart

mkdir ~/.config/jellyfin
cd ~/.config/jellyfin
mkdir cache config data log

echo "Installing service..."
mkdir -p $HOME/.config/systemd/user
echo "[Unit]
Description=Jellyfin
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=$HOME/.apps/jellyfin/jellyfin -d $HOME/.config/jellyfin/data -w $HOME/.apps/jellyfin/jellyfin-web/src -C $HOME/.config/jellyfin/cache -c $HOME/.config/jellyfin/config -l $HOME/.config/jellyfin/log

[Install]
WantedBy=default.target" >> $HOME/.config/systemd/user/jellyfin.service
systemctl --user daemon-reload
systemctl --user enable jellyfin

loginctl enable-linger $USER

echo "Updating ports..."
systemctl --user start jellyfin
sleep 5
systemctl --user stop jellyfin
sed -i "s/8096/$port/g" $HOME/.config/jellyfin/config/system.xml
sed -i 's/<EnableHttps>true<\/EnableHttps>/<EnableHttps>false<\/EnableHttps>/g' $HOME/.config/jellyfin/config/system.xml
sed -i 's/-1/6/g' $HOME/.config/jellyfin/config/encoding.xml

echo "Starting Jellyfin..."
systemctl --user start jellyfin

echo "Downloading uninstall script..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Jellyfin/jellyfin-uninstall.sh
chmod +x jellyfin-uninstall.sh

echo "Cleaning up..."
rm -- "$0"

printf "\033[0;32mDone!\033[0m\n"
echo "Access your Jellyfin installation at https://$USER.$(hostname).usbx.me/emby"
echo "Run ./jellyfin-uninstall.sh to uninstall" 
