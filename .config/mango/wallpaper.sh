#!/bin/bash
# Wallpaper of the active tag on every monitor, as keybindings.lua does in Hyprland.
# Started by autostart.toml. mmsg prints all monitors at start and after every change
# (tag switch, monitor plugged in); a monitor gets a new swaybg only when its tag changes.

wp=~/pictures/wallpapers/webp/arch_nord
# Nord colours for tags 1-10, made by ~/pictures/wallpapers/make-wallpaper.sh:
# polar night, yellow, blue, green, red, cyan, orange, purple, white, frost
walls=(1 13 10 14 11 8 12 15 6_light 7)

declare -A tag pid
mmsg watch all-monitors |
    jq --unbuffered -r '.monitors[] | select(.width > 0 and .active_tags[0] > 0) | "\(.name) \(.active_tags[0])"' |
    while read -r mon t; do
        [[ ${tag[$mon]} == "$t" ]] && continue
        tag[$mon]=$t
        old=${pid[$mon]}
        swaybg -o "$mon" -m fill -i "$wp${walls[t-1]}_2160p.webp" &
        pid[$mon]=$!
        # The old one goes once the new one is drawn, so the background never flashes
        [[ $old ]] && { sleep 0.5; kill "$old"; } &
    done
