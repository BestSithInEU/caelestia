#!/bin/fish

function fmt-time -a secs
    printf "%d:%02d" (math -s 0 $secs / 60 % 60) (math -s 0 $secs % 60)
end

set -l position (caelestia shell media position)
set -l length (caelestia shell media length)

echo "$(fmt-time $position)/$(fmt-time $length)"
