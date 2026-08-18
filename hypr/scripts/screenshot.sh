#!/usr/bin/env bash
# Hyprland Screenshot Tool (grim + slurp)
# Saves image to ~/Pictures/Screenshots and copies to clipboard with notification preview
# Usage: screenshot.sh [area|full|window]

set -euo pipefail

MODE="${1:-area}"
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILENAME="$SAVE_DIR/screenshot_$(date +'%Y%m%d_%H%M%S').png"

case "$MODE" in
    area)
        # Capture selected region with slurp (exits cleanly if cancelled with Esc)
        GEOM=$(slurp 2>/dev/null) || exit 0
        if [[ -n "${GEOM:-}" ]]; then
            grim -g "$GEOM" "$FILENAME"
            wl-copy < "$FILENAME"
            notify-send -t 3000 -i "$FILENAME" "Screenshot Saved" "Area saved to Screenshots & copied to clipboard"
        fi
        ;;
    full)
        grim "$FILENAME"
        wl-copy < "$FILENAME"
        notify-send -t 3000 -i "$FILENAME" "Screenshot Saved" "Full screen saved to Screenshots & copied to clipboard"
        ;;
    window)
        GEOM=$(hyprctl activewindow -j | jq -r 'if .at == null or .size == null then empty else "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])" end')
        if [[ -z "${GEOM:-}" ]]; then
            notify-send -u low "Screenshot" "No active window found"
            exit 1
        fi
        grim -g "$GEOM" "$FILENAME"
        wl-copy < "$FILENAME"
        notify-send -t 3000 -i "$FILENAME" "Screenshot Saved" "Active window saved & copied to clipboard"
        ;;
    *)
        echo "Usage: $0 {area|full|window}"
        exit 1
        ;;
esac
