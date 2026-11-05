# --- Welcome Message ---------------------------------------------------------
# The distro name in its colours, centered, when a terminal opens. In a subshell,
# so /etc/os-release and the helper stay out of your shell.
[[ -o interactive && -f /etc/os-release ]] && (
    . /etc/os-release

    # Prints `text` centered to the terminal width, with one blank line above it.
    # $2 (optional) is a "R;G;B" truecolor foreground to print it in; omitted = plain/default color.
    _print_centered() {
        local text="$1"
        local color="$2"
        local width=$(tput cols)
        local pad=$(( (width - ${#text}) / 2 ))
        (( pad < 0 )) && pad=0
        echo
        if [[ -n "$color" ]]; then
            printf "%${pad}s\e[1;38;2;${color}m%s\e[0m\n" "" "$text"
        else
            printf "%${pad}s\e[1m%s\e[0m\n" "" "$text"
        fi
    }

    case "$ID" in
        arch)
            padding=$(( ($(tput cols) - 15) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;46;52;64;48;2;94;129;172m A \e[0m \e[38;2;46;52;64;48;2;129;161;193m R \e[0m \e[38;2;46;52;64;48;2;136;192;208m C \e[0m \e[38;2;46;52;64;48;2;143;188;187m H \e[0m\n"
            ;;
        ubuntu)
            padding=$(( ($(tput cols) - 23) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;255;255;255;48;2;233;84;32m U \e[0m \e[38;2;255;255;255;48;2;225;59;24m B \e[0m \e[38;2;255;255;255;48;2;173;33;72m U \e[0m \e[38;2;255;255;255;48;2;119;33;111m N \e[0m \e[38;2;255;255;255;48;2;94;39;80m T \e[0m \e[38;2;255;255;255;48;2;76;34;70m U \e[0m\n"
            # $VERSION comes from the sourced /etc/os-release and on Ubuntu already
            # contains the point version + codename, e.g. "26.04.1 LTS (Resolute Raccoon)"
            # Color 233;84;32 is the first Ubuntu square's background (the orange tile).
            _print_centered "$VERSION" "233;84;32"
            echo
            echo
            ;;
        debian)
            padding=$(( ($(tput cols) - 23) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;255;255;255;48;2;168;0;45m D \e[0m \e[38;2;255;255;255;48;2;215;7;81m E \e[0m \e[38;2;255;255;255;48;2;230;0;88m B \e[0m \e[38;2;255;255;255;48;2;168;0;45m I \e[0m \e[38;2;255;255;255;48;2;215;7;81m A \e[0m \e[38;2;255;255;255;48;2;230;0;88m N \e[0m\n"
            # /etc/os-release on Debian does NOT have the full point version (VERSION is
            # e.g. just "13 (trixie)"), so we read it from /etc/debian_version (e.g. "13.7")
            # and append VERSION_CODENAME from os-release.
            # Color 168;0;45 is the first Debian square's background (the red tile).
            _print_centered "$(</etc/debian_version) (${VERSION_CODENAME})" "168;0;45"
            echo
            echo
            ;;
        *)
            padding=$(( ($(tput cols) - 19) / 2 )) && printf "%${padding}s" "" && printf "\e[38;2;46;52;64;48;2;163;190;140m N \e[0m \e[38;2;46;52;64;48;2;235;203;139m E \e[0m \e[38;2;46;52;64;48;2;136;192;208m W \e[0m \e[38;2;46;52;64;48;2;129;161;193m O \e[0m \e[38;2;46;52;64;48;2;191;97;106m S \e[0m\n"
            ;;
    esac
)
