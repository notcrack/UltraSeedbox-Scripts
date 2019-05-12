#!/bin/bash
torrentid=$1
torrentname=$2
torrentpath=$3

x=1
while [ $x -le 100 ]
do
  sleep 2
  echo "Running $x times" >> ~/script.log
  echo "TorrentID: $torrentid" >> ~/script.log
  line=$(deluge-console "connect 127.0.0.1:daemon_port user pass; info" $1 | grep "Tracker status")
  echo $line >> ~/script.log
  case "$line" in
    *Error*|*Sent*|*End*of*file*|*Bad*Gateway*)
      deluge-console "connect 127.0.0.1:daemon_port user pass; pause '$torrentid'"
      sleep 5
      deluge-console "connect 127.0.0.1:daemon_port user pass; resume '$torrentid'"
      ;;
    *)
      echo "Found working torrent: $torrentname $torrentpath $torrentid" >> ~/script.log
      exit 1;;
  esac
  x=$(( $x + 1 ))
done