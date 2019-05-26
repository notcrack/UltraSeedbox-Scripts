#!/bin/bash

app-radarr stop
cp ~/.apps/radarr/config.xml ~/.apps/radarr/config.xml.bak
sed -i "s+<UrlBase></UrlBase>+<UrlBase>/radarr</UrlBase>+g" ~/.apps/radarr/config.xml
app-radarr start
