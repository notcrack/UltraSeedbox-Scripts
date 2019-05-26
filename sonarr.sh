#!/bin/bash

app-sonarr stop
sed -i "s+<UrlBase></UrlBase>+<UrlBase>/sonarr</UrlBase>+g" ~/.apps/sonarr/config.xml
app-sonarr start
