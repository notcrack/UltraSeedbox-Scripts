#!/bin/bash
#USB Mellow Installer
#Written by Alpha#5000

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
        exit
fi 

mkdir ~/.apps/nodejs
cd ~/.apps/nodejs

echo "Downloading NodeJS..."
version=$(curl -s "https://resolve-node.now.sh/lts")
release="node-$version-linux-x64.tar.xz"
wget -q "https://nodejs.org/dist/$version/$release"
tar --strip-components=1 -xf $release
rm $release

echo 'export PATH=$PATH:~/.apps/nodejs/bin' >> ~/.bashrc
source ~/.bashrc

echo "Downloading Mellow..."
git clone -b develop "https://github.com/v0idp/Mellow.git" ~/.apps/mellow
cd ~/.apps/mellow

npm install --loglevel=silent

echo "Installing service..."
mkdir -p ~/.config/systemd/user
echo "[Unit]
Description=Mellow
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=$HOME/.apps/mellow
ExecStart=$HOME/.apps/nodejs/bin/node src/index.js
[Install]
WantedBy=default.target" >> $HOME/.config/systemd/user/mellow.service
systemctl --user daemon-reload
systemctl --user enable mellow

loginctl enable-linger $USER

echo "Updating ports..."
port=$(( 11000 + (($UID - 1000) * 50) + 30))
sed -i "s/5060/$port/g" ~/.apps/mellow/src/WebServer.js
sed -i "s/this.app.get('\//this.app.get('\/mellow\//g" ~/.apps/mellow/src/WebServer.js

echo "Starting Mellow..."
systemctl --user start mellow

echo "Downloading uninstall script..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Mellow/mellow-uninstall.sh
chmod +x mellow-uninstall.sh

echo "Cleaning up..."
rm -- "$0"

ip=$(curl -s "https://ipinfo.io/ip")
printf "\033[0;31mDone!\033[0m\n"
echo "Access your Mellow installation at http://$ip:$port"
echo "Run ./mellow-uninstall.sh to uninstall | Run ./mellow-upgrade.sh to upgrade" 