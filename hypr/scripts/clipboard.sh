#!/usr/bin/env bash
# Tokyo Night Clipboard Picker
selection=$(cliphist list | bemenu -i -l 12 \
    -p " 󰅍 Clipboard " \
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

if [ -n "$selection" ]; then
    echo "$selection" | cliphist decode | wl-copy
fi
