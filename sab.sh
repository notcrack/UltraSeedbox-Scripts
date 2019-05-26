#!/bin/bash

app-sabnzbd stop
cp ~/.sabnzbd/sabnzbd.ini ~/.sabnzbd/sabnzbd.ini.bank
sed -i "s/host_whitelist =/host_whitelist = $HOSTNAME.usbx.me,/g" ~/.sabnzbd/sabnzbd.ini
app-sabnzbd start
