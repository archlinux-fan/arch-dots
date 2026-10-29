-- ============================================================
-- hyprland.lua  –  Main config entry point
-- Place at: ~/.config/hypr/hyprland.lua
--
-- Requires Hyprland >= 0.55  (Lua config system)
-- Hyprland will load this file instead of hyprland.conf
-- when it exists. Delete / rename hyprland.conf or keep it
-- for one-version fallback – it will be ignored once .lua
-- is present.
--
-- Sub-files are loaded with require().  Lua uses the hypr/
-- directory as the package root, so "monitors" resolves to
-- ~/.config/hypr/monitors.lua, etc.
-- ============================================================

require("env")          -- Environment variables (XCURSOR_SIZE, XDG_*, etc.)
require("monitors")     -- Monitor layout + workspace-to-monitor assignments
require("theme")        -- general / decoration / animations / dwindle / misc
require("autostart")    -- exec-once equivalents  (hl.on "hyprland.start")
require("windowrules")  -- Window & layer rules
require("keybindings")  -- All keybinds


-- ── Input ────────────────────────────────────────────────────
-- Keyboard layout and per-device settings go to local.lua.
hl.config({
    input = {
        follow_mouse = 0,           -- 0 = focus follows click, not cursor
        sensitivity  = 0,

        numlock_by_default = true,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- ── Optional extras ──────────────────────────────────────────
-- extras.lua (wobble, popup blur, snapping ...); delete it to drop them.
if io.open(os.getenv("HOME") .. "/.config/hypr/extras.lua") then
    require("extras")
end

-- ── Personal overrides ───────────────────────────────────────
-- local.lua (keyboard, mouse, monitors) comes from the private
-- repo; skipped when it doesn't exist.
if io.open(os.getenv("HOME") .. "/.config/hypr/local.lua") then
    require("local")
end
