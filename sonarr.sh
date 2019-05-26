#!/bin/bash

app-sonarr stop
cp ~/.apps/sonarr/config.xml ~/.apps/sonarr/config.xml.bak
sed -i "s+<UrlBase></UrlBase>+<UrlBase>/sonarr</UrlBase>+g" ~/.apps/sonarr/config.xml
app-sonarr start
