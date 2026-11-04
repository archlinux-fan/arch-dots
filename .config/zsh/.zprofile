# tty1 autologin -> mango; hyprlock (autostart.toml) is the login screen
[ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && exec mango
