# bash at login on the console. zsh reads ~/.zshenv and ~/.config/zsh/.zprofile instead:
# the same settings are there, change both.

# Default editor, terminal and browser
export EDITOR=nano
export VISUAL=nano
export TERMINAL=foot
export BROWSER=brave-origin

# Own scripts (bt, power-confirm ...), also for waybar and mango
export PATH="$HOME/.local/bin:$PATH"

# Fix to force move.some files from $HOME folder to .config
export PULSE_COOKIE="$HOME/.config/pulse-cookie"

# Arch's default: the settings for interactive bash
[[ -f ~/.bashrc ]] && . ~/.bashrc

# tty1 autologin -> mango; swaylock (autostart.toml) is the login screen
[ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && exec mango
