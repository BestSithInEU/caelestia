#!/bin/bash

# Toggle special workspace script for Hyprland
# Usage: toggle-special-workspace.sh <workspace_name> <app_command>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <workspace_name> <app_command>"
    exit 1
fi

WORKSPACE_NAME="$1"
APP_COMMAND="$2"

# Check if the special workspace is currently visible
WORKSPACE_STATUS=$(hyprctl workspaces -j | jq -r ".[] | select(.name == \"special:$WORKSPACE_NAME\") | .windows")

if [ "$WORKSPACE_STATUS" = "0" ] || [ -z "$WORKSPACE_STATUS" ]; then
    # Workspace is empty or doesn't exist, launch the app
    hyprctl dispatch exec "[workspace special:$WORKSPACE_NAME silent] $APP_COMMAND"
else
    # Workspace exists and has windows, toggle its visibility
    CURRENT_SPECIAL=$(hyprctl activewindow -j | jq -r '.workspace.name')

    if [ "$CURRENT_SPECIAL" = "special:$WORKSPACE_NAME" ]; then
        # Currently on this special workspace, hide it
        hyprctl dispatch togglespecialworkspace "$WORKSPACE_NAME"
    else
        # Not on this special workspace, show it
        hyprctl dispatch togglespecialworkspace "$WORKSPACE_NAME"
    fi
fi
