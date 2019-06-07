#!/bin/bash
#USB Mellow Uninstaller
#Written by Alpha#5000

echo "Stopping Mellow..."
systemctl --user stop mellow

echo "Removing Files..."
rm -rf ~/.apps/mellow

if [ -d "$HOME/.nvm" ]
then
    read -p "Uninstall Node? (y/n) " input
    if [ "$input" = "y" ]
    then
        if [ -z "$(which nvm)" ]
        then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        fi
        nvm deactivate
        nvm uninstall 12
        nvm alias default system
        nvm use default
    fi
fi

echo "Removing Service..."
rm ~/.config/systemd/user/mellow.service
systemctl --user daemon-reload

echo "Cleaning Up..."

rm -- "$0"

echo "Done!"
