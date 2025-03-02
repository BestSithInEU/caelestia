#!/bin/fish

set -l src (dirname (status filename))

cp $src/templates/hyprlock-base.conf $src/../hyprlock.conf

for monitor in (hyprctl monitors -j | jq -r '.[] | "\(.name) \(.width) \(.height)"')
    set -l monitor (string split ' ' $monitor)
    set -l name $monitor[1]
    set -l width $monitor[2]
    set -l height $monitor[3]

    set -l tmp (mktemp)
    cp $src/templates/hyprlock-monitor.conf $tmp
    sed -n 's/.*{{ \(.*\) }}.*/\1/p' $src/templates/hyprlock-monitor.conf | while read expr
        sed -i "s|{{ $expr }}|$(echo "echo $expr" | .)|g" $tmp
    end
    cat $tmp >> $src/../hyprlock.conf
end
