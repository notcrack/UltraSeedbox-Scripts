#!/bin/bash

home_dir="/homexx/yyyyy"
lock_file="$home_dir/rclone.lock"

trap "rm -f $lock_file; exit 0" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "$base_name is already running."
    exit
else
    touch "$lock_file"
    "$home_dir"/bin/rclone move /homexx/yyyyy/Stuff/Local/ gdrive: --drive-chunk-size 128M --tpslimit 10 --transfers 40 --checkers 40 --max-backlog 200000 --drive-acknowledge-abuse=true -vvv --delete-empty-src-dirs --fast-list --log-file "$home_dir"/scripts/rclone-sync.log
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
