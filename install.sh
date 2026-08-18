#!/usr/bin/env bash
# 9M2PJU Hyprland Configuration Installer
# Target: Lenovo ThinkPad T460 / CachyOS / Arch Linux

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/hyprland_backup_$(date +%Y%m%d_%H%M%S)"

echo "=== 9M2PJU Hyprland Configuration Setup ==="

# 1. Backup existing configs if they exist
mkdir -p "$BACKUP_DIR"
for cfg in hypr waybar wlogout; do
    if [[ -d "$HOME/.config/$cfg" ]]; then
        echo "[+] Backing up ~/.config/$cfg to $BACKUP_DIR/"
        cp -r "$HOME/.config/$cfg" "$BACKUP_DIR/"
    fi
done

# 2. Deploy configs
mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar/scripts" "$HOME/.config/wlogout"

echo "[+] Installing Hyprland configuration (hyprland.lua, hyprland.conf, hypridle, hyprlock)..."
cp -r "$DOTFILES_DIR/hypr/"* "$HOME/.config/hypr/"

echo "[+] Installing Waybar configuration & scripts..."
cp -r "$DOTFILES_DIR/waybar/"* "$HOME/.config/waybar/"
chmod +x "$HOME/.config/waybar/scripts/"*.sh

echo "[+] Installing wlogout layout..."
cp -r "$DOTFILES_DIR/wlogout/"* "$HOME/.config/wlogout/"

# 3. SDDM Numlock setup (optional sudo)
if [[ -f "$DOTFILES_DIR/sddm/10-numlock.conf" ]]; then
    if sudo -n true 2>/dev/null; then
        echo "[+] Installing SDDM Numlock configuration..."
        sudo mkdir -p /etc/sddm.conf.d
        sudo cp "$DOTFILES_DIR/sddm/10-numlock.conf" /etc/sddm.conf.d/
    else
        echo "[!] To enable Numlock in SDDM login screen, run:"
        echo "    sudo cp $DOTFILES_DIR/sddm/10-numlock.conf /etc/sddm.conf.d/"
    fi
fi

echo "[✓] Installation complete! Reloading Hyprland..."
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
fi

if pgrep -x waybar >/dev/null 2>&1; then
    pkill waybar || true
    sleep 0.5
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl dispatch exec waybar || true
    else
        waybar &
    fi
fi

echo "Done! Backup saved at $BACKUP_DIR"
