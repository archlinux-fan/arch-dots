# --- Prompt ------------------------------------------------------------------
# @host ~/folder $ : blue at home, yellow over ssh, red with # as root.
autoload -U colors && colors

if [[ $EUID -eq 0 ]]; then
    HOSTCOLOR="red"
    USER_SYMBOL="#"
elif [[ -n "$SSH_CONNECTION" ]]; then
    HOSTCOLOR="yellow"
    USER_SYMBOL="$"
else
    HOSTCOLOR="blue"
    USER_SYMBOL="$"
fi

PROMPT='%B%F{magenta}@%F{$HOSTCOLOR}%m %F{white}%~ %F{$HOSTCOLOR}${USER_SYMBOL}%b%f '
