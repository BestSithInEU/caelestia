#!/bin/fish

set -q XDG_CACHE_HOME && set cache $XDG_CACHE_HOME || set cache ~/.cache
set scheme_path $cache/caelestia/scheme/current.txt

set scheme mocha
if test -f $scheme_path
    set -l current_scheme (cat $scheme_path)
    test -f ~/.config/hypr/scheme/$current_scheme.conf && set scheme $current_scheme
end
echo "source = ~/.config/hypr/scheme/$scheme.conf" > ~/.config/hypr/scheme/current.conf
