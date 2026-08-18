# 9M2PJU Hyprland Configuration

Optimized, lightweight, and modern **Hyprland** (Wayland) dotfiles tuned for **Lenovo ThinkPad T460** on **CachyOS / Arch Linux**.

---

## 💻 Hardware & System Profile

- **Device**: Lenovo ThinkPad T460 (Intel Core i5-6300U @ 2.40–3.00 GHz, 2C/4T)
- **Graphics**: Intel HD Graphics 520 (Skylake GT2)
- **RAM**: 16 GiB DDR3-1600 + 15.5 GiB zram swap
- **Display Setup**: Dual Monitor
  - Internal Laptop Panel: `eDP-1` (1366×768 @ 60Hz) on the left `(0,0)`
  - External Monitor: `HDMI-A-2` (1920×1080 @ 100Hz) on the right `(1366,0)`
- **Audio**: Intel Sunrise Point-LP Realtek ALC269 + FiiO K11 R2R DAC (USB)

---

## ✨ Features & Highlights

### 1. Modern Lua Configuration (Hyprland v0.55+)
- Migrated to the new native Lua format (`hyprland.lua`).
- Fully backwards-compatible with fallback `hyprland.conf`.
- GPU optimizations for Intel HD 520 (disabled heavy blur passes and shadows for stutter-free 60–100Hz rendering).

### 2. Custom Waybar Top Bar
- **Dynamic Workspaces**: Displays live app icons (``, ``, ``, `󰨞`, ``, ``, etc.) mapped to running window classes.
- **Independent Dual Brightness Control**:
  - **Laptop Screen (`eDP-1`)**: Standard kernel backlight control (`brightnessctl`).
  - **External Monitor (`HDMI-A-2`)**: Hardware DDC/CI control via `ddcutil` with background caching (instant mouse scrolling without UI freezing).
- **Rich Memory Telemetry**: Shows live RAM % with tooltip breakdown of Used/Available GiB and zram swap utilization; click launches `btop`.
- **Btrfs Disk Space Monitor**: Root partition storage percentage and free space; click launches Dolphin.
- **Bold 12-Hour Clock**: Formatted as `dd/mm/yyyy hh:mm AM/PM` with full calendar tooltip.
- **Power Menu**: Dedicated `⏻` button triggering `wlogout`.

### 3. Idle & Lock Management (`hypridle` + `hyprlock`)
- **2.5 min**: Dims backlight.
- **5 min**: Automatic lock screen via `hyprlock`.
- **6 min**: Turns off displays via DPMS (wakes on mouse/key).
- **30 min**: System suspend.
- **Lock on sleep**: Automatically locks session before suspend or lid close.
- **Caffeine Mode**: Toggleable on Waybar via `idle_inhibitor`.

### 4. Input & Navigation
- **Mouse Wheel**: `scroll_factor = 2.0` (faster scroll speed matching KDE Plasma).
- **Touchpad**: `scroll_factor = 1.0` (standard natural scrolling with tap-to-click).
- **NumLock on Login**: Enabled across both SDDM and Hyprland desktop sessions.

---

## ⌨️ Keybindings Cheat-Sheet

| Keybinding | Action |
| :--- | :--- |
| `SUPER` + `Q` | Open Terminal (`kitty`) |
| `SUPER` + `E` | Open File Manager (`dolphin`) |
| `SUPER` + `R` or `SUPER` + `SPACE` | App Launcher (`wofi`) |
| `SUPER` + `C` | Close Active Window |
| `SUPER` + `V` | Toggle Floating Window |
| `SUPER` + `F` | **Maximize** (Monocle — keeps top bar visible) |
| `SUPER` + `SHIFT` + `F` | **True Fullscreen** (covers whole display) |
| `SUPER` + `L` | Lock Screen (`hyprlock`) |
| `SUPER` + `M` | Exit Hyprland Session |
| `Print` | Copy Full Screenshot to Clipboard |
| `SUPER` + `SHIFT` + `S` | Area Screenshot (`grim` + `slurp`) |
| `SUPER` + `[0-9]` | Switch to Workspace 1–10 |
| `SUPER` + `SHIFT` + `[0-9]` | Move Window to Workspace 1–10 |
| `SUPER` + Arrow Keys | Move Focus (Left/Right/Up/Down) |
| `SUPER` + `LMB Drag` | Move Window |
| `SUPER` + `RMB Drag` | Resize Window |
| Volume / Brightness Keys | Audio & Laptop Backlight Control |

---

## 📁 Repository Structure

```text
9M2PJU-Hyprland-Config/
├── README.md
├── install.sh
├── hypr/
│   ├── hyprland.lua          # Main Hyprland Lua configuration
│   ├── hyprland.conf         # Fallback Hyprland config
│   ├── hypridle.conf         # Idle, DPMS, and sleep timeout daemon
│   └── hyprlock.conf         # Blurred desktop lockscreen
├── waybar/
│   ├── config.jsonc          # Waybar module layout & definitions
│   ├── style.css             # GTK CSS stylesheet
│   └── scripts/
│       ├── brightness-ext.sh # DDC/CI external monitor brightness controller
│       └── tailscale.sh      # Tailscale VPN status module
├── wlogout/
│   └── layout                # Power menu actions (Lock, Suspend, Reboot, Shutdown)
└── sddm/
    └── 10-numlock.conf       # SDDM login screen NumLock setting
```

---

## 🚀 Installation

Clone and run the installation script:

```bash
git clone https://github.com/9M2PJU/9M2PJU-Hyprland-Config.git
cd 9M2PJU-Hyprland-Config
chmod +x install.sh
./install.sh
```

---

## 👤 Author

- **9M2PJU** — Amateur Radio Operator & Linux Enthusiast
