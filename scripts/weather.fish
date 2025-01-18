#!/bin/fish

set -q XDG_CACHE_HOME && set cache $XDG_CACHE_HOME || set cache ~/.cache
set cache $cache/caelestia/weather.txt

set format '\(.weatherDesc[0].value) • \(.temp_C)°C | UV \(.uvIndex) • 💨 \(.windspeedKmph)km/h'

set city (curl ipinfo.io | jq -r '.city')
set weather (curl "wttr.in/$city?format=j1" | jq -er '.current_condition[0] | "'$format'"' || cat $cache)

if test -n weather
    echo $weather > $cache
    echo $weather
end
