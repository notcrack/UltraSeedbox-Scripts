#!/bin/bash

lock_file="$HOME/rclone.lock"

trap "rm -f $lock_file; exit 0" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "$base_name is already running."
    exit
else
    touch "$lock_file"
    "$HOME"/bin/rclone move /homexx/yyyyy/Stuff/Local/ gdrive: --drive-chunk-size 128M --tpslimit 10 --transfers 10 --checkers 10 --drive-acknowledge-abuse=true -vvv --delete-empty-src-dirs --fast-list --log-file "$HOME"/scripts/rclone-sync.log
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
