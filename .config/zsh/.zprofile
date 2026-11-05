# tty1 autologin -> mango; swaylock (autostart.toml) is the login screen.
# The same line is in ~/.bash_profile for bash: change both.
[ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && exec mango
