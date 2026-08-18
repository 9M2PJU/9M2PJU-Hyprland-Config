#!/usr/bin/env bash
# Instant Window Switcher (Next) - No Enter, No Popup
# Switches focus immediately across all monitors and workspaces

set -euo pipefail

active=$(hyprctl activewindow -j | jq -r '.address // empty')
mapfile -t clients < <(hyprctl clients -j | jq -r '.[] | select(.mapped == true and .title != "") | .address')
num=${#clients[@]}

if [[ $num -le 1 ]]; then
    exit 0
fi

for i in "${!clients[@]}"; do
    if [[ "${clients[$i]}" == "$active" ]]; then
        next_index=$(( (i + 1) % num ))
        hyprctl dispatch focuswindow "address:${clients[$next_index]}"
        exit 0
    fi
done

hyprctl dispatch focuswindow "address:${clients[0]}"
