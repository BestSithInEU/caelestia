#!/bin/fish

set -q XDG_CACHE_HOME && set cache $XDG_CACHE_HOME || set cache ~/.cache
set scheme_path $cache/caelestia/scheme/current.txt
set schemes ~/.config/hypr/scheme

inotifywait -e 'close_write,moved_to,create' -m (dirname $scheme_path) | while read dir events file
    test "$dir$file" = $scheme_path && hyprctl reload
end
