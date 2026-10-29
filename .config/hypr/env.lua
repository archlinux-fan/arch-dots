-- ============================================================
-- env.lua  –  Environment variables
-- Place at: ~/.config/hypr/env.lua
-- ============================================================

-- Cursor size for X11 and Hypr native cursors
hl.env("XCURSOR_THEME",    "Nordzy-cursors-white")
hl.env("XCURSOR_SIZE",       "24")
hl.env("HYPRCURSOR_THEME", "Nordzy-hyprcursors-white")
hl.env("HYPRCURSOR_SIZE",    "24")

-- XDG session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK – use wayland backend, unscaled (scale handled by Hyprland)
hl.env("GDK_BACKEND", "wayland")
hl.env("GDK_SCALE",   "1")

-- ── Commented-out extras ────────────────────────────────────
-- Uncomment if you need Qt / SDL / Java / Mozilla tweaks:

hl.env("QT_QPA_PLATFORM",                  "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

hl.env("SDL_VIDEODRIVER", "wayland")
-- hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
-- hl.env("WLR_NO_HARDWARE_CURSORS",     "1")   -- try if cursor is invisible on NVIDIA

-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("MOZ_ENABLE_WAYLAND",      "1")

-- hl.env("OZONE_PLATFORM", "wayland")
