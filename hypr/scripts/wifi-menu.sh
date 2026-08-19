#!/usr/bin/env bash
# =============================================================================
# Tokyo Night WiFi Menu for Hyprland / Waybar using bemenu & nmcli
# =============================================================================

# Check WiFi Status
wifi_status=$(nmcli -fields WIFI g 2>/dev/null)

if [[ "$wifi_status" =~ "disabled" ]]; then
    toggle_opt="󰤮  Enable Wi-Fi"
else
    toggle_opt="󰤮  Disable Wi-Fi"
fi

# Quick rescan
nmcli dev wifi rescan 2>/dev/null || true

# Format WiFi list: signal icon, SSID, security, signal %
raw_list=$(nmcli --colors no -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list | awk -F: '
$2 != "" && $2 != "--" {
    in_use = ($1 == "*") ? " " : "   ";
    ssid = $2;
    signal = $3;
    sec = ($4 == "") ? "Open" : $4;
    
    if (signal > 75) icon = "󰤨 ";
    else if (signal > 50) icon = "󰤥 ";
    else if (signal > 25) icon = "󰤢 ";
    else icon = "󰤟 ";
    
    printf "%s%s %-25s [%s%% | %s]\n", in_use, icon, ssid, signal, sec;
}' | sort -u -k2,2)

options="$toggle_opt\n󰑐  Rescan Networks\n󰢻  Network Settings (GUI)\n----------------------------------------\n$raw_list"

chosen=$(echo -e "$options" | bemenu -i -l 14 \
    -p "   Wi-Fi Networks " \
    --fn "CaskaydiaCove Nerd Font 11" \
    --tb "#1a1b26" --tf "#7aa2f7" \
    --fb "#1a1b26" --ff "#c0caf5" \
    --nb "#1a1b26" --nf "#c0caf5" \
    --hb "#292e42" --hf "#7aa2f7" \
    --sb "#292e42" --sf "#7aa2f7" \
    --border 2 \
    --border-radius 8 \
    --margin 12 \
    --width-factor 0.45)

if [ -z "$chosen" ]; then
    exit 0
fi

if [[ "$chosen" == *"Enable Wi-Fi"* ]]; then
    nmcli r wifi on
    notify-send "Wi-Fi" "Wi-Fi enabled"
elif [[ "$chosen" == *"Disable Wi-Fi"* ]]; then
    nmcli r wifi off
    notify-send "Wi-Fi" "Wi-Fi disabled"
elif [[ "$chosen" == *"Rescan Networks"* ]]; then
    exec "$0"
elif [[ "$chosen" == *"Network Settings"* ]]; then
    nm-connection-editor &
elif [[ "$chosen" == *"---"* ]]; then
    exit 0
else
    # Extract SSID
    chosen_ssid=$(echo "$chosen" | sed -E 's/^[ * ]*[󰤨󰤥󰤢󰤟] *//; s/ *\[.*//')
    
    # Check if already connected
    if [[ "$chosen" == *""* ]]; then
        notify-send "Wi-Fi" "Already connected to $chosen_ssid"
        exit 0
    fi
    
    # Check if connection already exists in NetworkManager
    if nmcli -g NAME connection show | grep -Fxq "$chosen_ssid"; then
        notify-send "Wi-Fi" "Connecting to saved network: $chosen_ssid..."
        if nmcli connection up id "$chosen_ssid"; then
            notify-send "Wi-Fi" "Successfully connected to $chosen_ssid"
        else
            notify-send -u critical "Wi-Fi" "Failed to connect to $chosen_ssid"
        fi
    else
        # If password required
        if [[ "$chosen" =~ "WPA" ]] || [[ "$chosen" =~ "WEP" ]]; then
            wifi_pass=$(echo "" | bemenu -p "   Enter Password for $chosen_ssid: " \
                --fn "CaskaydiaCove Nerd Font 11" \
                --tb "#1a1b26" --tf "#7aa2f7" \
                --fb "#1a1b26" --ff "#c0caf5" \
                --nb "#1a1b26" --nf "#c0caf5" \
                --hb "#292e42" --hf "#7aa2f7" \
                --sb "#292e42" --sf "#7aa2f7" \
                --border 2 \
                --border-radius 8 \
                --margin 12 \
                --width-factor 0.45)
            
            if [ -n "$wifi_pass" ]; then
                notify-send "Wi-Fi" "Connecting to $chosen_ssid..."
                if nmcli dev wifi connect "$chosen_ssid" password "$wifi_pass"; then
                    notify-send "Wi-Fi" "Connected to $chosen_ssid"
                else
                    notify-send -u critical "Wi-Fi" "Connection failed. Check password."
                fi
            fi
        else
            notify-send "Wi-Fi" "Connecting to open network: $chosen_ssid..."
            if nmcli dev wifi connect "$chosen_ssid"; then
                notify-send "Wi-Fi" "Connected to $chosen_ssid"
            else
                notify-send -u critical "Wi-Fi" "Failed to connect."
            fi
        fi
    fi
fi
