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
secret=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "Installing Node..."
cd ~
git clone https://github.com/tj/n.git
cd n
PREFIX=$HOME make install
N_PREFIX=$HOME/.apps/node n latest

echo 'export PATH=$PATH:~/.apps/node/bin' >> ~/.bashrc
export PATH=$PATH:~/.apps/node/bin

echo "Installing Flood..."
git clone https://github.com/Flood-UI/flood.git ~/.apps/flood

echo "Configuring Flood..."
cd ~/.apps/flood
cp config.template.js config.js
sed -i "s/floodServerPort: 3000/floodServerPort: $port/" config.js
sed -i "s/baseURI: '\/'/baseURI: '\/flood'/" config.js
sed -i "s/secret: 'flood'/secret: '$secret'/" config.js
npm install
npm run build

echo "Configuring nginx..."
echo "location /flood/ {
  proxy_pass http://127.0.0.1:11659/;
}" >> ~/.apps/nginx/proxy.d/flood.conf
chmod 755 ~/.apps/nginx/proxy.d/flood.conf

echo "Installing Service..."
echo "[Unit]
Description=Flood
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=$HOME/.apps/flood
ExecStart=$HOME/.apps/node/bin/node $HOME/.apps/flood/server/bin/start.js

[Install]
WantedBy=default.target" >> ~/.config/systemd/user/flood.service
systemctl --user daemon-reload
systemctl --user enable flood

loginctl enable-linger $USER

echo "Starting Flood..."
systemctl --user start flood

echo "Downloading Uninstaller..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Flood/flood-uninstall.sh
chmod +x flood-uninstall.sh

echo "Cleaning Up..."
rm -- "$0"

printf "\033[0;32mDone!\033[0m\n"
echo "Access your Flood installation at https://$USER.$(hostname).usbx.me/flood"
echo "Use \"$HOME/.config/rtorrent/socket\" for Unix Socket"
echo "Run ./flood-uninstall.sh to uninstall" 
