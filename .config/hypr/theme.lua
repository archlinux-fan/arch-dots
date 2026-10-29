-- ============================================================
-- theme.lua  –  Look & feel: general, decoration, animations,
--               layouts, misc, input, device
-- Place at: ~/.config/hypr/theme.lua
-- ============================================================

-- ── General & Decoration ────────────────────────────────────
hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 8,
        border_size      = 2,
        col = {
            -- Nord frost blue: nord9
            active_border   = { colors = { "rgba(81A1C1ff)" }, angle = 45 },
            -- Nord polar night: nord3 → nord1, 45°
            inactive_border = { colors = { "rgba(4c566acc)", "rgba(3b4252cc)" }, angle = 45 },
        },
        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding        = 10,
        rounding_power = 2,
        -- All windows (foot too, its own alpha is off); fullscreen stays opaque
        active_opacity   = 1,
        inactive_opacity = 0.95,

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1d2129ee)",  -- nord0, darker
        },
    },

    -- ── Dwindle layout ────────────────────────────────────
    dwindle = {
        preserve_split = true,
    },

    -- ── Master layout ─────────────────────────────────────
    master = {
        new_status = "master",
    },

    -- ── Scrolling layout ──────────────────────────────────
    scrolling = {
        fullscreen_on_one_column = true,
    },
    
    -- ── Gestures ──────────────────────────────────────────
    gestures = {
        workspace_swipe_touch = true,
    },

    -- ── Miscellaneous ─────────────────────────────────────
    misc = {
--        vrr                    = 0,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,   -- -1 = default; 0 or 1 disables anime mascot
        disable_hyprland_logo    = true,
        focus_on_activate = true,
        key_press_enables_dpms = true,  -- any key wakes screens after DPMS off
    },

    -- No automatic HDR switch on fullscreen video: each switch is a modeset,
    -- seconds of black screen when entering and leaving fullscreen
    render = {
        cm_auto_hdr = 0,
    },
})

-- ── Group border colours ─────────────────────────────────────
-- NOTE: group colours are set via hl.config in newer builds.
-- If your version supports it, uncomment this block:
-- hl.config({
--     group = {
--         col = {
--             border_active   = { colors = { "rgba(88c0d0ff)", "rgba(5e81acff)" }, angle = 45 },
--             border_inactive = { colors = { "rgba(4c566acc)", "rgba(3b4252cc)" }, angle = 45 },
--         },
--     },
-- })




---- ── Bezier curves ────────────────────────────────────────────
hl.curve("wind",           { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn",          { type = "bezier", points = { { 0.1,  1.1 }, { 0.1, 1.1  } } })
hl.curve("winOut",         { type = "bezier", points = { { 0.3, -0.3 }, { 0,   1    } } })
hl.curve("linear",         { type = "bezier", points = { { 0,   0    }, { 1,   1    } } })

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
-- hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })



---- ── Animations ──────────────────────────────────────────────
--hl.config({ animations = { enabled = true } })
--


hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
--hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "border",        enabled = true,  speed = 1,    bezier = "linear" })

--hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
--hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
--hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.5,  bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.5,  bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 4.5,  bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true,  speed = 3,    bezier = "wind",   style = "slide" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
--hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
--hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4.5, bezier = "wind" })

--hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "wind" })
--hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "wind" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })


