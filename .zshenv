# ─── Path & Directory Settings ───────────────────────────────────────────────

# Set the configuration directory (Keep .config clean for Git)
export ZDOTDIR="$HOME/.config/zsh"

# Set history file to local share (Avoids Git tracking and Home clutter)
export HISTFILE="$HOME/.local/share/zsh/zsh_history"

# Define default editor and browser
export EDITOR=nano
export VISUAL=nano
export TERMINAL=foot
export BROWSER=brave-origin

# Update PATH
export PATH="$HOME/.local/bin:$PATH"

# Fix to force move.some files from $HOME folder to .config
export GTK2_RC_FILES="$HOME/.config/gtk-2.0/gtkrc"
export PULSE_COOKIE="$HOME/.config/pulse-cookie"
