#!/usr/bin/env bash
# Hyprland Visual Window Switcher via Wofi
# Lists all open windows across all workspaces and monitors

set -euo pipefail

# Get active windows formatted as: "address | [Workspace] Class: Title"
windows=$(hyprctl clients -j | jq -r '.[] | select(.mapped == true and .title != "") | "\(.address)\t[\(.workspace.name)] \(.class): \(.title)"')

if [[ -z "$windows" ]]; then
    exit 0
fi

# Show searchable list via wofi dmenu
selected=$(echo "$windows" | awk -F'\t' '{print $2}' | wofi --dmenu --prompt "Switch Window" --width 650 --height 350 --insensitive || true)

if [[ -n "$selected" ]]; then
    # Find matching address
    addr=$(echo "$windows" | grep -F "$selected" | head -n 1 | awk -F'\t' '{print $1}')
    if [[ -n "$addr" ]]; then
        hyprctl eval "hl.dispatch(hl.dsp.focus({ window = 'address:$addr' }))"
    fi
fi
