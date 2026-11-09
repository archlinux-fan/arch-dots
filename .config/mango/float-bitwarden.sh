#!/bin/bash
# Floats the Bitwarden pop-out of Firefox. Started by autostart.toml.
# Firefox sets its title after it opens, so a window rule can't match.

declare -A seen
mmsg watch all-clients |
    jq --unbuffered -r '.clients[] | select(.appid == "firefox" and (.is_floating | not)
        and (.title | startswith("Extension: (Bitwarden Password Manager)"))) | .id' |
    while read -r id; do
        # The title changes several times, float only once
        [[ ${seen[$id]} ]] && continue
        seen[$id]=1
        mmsg dispatch togglefloating client,$id
        mmsg dispatch resizewin,480,630 client,$id
        mmsg dispatch centerwin client,$id
    done
