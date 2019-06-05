#!/bin/bash
#USB Flood installer
#Written by nostyle#0001
#May or may not have borrowed a lot from Alpha#5000's work.

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
        exit
fi

port=$(( 11009 + (($UID - 1000) * 50)))
key=$(openssl rand -base64 32)

echo "Installing n + latest node..."
cd $HOME
git clone https://github.com/tj/n.git
cd $HOME/n
PREFIX=$HOME make install
cd $HOME
N_PREFIX=$HOME n latest

echo "Downloading Flood..."
git clone https://github.com/Flood-UI/flood.git

echo "Configuring Flood..."
npm install -g node-gyp
cd $HOME/flood
cp config.template.js config.js
sed -i "s/floodServerHost: '127.0.0.1'/floodServerHost: '0.0.0.0'/"
sed -i "s/floodServerPort: 3000/floodServerPort: $port/"
sed -i "s/baseURI: '/'/baseURI: '/flood'/"
sed -i "s/secret: 'flood'/secret: $key/"
npm install
npm run build

echo "Updating nginx..."
echo "location /flood {
    # Proxy Flood
    proxy_pass http://127.0.0.1:$port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Protocol \$scheme;
    proxy_set_header X-Forwarded-Host \$http_host;
}" >> ~/.apps/nginx/proxy.d/flood.conf
chmod 755 ~/.apps/nginx/proxy.d/flood.conf

echo "Installing service..."
mkdir -p $HOME/.config/systemd/user
echo "[Unit]
Description=Flood
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=$HOME/bin/node $HOME/flood/server/bin/start.js
[Install]
WantedBy=default.target" >> $HOME/.config/systemd/user/flood.service
systemctl --user daemon-reload
systemctl --user enable flood

loginctl enable-linger $USER

echo "Starting Flood..."
systemctl --user start flood

echo "Downloading uninstall script..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Flood/flood-uninstall.sh
chmod +x flood-uninstall.sh

echo "Cleaning up..."
rm -- "$0"

printf "\033[0;32mDone!\033[0m\n"
echo "Access your Flood installation at https://$USER.$(hostname).usbx.me/flood"
echo "Use $HOME/.config/rtorrent/socket for"
echo "Run ./flood-uninstall.sh to uninstall" 