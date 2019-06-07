#!/bin/bash
#USB Mellow Installer
#Written by Alpha#5000

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
        exit
fi 

PORT=$(( 11000 + (($UID - 1000) * 50) + 30))

if [ ! -d "$HOME/.nvm" ]
then
    echo "Installing Node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 12 --latest-npm
    nvm alias default 12
    nvm use default
else
    echo "Node already installed. Skipping..."
fi

echo "Installing Mellow..."
git clone -b develop "https://github.com/v0idp/Mellow.git" ~/.apps/mellow
cd ~/.apps/mellow
npm install --loglevel=silent

echo "Configuring Mellow..."
sed -i "s/5060/$port/g" ~/.apps/mellow/src/WebServer.js

echo "Installing Service..."
echo "[Unit]
Description=Mellow
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=$HOME/.apps/mellow
ExecStart=$(which node) src/index.js

[Install]
WantedBy=default.target" >> $HOME/.config/systemd/user/mellow.service
systemctl --user daemon-reload
systemctl --user enable mellow

loginctl enable-linger $USER

echo "Starting Mellow..."
systemctl --user start mellow

echo "Downloading Uninstaller..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Mellow/mellow-uninstall.sh
chmod +x mellow-uninstall.sh

echo "Cleaning Up..."
rm -- "$0"

ip=$(curl -s "https://ipinfo.io/ip")
printf "\033[0;32mDone!\033[0m\n"
echo "Access your Mellow installation at http://$ip:$port"
echo "Run ./mellow-uninstall.sh to uninstall"
