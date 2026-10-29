#!/bin/bash
#  _   _           _       _             
# | | | |_ __   __| | __ _| |_ ___  ___  
# | | | | '_ \ / _` |/ _` | __/ _ \/ __| 
# | |_| | |_) | (_| | (_| | ||  __/\__ \ 
#  \___/| .__/ \__,_|\__,_|\__\___||___/ 
#       |_|                              
#

# -----------------------------------------------------
# Waybar updates module: pacman and AUR
# Usage:   updates.sh pacman      JSON for the module
#          updates.sh aur
#          updates.sh upgrade     in a terminal: the list, then pacman -Syu
# -----------------------------------------------------

mode="$1"
db=~/.cache/pacman-updates

case "$mode" in
    upgrade)
        # Waybar right click and Super+U. The list with descriptions comes from the copy;
        # pacman -Syu needs no password (sudoers), anything else does.
        "$0" pacman >/dev/null
        printf '\n\e[1;37m%-20s   %s\e[0m\n' Package Description
        pacman -Qu --dbpath "$db" | cut -d' ' -f1 | xargs -r pacman -Si --dbpath "$db" |
            awk -F': ' '/^Name/ {name=$2} /^Description/ {printf "%-20s   %s\n", name, $2}'
        echo; sudo pacman -Syu
        pkill -SIGRTMIN+8 waybar
        exit
        ;;
    pacman)
        # Like checkupdates: sync a copy of the database, never the real one ("pacman -Sy"
        # without -u leaves the system half updated). fakeroot fakes the root pacman wants;
        # the download sandbox (user alpm) needs real root, so it's off for this copy.
        mkdir -p "$db" && ln -sfn /var/lib/pacman/local "$db/local"
        list=$(fakeroot -- pacman -Sy --dbpath "$db" --logfile /dev/null --disable-sandbox >/dev/null 2>&1 && pacman -Qu --dbpath "$db")
        name="official repos (pacman)"
        threshhold_yellow=10
        threshhold_red=30
        ;;
    aur)
        list=$(yay -Qua 2>/dev/null)
        name="AUR (yay)"
        threshhold_yellow=5
        threshhold_red=15
        ;;
    *)
        printf '{"text": "?", "alt": "?", "tooltip": "Usage: %s pacman|aur", "class": "white"}' "$(basename "$0")"
        exit 1
        ;;
esac

# One line per update; a failed command gives an empty list, so 0
updates=$(grep -c . <<< "$list")

# -----------------------------------------------------
# JSON output for the Waybar custom module
# -----------------------------------------------------

threshhold_green=1

if [ "$updates" -ge "$threshhold_red" ]; then
    css_class="red"
elif [ "$updates" -ge "$threshhold_yellow" ]; then
    css_class="yellow"
elif [ "$updates" -ge "$threshhold_green" ]; then
    css_class="green"
else
    css_class="white"
fi

# Hover: the list (a tooltip is as wide as its text), at most 30 lines, then the clicks.
# The tooltip is Pango markup, so @html escapes < > & in the list.
[ -n "$list" ] && list=$'\n\n'"$(head -n 30 <<< "$list")"
[ "$updates" -gt 30 ] && list+=$'\n'"... and $((updates - 30)) more"
jq -cn --arg n "$updates" --arg c "$css_class" --arg name "$name" --arg list "$list" \
    '{text: $n, alt: $n, class: $c, tooltip: "<b>Updates:</b> \($name)\($list | @html)\n\nLeft click: check now\nRight click: update"}'
