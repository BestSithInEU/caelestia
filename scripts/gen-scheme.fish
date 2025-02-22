#!/bin/fish

function read-scheme -a scheme_path
    cat $scheme_path | while read line
        set -l colour (string split ' ' $line)
        echo "\$$colour[1] = $colour[2]"
    end
end

set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
set -l scheme_path $state/caelestia/scheme/current.txt

if test -f $scheme_path
    read-scheme $scheme_path > ~/.config/hypr/scheme/current.conf
else
    cp -f ~/.config/hypr/scheme/default.conf ~/.config/hypr/scheme/current.conf
end
