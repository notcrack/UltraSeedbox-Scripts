#!/bin/bash

title=$1
downloadUrl=$2
apiKey=$3
date=$(date -u +"%Y-%m-%d %H:%M:%SZ")

{
$(which curl) -i -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Api-Key: $apiKey" -X POST -d '{"title":"'"$title"'","downloadUrl":"'"$downloadUrl"'","Protocol":"torrent","publishDate":"'"$date"'"}' http://lwxxx.usbx.me:xxxxx/api/v1/release/push
} &> /dev/null
