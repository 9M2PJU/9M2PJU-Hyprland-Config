#!/usr/bin/env bash
# Hyprland Screenshot Helper with Visual Window/Region Picker
# Usage: screenshot.sh [full|window|active_window|area]

set -euo pipefail

MODE="${1:-full}"
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

case "$MODE" in
    full)
        hyprshot -m output -o "$SAVE_DIR" -t 3000
        ;;
    window)
        # Interactive window picker: dims screen and highlights windows on hover
        hyprshot -m window -o "$SAVE_DIR" -t 3000
        ;;
    active_window)
        # Direct capture of active focused window
        hyprshot -m window -m active -o "$SAVE_DIR" -t 3000
        ;;
    area)
        # Interactive region crop
        hyprshot -m region -o "$SAVE_DIR" -t 3000
        ;;
    *)
        echo "Usage: $0 {full|window|active_window|area}"
        exit 1
        ;;
esac
