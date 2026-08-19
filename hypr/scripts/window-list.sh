#!/usr/bin/env bash
# =============================================================================
# Tokyo Night Interactive Window Selector for Hyprland (bemenu)
# =============================================================================

# Fetch active clients from Hyprland
clients=$(hyprctl clients -j 2>/dev/null | jq -r '
    .[] | select(.mapped == true and .hidden == false) | 
    "\(.address)\t[WS \(.workspace.id)] \(.class) — \(.title)"
')

if [ -z "$clients" ]; then
    notify-send -t 1500 "Window Switcher" "No active windows found"
    exit 0
fi

# Display formatted window list in bemenu
selected=$(echo -e "$clients" | awk -F'\t' '{printf "%-50s\t%s\n", $2, $1}' | bemenu -i -l 12 \
    -p "  Switch Window " \
    --fn "CaskaydiaCove Nerd Font 11" \
    --tb "#1a1b26" --tf "#7aa2f7" \
    --fb "#1a1b26" --ff "#c0caf5" \
    --nb "#1a1b26" --nf "#c0caf5" \
    --hb "#292e42" --hf "#7aa2f7" \
    --sb "#292e42" --sf "#7aa2f7" \
    --border 2 \
    --border-radius 8 \
    --margin 12 \
    --width-factor 0.55)

if [ -n "$selected" ]; then
    addr=$(echo "$selected" | awk -F'\t' '{print $2}')
    if [ -n "$addr" ]; then
        hyprctl dispatch focuswindow "address:$addr"
    fi
fi
