#!/bin/bash
# Wallpaper of the active tag on every monitor.
# Started by autostart.toml. mmsg prints all monitors at start and after every change
# (tag switch, monitor plugged in); a monitor gets a new swaybg only when its tag changes.

wp=~/.dots/wallpapers/webp/arch_nord
# Nord colours for tags 1-10, made by ~/.dots/wallpapers/make-wallpaper.sh:
# polar night, yellow, blue, green, red, cyan, orange, purple, white, frost
walls=(1 10_tonelogo 12_darklogo 8_darklogo 15_darklogo 13_darklogo 11 9_darklogo 5_darklogo 7_darklogo)

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
