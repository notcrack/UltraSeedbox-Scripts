[Unit]
Description=RClone Service
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
Environment=RCLONE_CONFIG=/home6/kbguides/.config/rclone/rclone.conf

ExecStart=/home6/kbguides/bin/rclone mount gdrive: /home6/kbguides/Mount \
  --allow-other \
  --buffer-size 256M \
  --fast-list \
  --drive-chunk-size 128M \
  --dir-cache-time 96h \
  --log-level INFO \
  --log-file /home6/kbguides/scripts/rclone.log \
  --timeout 1h \
  --umask 002 \
  --vfs-cache-mode writes
ExecStop=/bin/fusermount -uz /homexx/yyyyy/Mount
Restart=on-failure
  
  [Install]
  WantedBy=default.target
