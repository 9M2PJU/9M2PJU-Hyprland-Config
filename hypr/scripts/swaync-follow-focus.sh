#!/usr/bin/env bash
# =============================================================================
# SwayNC Active Monitor Follower for Hyprland
# Dynamically routes notifications and Control Center to the currently focused monitor
# =============================================================================

HYPR_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# Wait for Hyprland IPC socket
while [ ! -S "$HYPR_SOCK" ]; do
    sleep 0.5
done

# Wait for SwayNC daemon to respond
for i in {1..20}; do
    if swaync-client -c >/dev/null 2>&1; then
        break
    fi
    sleep 0.3
done

# Set initial monitor based on current focus
LAST_MON=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name')
if [ -n "$LAST_MON" ] && [ "$LAST_MON" != "null" ]; then
    swaync-client --change-noti-monitor "$LAST_MON" >/dev/null 2>&1 || true
    swaync-client --change-cc-monitor "$LAST_MON" >/dev/null 2>&1 || true
fi

# Listen for monitor focus switch events
while true; do
    socat -u UNIX-CONNECT:"$HYPR_SOCK" - 2>/dev/null | while IFS= read -r event; do
        case "$event" in
            focusedmon\>\>*)
                mon="${event#focusedmon>>}"
                mon="${mon%%,*}"
                if [ -n "$mon" ] && [ "$mon" != "$LAST_MON" ]; then
                    swaync-client --change-noti-monitor "$mon" >/dev/null 2>&1 || true
                    swaync-client --change-cc-monitor "$mon" >/dev/null 2>&1 || true
                    LAST_MON="$mon"
                fi
                ;;
        esac
    done
    sleep 1
done
