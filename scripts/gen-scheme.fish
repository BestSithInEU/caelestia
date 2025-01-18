#!/bin/fish

set -q XDG_CACHE_HOME && set cache $XDG_CACHE_HOME/caelestia || set cache ~/.cache/caelestia
set scheme_path $cache/scheme/current.txt
set lock_file $cache/locks/hypr-gen-scheme.lock
set hypr ~/.config/hypr

set default mocha
set program $argv[1]

function update-scheme -a scheme
    cp $hypr/scheme/$program/$scheme.conf $hypr/$program/scheme.conf
end

if test -f $scheme_path
    if test -f $lock_file
        set -l scheme (cat $scheme_path)
        test -f $hypr/scheme/$program/$scheme.conf && update-scheme $scheme || update-scheme $default
    else
        # Lock so only 1 monitor
        mkdir -p (dirname $lock_file)
        touch $lock_file
        trap "rm $lock_file" SIGINT

        # Monitor file for changes
        tail -f $scheme_path | while read line
            test -f $hypr/scheme/$program/$line.conf && update-scheme $line
        end
    end
else
    update-scheme $default
end
