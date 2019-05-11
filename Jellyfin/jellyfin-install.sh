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

file=$(curl -s "https://repo.jellyfin.org/releases/server/linux/" | grep -oE "jellyfin_([0-9\.]+)\.portable\.tar\.gz" | head -1)
if [ -z "$file" ]
then
	echo "Error: Unable to download Jellyfin"
	exit
fi

cd $HOME
mkdir jellyfin
cd jellyfin

echo "Downloading Jellyfin..."
wget -q "https://repo.jellyfin.org/releases/server/linux/$file"

echo "Extracting Jellyfin..."
tar --strip-components=1 -zxf $file
rm $file

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
}" >> $HOME/.apps/nginx/proxy.d/jellyfin.conf
chmod 755 $HOME/.apps/nginx/proxy.d/jellyfin.conf

echo "Restarting nginx..."
app-nginx restart

mkdir $HOME/jellydata
cd $HOME/jellydata
mkdir cache config data log

echo "Installing Service..."
mkdir -p $HOME/.config/systemd/user
echo "[Unit]
Description=Jellyfin

[Service]
ExecStart=$HOME/jellyfin/jellyfin -d $HOME/jellydata/data -w $HOME/jellyfin/jellyfin-web/src -C $HOME/jellydata/cache -c $HOME/jellydata/config -l $HOME/jellydata/log
RestartSec=10s
Restart=on-failure

[Install]
WantedBy=default.target" >> $HOME/.config/systemd/user/jellyfin.service
systemctl --user daemon-reload
systemctl --user enable jellyfin

loginctl enable-linger $USER

echo "Updating ports..."
systemctl --user start jellyfin
sleep 10
systemctl --user stop jellyfin
sed -i 's/8096/$port/g' $HOME/jellydata/config/system.xml
sed -i 's/<EnableHttps>true<\/EnableHttps>/<EnableHttps>false<\/EnableHttps>/g' $HOME/jellydata/config/system.xml

echo "Starting Jellyfin..."
systemctl --user start jellyfin

echo "Done!"
echo "Access your Jellyfin installation at https://$USER.$(hostname).usbx.me/emby"