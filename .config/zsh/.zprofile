# tty1 autologin -> Hyprland; hyprlock (autostart.lua) is the login screen
[ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && exec start-hyprland
