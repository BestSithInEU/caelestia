#!/bin/fish

set -q XDG_CACHE_HOME && set cache $XDG_CACHE_HOME || set cache ~/.cache
set scheme_path $cache/caelestia/scheme/current.txt

set scheme mocha
if test -f $scheme_path
    set -l current_scheme (cat $scheme_path)
    test -f ~/.config/hypr/schemes/$current_scheme.conf && set scheme $current_scheme
end
echo "source = ~/.config/hypr/schemes/$scheme.conf" > ~/.config/hypr/schemes/current.conf
