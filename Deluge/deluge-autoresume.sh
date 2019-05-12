#!/bin/bash
torrentid=$1
torrentname=$2
torrentpath=$3

#change all information here to reflect slot specifics
ip=xyz.xyz.xyz.xyz
port=zzzzz
username=xxxx
password=yyyy

x=1
while [ $x -le 100 ]
do
  sleep 2
  echo "Running $x times" >> ~/script.log
  echo "TorrentID: $torrentid" >> ~/script.log
  line=$(deluge-console "connect '$ip':'$port' '$username' '$password'; info" $1 | grep "Tracker status")
  echo $line >> ~/script.log
  case "$line" in
    *Error*|*Sent*|*End*of*file*|*Bad*Gateway*)
      deluge-console "connect '$ip':'$port' '$username' '$password'; pause '$torrentid'"
      sleep 5
      deluge-console "connect '$ip':'$port' '$username' '$password'; resume '$torrentid'"
      ;;
    *)
      echo "Found working torrent: $torrentname $torrentpath $torrentid" >> ~/script.log
      exit 1;;
  esac
  x=$(( $x + 1 ))
done