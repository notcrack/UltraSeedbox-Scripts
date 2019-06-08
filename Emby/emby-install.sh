#!/bin/bash
#USB Emby Installer
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

if [ -d "$HOME/.apps/jellyfin" ]
then
        echo "Error: Jellyfin is already installed"
        exit
fi

PORT=$(( 11000 + (($UID - 1000) * 50) + 2))

mkdir ~/.apps/emby
cd ~/.apps/emby

echo "Installing Emby..."
wget -q $(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep 'browser_' | cut -d\" -f4 | head -n 5 | tail -n 1)
RELEASE=$(ls | head -n 1)
dpkg -x $RELEASE ~/.apps/emby
rm $RELEASE

echo $'#!/bin/sh

APP_DIR=$HOME/.apps/emby/opt/emby-server

export AMDGPU_IDS=$APP_DIR/share/libdrm/amdgpu.ids
if [ -z $EMBY_DATA ]; then
  export EMBY_DATA=$HOME/.config/emby
fi
export FONTCONFIG_PATH=$APP_DIR/etc/fonts
export LD_LIBRARY_PATH=$APP_DIR/lib:$APP_DIR/lib/samba
export LIBVA_DRIVERS_PATH=$APP_DIR/lib/dri:/usr/lib/x86_64-linux-gnu/dri:/usr/lib64/dri:/usr/lib/dri
if [ -n $LIBVA_DRIVERS_DIR ]; then
  export LIBVA_DRIVERS_PATH=$LIBVA_DRIVERS_PATH:$LIBVA_DRIVERS_DIR
fi
export SSL_CERT_FILE=$APP_DIR/etc/ssl/certs/ca-certificates.crt

exec $APP_DIR/system/EmbyServer \
  -programdata $EMBY_DATA \
  -ffdetect $APP_DIR/bin/ffdetect \
  -ffmpeg $APP_DIR/bin/ffmpeg \
  -ffprobe $APP_DIR/bin/ffprobe \
  -restartexitcode 3 \
  -updatepackage \'emby-server-deb_{version}_amd64.deb\'' > ~/.apps/emby/opt/emby-server/bin/emby-server

echo "Updating nginx..."
echo "location /emby {
    # Proxy main Emby traffic
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
    # Proxy Emby Websockets traffic
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
}" >> ~/.apps/nginx/proxy.d/emby.conf
chmod 755 ~/.apps/nginx/proxy.d/emby.conf

echo "Restarting nginx..."
app-nginx restart

mkdir ~/.config/emby
cd ~/.config/emby

echo "Installing Service..."
mkdir -p ~/.config/systemd/user
echo "[Unit]
Description=Emby
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=$HOME/.apps/emby/opt/emby-server/bin/emby-server

[Install]
WantedBy=default.target" >> ~/.config/systemd/user/emby.service
systemctl --user daemon-reload
systemctl --user enable emby

loginctl enable-linger $USER

echo "Configuring Emby..."
systemctl --user start emby
sleep 5
systemctl --user stop emby
sed -i "s/8096/$port/g" ~/.config/emby/config/system.xml
sed -i "s/8920/$(($port + 2))/g" ~/.config/emby/config/system.xml
echo '<?xml version="1.0"?>
<EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <EncodingThreadCount>6</EncodingThreadCount>
  <ExtractionThreadCount>-1</ExtractionThreadCount>
  <TranscodingTempPath />
  <DownMixAudioBoost>2</DownMixAudioBoost>
  <EnableThrottling>false</EnableThrottling>
  <ThrottleBufferSize>120</ThrottleBufferSize>
  <ThrottleHysteresis>8</ThrottleHysteresis>
  <H264Crf>23</H264Crf>
  <H264Preset />
  <EnableHardwareEncoding>true</EnableHardwareEncoding>
  <EnableSubtitleExtraction>true</EnableSubtitleExtraction>
  <CodecConfigurations />
  <HardwareAccelerationMode>1</HardwareAccelerationMode>
  <HardwareDecodingCodecs>
    <string>h264</string>
    <string>vc1</string>
  </HardwareDecodingCodecs>
</EncodingOptions>' > ~/.config/emby/config/encoding.xml

echo "Starting Emby..."
systemctl --user start emby

echo "Downloading Uninstaller..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Emby/emby-uninstall.sh
chmod +x emby-uninstall.sh

echo "Cleaning Up..."
rm -- "$0"

printf "\033[0;32mDone!\033[0m\n"
echo "Access your Emby installation at https://$USER.$(hostname).usbx.me/emby"
echo "Run ./emby-uninstall.sh to uninstall"
