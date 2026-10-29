-- ============================================================
-- autostart.lua  –  Programs launched at Hyprland start
-- Place at: ~/.config/hypr/autostart.lua
--
-- exec-once equivalents use hl.on("hyprland.start", ...).
-- All commands run exactly once when the compositor starts.
-- ============================================================

hl.on("hyprland.start", function()

    -- Login screen (tty1 autologin starts Hyprland unlocked)
    hl.exec_cmd("hyprlock")

    -- Polkit agent (authentication popups)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Wallpaper daemon – start it, then wait briefly for it to be ready,
    -- then push the initial wallpaper (wallpaper 1 = default workspace).
    -- Without the second call the wallpaper stays blank until the user
    -- presses Super+1 for the first time.
    hl.exec_cmd("hyprpaper")

    -- Clipboard persistence – keeps clipboard alive after app closes.
    -- The --ignore-empty flag avoids a freeze when copying in Brave
    -- (pair with Brave flag: --ozone-platform-hint=wayland).
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- Notification daemon
    hl.exec_cmd("mako")

    -- Idle / lock / DPMS daemon
    hl.exec_cmd("hypridle")

    -- Foot terminal daemon/server
    hl.exec_cmd("foot --server")
    
    -- Set cursor
    hl.exec_cmd("hyprctl setcursor Nordzy-hyprcursors-white 24")
    
    -- Status bar
    hl.exec_cmd("waybar")

    -- Connects Bluetooth headphones again when their music link hangs (~/.local/bin/bt)
    hl.exec_cmd("bt watch")

end)
