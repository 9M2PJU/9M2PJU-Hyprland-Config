#!/usr/bin/env bash
# Hyprland Screenshot Helper
# Usage: screenshot.sh [full|window|area]

set -euo pipefail

MODE="${1:-full}"
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILENAME="$SAVE_DIR/screenshot_$(date +'%Y%m%d_%H%M%S').png"

case "$MODE" in
    full)
        grim "$FILENAME"
        wl-copy < "$FILENAME"
        notify-send -t 3000 "Screenshot Captured" "Full screen saved and copied to clipboard"
        ;;
    window)
        # Query active window geometry from hyprctl
        geom=$(hyprctl activewindow -j | jq -r 'if .at == null or .size == null then empty else "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" end')
        if [[ -z "$geom" ]]; then
            notify-send -u low "Screenshot" "No active window found"
            exit 1
        fi
        grim -g "$geom" "$FILENAME"
        wl-copy < "$FILENAME"
        notify-send -t 3000 "Screenshot Captured" "Active window saved and copied to clipboard"
        ;;
    area)
        # Use slurp to select area
        geom=$(slurp)
        if [[ -n "$geom" ]]; then
            grim -g "$geom" "$FILENAME"
            wl-copy < "$FILENAME"
            notify-send -t 3000 "Screenshot Captured" "Selected area saved and copied to clipboard"
        fi
        ;;
    *)
        echo "Usage: $0 {full|window|area}"
        exit 1
        ;;
esac
