#!/usr/bin/env bash
# =============================================================================
# SwayNC Startup & Dynamic Monitor Routing Script
# =============================================================================
pkill -x swaync 2>/dev/null || true
pkill -f "swaync-follow-focus.sh" 2>/dev/null || true
sleep 0.2

# Start SwayNC daemon in background
swaync &

# Start dynamic active-monitor follower daemon
~/.config/hypr/scripts/swaync-follow-focus.sh &
