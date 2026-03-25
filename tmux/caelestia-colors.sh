#!/bin/bash
# Reads caelestia scheme colors and sets tmux theme options
# Run: bash ~/.config/tmux/caelestia-colors.sh
# Or source from tmux.conf: run-shell "bash ~/.config/tmux/caelestia-colors.sh"

SCHEME_FILE="$HOME/.config/hypr/scheme/current.conf"

if [ ! -f "$SCHEME_FILE" ]; then
    exit 0
fi

get_color() {
    grep "^\\\$$1 = " "$SCHEME_FILE" | head -1 | sed 's/.*= //'
}

# Catppuccin-style variables (used by pane borders)
tmux set -gq "@thm_bg"          "#$(get_color base)"
tmux set -gq "@thm_fg"          "#$(get_color text)"
tmux set -gq "@thm_rosewater"   "#$(get_color rosewater)"
tmux set -gq "@thm_flamingo"    "#$(get_color flamingo)"
tmux set -gq "@thm_pink"        "#$(get_color pink)"
tmux set -gq "@thm_mauve"       "#$(get_color mauve)"
tmux set -gq "@thm_red"         "#$(get_color red)"
tmux set -gq "@thm_maroon"      "#$(get_color maroon)"
tmux set -gq "@thm_peach"       "#$(get_color peach)"
tmux set -gq "@thm_yellow"      "#$(get_color yellow)"
tmux set -gq "@thm_green"       "#$(get_color green)"
tmux set -gq "@thm_teal"        "#$(get_color teal)"
tmux set -gq "@thm_sky"         "#$(get_color sky)"
tmux set -gq "@thm_sapphire"    "#$(get_color sapphire)"
tmux set -gq "@thm_blue"        "#$(get_color blue)"
tmux set -gq "@thm_lavender"    "#$(get_color lavender)"
tmux set -gq "@thm_text"        "#$(get_color text)"
tmux set -gq "@thm_subtext_1"   "#$(get_color subtext1)"
tmux set -gq "@thm_subtext_0"   "#$(get_color subtext0)"
tmux set -gq "@thm_overlay_2"   "#$(get_color overlay2)"
tmux set -gq "@thm_overlay_1"   "#$(get_color overlay1)"
tmux set -gq "@thm_overlay_0"   "#$(get_color overlay0)"
tmux set -gq "@thm_surface_2"   "#$(get_color surfaceContainerHighest)"
tmux set -gq "@thm_surface_1"   "#$(get_color surfaceContainerHigh)"
tmux set -gq "@thm_surface_0"   "#$(get_color surfaceContainer)"
tmux set -gq "@thm_mantle"      "#$(get_color mantle)"
tmux set -gq "@thm_crust"       "#$(get_color crust)"

# Patch dracula scripts with caelestia overrides
CAELESTIA_DIR="$(dirname "$(readlink -f "$0")")"
DRACULA_DIR="$HOME/.tmux/plugins/tmux/scripts"
for script in weather.sh playerctl.sh; do
    if [ -f "$DRACULA_DIR/$script" ] && [ -f "$CAELESTIA_DIR/$script" ]; then
        cp "$CAELESTIA_DIR/$script" "$DRACULA_DIR/$script"
    fi
done

# Dracula color overrides — map caelestia → dracula named colors
tmux set -gq @dracula-colors "
white='#$(get_color text)'
gray='#$(get_color surfaceContainerHigh)'
dark_gray='#$(get_color base)'
light_purple='#$(get_color mauve)'
dark_purple='#$(get_color overlay1)'
cyan='#$(get_color sky)'
green='#$(get_color green)'
orange='#$(get_color peach)'
red='#$(get_color red)'
pink='#$(get_color pink)'
yellow='#$(get_color yellow)'
"
