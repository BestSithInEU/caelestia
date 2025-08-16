#!/bin/bash

set -euo pipefail

declare -A timeout_tracker
declare -A window_rules

init_window_rules() {
    window_rules=(
        ["Write: (no subject)"]="initial_title:50%:54%:float:center"
        ["(Bitwarden"]="title_contains:20%:54%:float:center"
        ["Sign in - Google Accounts"]="title_contains:35%:65%:float:center"
        ["Compose - Gmail"]="title_contains:60%:70%:float:center"
        ["Authorize Discord"]="title_contains:25%:50%:float:center"
        ["GitHub"]="title_contains:30%:55%:float:center"
        # ["Epic Games"]="title_contains:35%:65%:float:center"
        ["steampowered.com"]="title_contains:35%:60%:float:center"
        ["oauth"]="title_contains:30%:60%:float:center"
    )
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

is_rate_limited() {
    local key="$1"
    local current_time=$SECONDS
    local last_time=${timeout_tracker[$key]:-0}

    if ((current_time < last_time + 1)); then
        return 0
    fi

    timeout_tracker[$key]=$current_time
    return 1
}

apply_window_actions() {
    local window_id="$1"
    local width="$2"
    local height="$3"
    local actions="$4"

    local dispatch_commands=""

    if [[ "$actions" == *"float"* ]]; then
        local window_info
        window_info=$(hyprctl clients -j | jq --arg id "0x$window_id" '.[] | select(.address == ($id))')
        local is_floating
        is_floating=$(echo "$window_info" | jq -r '.floating // false')

        if [[ "$is_floating" != "true" ]]; then
            dispatch_commands+="dispatch togglefloating address:0x$window_id; "
        fi
    fi

    dispatch_commands+="dispatch resizewindowpixel exact $width $height,address:0x$window_id; "

    if [[ "$actions" == *"center"* ]]; then
        dispatch_commands+="dispatch centerwindow; "
    fi

    if ! hyprctl --batch "$dispatch_commands"; then
        log_message "ERROR: Failed to apply window actions for window 0x$window_id"
        return 1
    fi

    log_message "Applied actions to window 0x$window_id: $width x $height ($actions)"
}

match_window_rule() {
    local window_title="$1"
    local initial_title="$2"

    for rule_name in "${!window_rules[@]}"; do
        local rule_config="${window_rules[$rule_name]}"
        IFS=':' read -ra rule_parts <<< "$rule_config"

        local match_type="${rule_parts[0]}"
        local width="${rule_parts[1]}"
        local height="${rule_parts[2]}"
        local actions="${rule_parts[3]}:${rule_parts[4]}"

        case "$match_type" in
            "initial_title")
                if [[ "$initial_title" == "$rule_name" ]]; then
                    echo "$rule_name:$width:$height:$actions"
                    return 0
                fi
                ;;
            "title_contains")
                local pattern="${rule_name}"
                if [[ "$window_title" == *"$pattern"* ]]; then
                    echo "$rule_name:$width:$height:$actions"
                    return 0
                fi
                ;;
            "title_exact")
                if [[ "$window_title" == "$rule_name" ]]; then
                    echo "$rule_name:$width:$height:$actions"
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

handle_window_event() {
    local event="$1"

    case "$event" in
        windowtitle*)
            local window_id="${event#*>>}"
            window_id="${window_id%%,*}"

            if [[ ! "$window_id" =~ ^[0-9a-fA-F]+$ ]]; then
                log_message "ERROR: Invalid window ID format: $window_id"
                return 1
            fi

            local window_info
            if ! window_info=$(hyprctl clients -j | jq --arg id "0x$window_id" '.[] | select(.address == ($id))' 2>/dev/null); then
                log_message "ERROR: Failed to get window info for 0x$window_id"
                return 1
            fi

            if [[ "$window_info" == "null" || -z "$window_info" ]]; then
                return 0
            fi

            local window_title initial_title
            window_title=$(echo "$window_info" | jq -r '.title // ""')
            initial_title=$(echo "$window_info" | jq -r '.initialTitle // ""')

            log_message "DEBUG: Window 0x$window_id - Title: '$window_title' | Initial: '$initial_title'"

            local match_result
            if match_result=$(match_window_rule "$window_title" "$initial_title"); then
                IFS=':' read -ra match_parts <<< "$match_result"
                local rule_name="${match_parts[0]}"
                local width="${match_parts[1]}"
                local height="${match_parts[2]}"
                local actions="${match_parts[3]}:${match_parts[4]}"

                if is_rate_limited "$window_id"; then
                    log_message "Rate limited: skipping window 0x$window_id"
                    return 0
                fi

                log_message "Matched rule '$rule_name' for window 0x$window_id"
                apply_window_actions "$window_id" "$width" "$height" "$actions"
            fi
            ;;
    esac
}

main() {
    init_window_rules
    log_message "Hyprland window resize script started"
    log_message "Loaded ${#window_rules[@]} window rules"

    if [[ -z "${XDG_RUNTIME_DIR:-}" || -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        log_message "ERROR: Required environment variables not set"
        exit 1
    fi

    local socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    if [[ ! -S "$socket_path" ]]; then
        log_message "ERROR: Hyprland socket not found at $socket_path"
        exit 1
    fi

    socat -U - "UNIX-CONNECT:$socket_path" | while read -r line; do
        handle_window_event "$line"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
