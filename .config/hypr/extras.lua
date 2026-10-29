-- ============================================================
-- extras.lua  –  Optional extras, mostly new in Hyprland 0.57
-- hyprland.lua loads this file only if it exists: delete it,
-- or a block of it, to drop what you don't like.
-- ============================================================

hl.config({
    decoration = {
        -- Windows wobble a little while you move or resize them
        -- wobble = { enabled = true },
        -- Blur behind right-click menus and other popups too
        blur = { popups = true },
    },
    cursor = {
        -- Mouse pointer hides while you type and returns when you move the mouse
        hide_on_key_press = true,
    },
    general = {
        -- Floating windows snap to screen edges and to each other
        snap = { enabled = true },
    },
})

-- The small reboot / power off dialog stays still (only matters with wobble on)
-- hl.window_rule({
--     name      = "confirm-no-wobble",
--     match     = { class = "footclient", title = "hypr-confirm" },
--     no_wobble = true,
-- })
