#!/usr/bin/env bash
# Patched playerctl.sh — only shows currently playing tracks (hides paused/stopped)
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

function slice_loop() {
  local str="$1"
  local start="$2"
  local how_many="$3"
  local len=${#str}

  local result=""

  for ((i = 0; i < how_many; i++)); do
    local index=$(((start + i) % len))
    local char="${str:index:1}"
    result="$result$char"
  done

  echo "$result"
}

main() {
  RATE=$(get_tmux_option "@dracula-refresh-rate" 5)

  if ! command -v playerctl &>/dev/null; then
    exit 1
  fi

  # Only show when actively playing
  status=$(playerctl status 2>/dev/null)
  if [[ "$status" != "Playing" ]]; then
    exit
  fi

  FORMAT=$(get_tmux_option "@dracula-playerctl-format" "Now playing: {{ artist }} - {{ album }} - {{ title }}")
  playerctl_playback=$(playerctl metadata --format "${FORMAT}")
  playerctl_playback="${playerctl_playback} "

  terminal_width=25
  start=0
  len=${#playerctl_playback}

  if [[ $len == 1 ]]; then
    exit
  fi

  scrolling_text=""

  for ((start = 0; start <= len; start++)); do
    scrolling_text=$(slice_loop "$playerctl_playback" "$start" "$terminal_width")
    echo -ne "\r"
    echo "$scrolling_text "
    echo -ne "\r"

    sleep 0.08
  done

  echo -ne "\r"
  echo "$scrolling_text "
  echo -ne "\r"
}

main
