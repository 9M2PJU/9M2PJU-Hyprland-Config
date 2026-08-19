#!/usr/bin/env bash
set -e

CONFIG_FILE="$HOME/.config/waybar/config.jsonc"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-$(ls $XDG_RUNTIME_DIR/wayland-* 2>/dev/null | grep -v '\.lock' | head -n 1 | xargs -r basename)}"
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$(ls -t $XDG_RUNTIME_DIR/hypr/ 2>/dev/null | head -n 1)"
fi
export XDG_CURRENT_DESKTOP="Hyprland"

get_target_monitor() {
    monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo "")
    ext_mon=$(echo "$monitors" | grep -E -v '^eDP-1$' | head -n 1)
    
    if [ -n "$ext_mon" ]; then
        echo "$ext_mon"
    else
        echo "eDP-1"
    fi
}

update_and_run_waybar() {
    target=$(get_target_monitor)
    sed -i -E "s/\"output\": \[[^]]*\]/\"output\": [\"$target\"]/g" "$CONFIG_FILE"
    killall -9 waybar 2>/dev/null || true
    sleep 0.3
    hyprctl dispatch "hl.dsp.exec_cmd('waybar')" >/dev/null 2>&1 || (nohup waybar >/dev/null 2>&1 & disown)
}

# Initial startup
update_and_run_waybar

# Listen for Hyprland monitor events
SOCKET="$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

if [ -S "$SOCKET" ]; then
    socat -U - UNIX-CONNECT:"$SOCKET" 2>/dev/null | while read -r line; do
        case "$line" in
            monitoradded*|monitorremoved*)
                sleep 1
                update_and_run_waybar
                ;;
        esac
    done
fi

