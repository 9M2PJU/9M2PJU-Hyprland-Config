#!/usr/bin/env bash
# Tailscale Waybar Module

case "$1" in
    copy)
        ip=$(tailscale ip -4 2>/dev/null | head -n1)
        if [[ -n "$ip" ]]; then
            echo -n "$ip" | wl-copy
            notify-send "Tailscale" "IP $ip copied to clipboard" -i network-vpn
        fi
        ;;
    toggle)
        state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState // empty')
        if [[ "$state" == "Running" ]]; then
            pkexec tailscale down
            notify-send "Tailscale" "Disconnected" -i network-vpn
        else
            pkexec tailscale up
            notify-send "Tailscale" "Connecting..." -i network-vpn
        fi
        pkill -RTMIN+9 waybar 2>/dev/null || true
        ;;
    status|*)
        data=$(tailscale status --json 2>/dev/null)
        state=$(echo "$data" | jq -r '.BackendState // "Stopped"')
        if [[ "$state" == "Running" ]]; then
            ip=$(echo "$data" | jq -r '.Self.TailscaleIPs[0] // "Unknown"')
            printf '{"text":"󰖂 %s","tooltip":"Tailscale Connected\nIP: %s\nLeft-click: Copy IP\nRight-click: Toggle","class":"connected"}\n' "$ip" "$ip"
        elif [[ "$state" == "NeedsLogin" ]]; then
            printf '{"text":"󰖂 Login","tooltip":"Tailscale Needs Login","class":"needs-login"}\n'
        else
            printf '{"text":"󰖂 Off","tooltip":"Tailscale Disconnected\nLeft-click: Connect","class":"disconnected"}\n'
        fi
        ;;
esac
