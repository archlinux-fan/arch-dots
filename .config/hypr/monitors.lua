-- ============================================================
-- monitors.lua  –  Default monitor rule
-- Any monitor gets its preferred mode, auto-placed.
-- Your own monitors, scales and workspace assignments go to
-- local.lua (private repo), which hyprland.lua loads last.
-- ============================================================

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
