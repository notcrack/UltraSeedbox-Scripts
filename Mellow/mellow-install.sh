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

git clone -b develop "https://github.com/v0idp/Mellow.git" ~/.apps/mellow
cd ~/.apps/mellow

npm install --loglevel=silent

port=$(( 11000 + (($UID - 1000) * 50) + 30))

echo "Updating nginx..."
echo "location /mellow {
    proxy_pass http://127.0.0.1:$port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Protocol \$scheme;
    proxy_set_header X-Forwarded-Host \$http_host;
}" >> ~/.apps/nginx/proxy.d/mellow.conf
chmod 755 ~/.apps/nginx/proxy.d/mellow.conf

echo "Restarting nginx..."
app-nginx restart

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
sed -i "s/5060/$port/g" ~/.apps/mellow/src/WebServer.js
sed -i "s/this.app.get('\//this.app.get('\/mellow\//g" ~/.apps/mellow/src/WebServer.js
sed -i "s/this.app.post('\//this.app.post('\/mellow\//g" ~/.apps/mellow/src/WebServer.js

echo "Starting Mellow..."
systemctl --user start mellow

echo "Downloading uninstall and upgrade scripts..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Mellow/mellow-uninstall.sh
chmod +x mellow-uninstall.sh
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Mellow/mellow-upgrade.sh
chmod +x mellow-upgrade.sh

echo "Cleaning up..."
rm -- "$0"

printf "\033[0;31mDone!\033[0m\n"
echo "Access your Mellow installation at https://$USER.$(hostname).usbx.me/mellow"
echo "Run ./mellow-uninstall.sh to uninstall | Run ./mellow-upgrade.sh to upgrade" 
