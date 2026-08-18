#!/usr/bin/env bash
# External Monitor Brightness Controller via DDC/CI (Waybar module)

CACHE_FILE="/tmp/waybar_ext_brightness"
LOCK_FILE="/tmp/waybar_ext_brightness.lock"
STEP=5

get_current() {
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        val=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
        if [[ -z "$val" || ! "$val" =~ ^[0-9]+$ ]]; then
            val=100
        fi
        echo "$val" > "$CACHE_FILE"
        echo "$val"
    fi
}

set_brightness() {
    local target=$1
    echo "$target" > "$CACHE_FILE"
    # Execute ddcutil in background to avoid blocking Waybar UI responsiveness
    (
        flock -x 200
        ddcutil setvcp 10 "$target" --brief >/dev/null 2>&1
    ) 200>"$LOCK_FILE" &
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

case "$1" in
    up)
        current=$(get_current)
        new_val=$((current + STEP))
        if (( new_val > 100 )); then new_val=100; fi
        set_brightness "$new_val"
        ;;
    down)
        current=$(get_current)
        new_val=$((current - STEP))
        if (( new_val < 5 )); then new_val=5; fi
        set_brightness "$new_val"
        ;;
    set)
        new_val=${2:-100}
        if (( new_val > 100 )); then new_val=100; fi
        if (( new_val < 5 )); then new_val=5; fi
        set_brightness "$new_val"
        ;;
    get|*)
        val=$(get_current)
        printf '{"text":"%d%% 󰍹","tooltip":"External Monitor (HDMI): %d%%","percentage":%d,"class":"backlight-ext"}\n' "$val" "$val" "$val"
        ;;
esac
