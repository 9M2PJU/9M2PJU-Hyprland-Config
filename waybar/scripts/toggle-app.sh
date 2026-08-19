#!/usr/bin/env bash
# Quick Toggle App Script for Waybar & Hyprland
# Usage: toggle-app.sh <app_class> <launch_cmd> [special_workspace_name]

set -euo pipefail

APP_CLASS="${1:-discord}"
LAUNCH_CMD="${2:-discord}"
WS_NAME="${3:-$APP_CLASS}"

# Check if app is running
client_info=$(hyprctl clients -j | jq -r --arg class "$APP_CLASS" '.[] | select(.class | test($class; "i")) | {address: .address, workspace: .workspace.name, focus: .focusHistoryID}')

if [[ -z "$client_info" ]]; then
    # Not running, launch it
    notify-send "Launching $APP_CLASS..." -t 2000
    eval "$LAUNCH_CMD" &
    exit 0
fi

addr=$(echo "$client_info" | jq -r '.address' | head -n 1)
current_active=$(hyprctl activewindow -j | jq -r '.address // empty')
current_ws=$(hyprctl activeworkspace -j | jq -r '.name')
client_ws=$(echo "$client_info" | jq -r '.workspace' | head -n 1)

if [[ "$addr" == "$current_active" ]]; then
    # Currently focused -> hide to special workspace (minimize)
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = 'special:$WS_NAME', silent = true }))"
elif [[ "$client_ws" == "special:$WS_NAME" ]]; then
    # In special workspace -> show it
    hyprctl eval "hl.dispatch(hl.dsp.workspace.toggle_special({ name = '$WS_NAME' }))"
else
    # On another workspace -> focus it or bring to current workspace
    hyprctl eval "hl.dispatch(hl.dsp.focus({ window = 'address:$addr' }))"
fi
