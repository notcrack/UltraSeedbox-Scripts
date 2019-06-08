#!/bin/bash
#USB Jellyfin Upgrader
#Written by Alpha#5000

if [ ! -d "$HOME/.apps/jellyfin" ]
then
        echo "Error: Jellyfin is not installed"
        exit
fi

RELEASE=$(curl -s "https://repo.jellyfin.org/releases/server/linux/" | grep -oE "jellyfin_([0-9\.]+)\.portable\.tar\.gz" | head -1)

if [ -z "$RELEASE" ]
then
	echo "Error: Unable to download Jellyfin"
	exit
fi

echo "Stopping Jellyfin..."
systemctl --user stop jellyfin

echo "Upgrading Jellyfin..."
rm -rf ~/.apps/jellyfin

mkdir ~/.apps/jellyfin
cd ~/.apps/jellyfin

wget -q "https://repo.jellyfin.org/releases/server/linux/$RELEASE"
tar --strip-components=1 -zxf $RELEASE
rm $RELEASE

echo "Starting Jellyfin..."
systemctl --user start jellyfin

echo "Done!"
