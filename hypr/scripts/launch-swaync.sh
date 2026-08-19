#!/usr/bin/env bash
# =============================================================================
# SwayNC Startup & Monitor Routing Script
# =============================================================================
pkill -x swaync 2>/dev/null || true
sleep 0.3
swaync &
sleep 0.5

# Detect primary monitor (External HDMI-A-2 first, fallback to internal eDP-1)
if hyprctl monitors -j 2>/dev/null | grep -q "HDMI-A-2"; then
    TARGET="HDMI-A-2"
else
    TARGET="eDP-1"
fi

swaync-client --change-noti-monitor "$TARGET" >/dev/null 2>&1 || true
swaync-client --change-cc-monitor "$TARGET" >/dev/null 2>&1 || true
