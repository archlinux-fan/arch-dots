-- ============================================================
-- windowrules.lua  –  Window & layer rules
-- Place at: ~/.config/hypr/windowrules.lua
--
-- Rules are evaluated top-to-bottom; later rules override
-- earlier ones for the same property.
-- ============================================================

-- ── General fixes ────────────────────────────────────────────

-- Suppress maximize requests from all apps (use tiling instead)
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag-and-drop ghost windows
hl.window_rule({
    name        = "fix-xwayland-drags",
    match       = { class = "^$", title = "^$", xwayland = true,
                    float = true, fullscreen = false, pin = false },
    no_focus    = true,
})

-- Opacity for all windows: active_opacity / inactive_opacity in theme.lua.
-- A rule here would multiply it: opacity = "active inactive", e.g. "0.9 0.8".

-- ── Floating windows ─────────────────────────────────────────

hl.window_rule({
    match = { class = "^(mpv|xpdf|.*ristretto.*|nwg-look|nm-applet|nm-connection-editor|.*pavucontrol|file_progress|confirm|dialog|download|notification|error|confirmreset)$" },
    float = true,
})

hl.window_rule({
    match = { title = "^(Firewall Configuration|Media viewer|Volume Control|Picture-in-Picture|Open File|branchdialog|Confirm to replace files|File Operation Progress|xarchiver.*|btop|satty)$" },
    float = true,
})

-- ── Sizes ────────────────────────────────────────────────────

hl.window_rule({
    match = { class = "^(download)$" },
    size  = { "monitor_w*0.75", "monitor_h*0.90" },
})

hl.window_rule({
    match = { class = "^(mpv)$" },
    size  = { "monitor_w*0.85", "monitor_h*0.85" },
})

hl.window_rule({
    match = { class = "^(.*ristretto.*|xpdf|com.gabm.satty)$" },
    size  = { "monitor_w*0.98", "monitor_h*0.94" },
})

hl.window_rule({
    match = { title = "^(Open File|Save File)$" },
    size  = { "monitor_w*0.75", "monitor_h*0.90" },
})

hl.window_rule({
    match = { title = "^(Volume Control)$" },
    size  = { 800, 600 },
})

-- ── Positions ────────────────────────────────────────────────

hl.window_rule({
    match = { title = "^(Volume Control)$" },
    move  = { 75, "monitor_h*0.44" },
})

-- ── Centering ────────────────────────────────────────────────

hl.window_rule({
    match  = { class = "^(nm-connection-editor|org.pulseaudio.pavucontrol)$" },
    center = true,
})

-- ── Idle inhibit ─────────────────────────────────────────────

hl.window_rule({
    match         = { class = "^(mpv)$" },
    idle_inhibit  = "focus",
})

hl.window_rule({
    name          = "brave-youtube-idle",
    match         = { class = "brave.*", title = ".*YouTube.*" },
    idle_inhibit  = "fullscreen",
})

-- ── Always on top ────────────────────────────────────────────

-- Password prompt of hyprpolkitagent: middle of the screen, never behind other windows
hl.window_rule({
    name   = "polkit-agent",
    match  = { class = "^(hyprpolkitagent)$" },
    float  = true,
    center = true,
    pin    = true,
})

-- Brave video pop-out stays visible on every workspace
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^(Picture-in-Picture)$" },
    pin   = true,
})

-- ── App-specific blocks ──────────────────────────────────────

-- Lite XL always opens on workspace 5 (switches there on launch)
hl.window_rule({
    name      = "litexl-workspace-5",
    match     = { class = "^com\\.lite_xl\\.LiteXL$" },
    workspace = "5",
})

hl.window_rule({
    name  = "bitwarden-popup",
    match = { class = "brave.*", title = "_crx_nngceckbapebfimnlniiiahkandclblb" },
    float = true,
    size  = { 480, "monitor_h*0.7" },
    center = true,
})

hl.window_rule({
    name   = "btop-foot",
    match  = { class = "footclient", title = "btop" },
    size   = { "monitor_w*0.97", "monitor_h*0.92" },
    center = true,
})

hl.window_rule({
    name   = "hypr-confirm-dialog",
    match  = { class = "footclient", title = "hypr-confirm" },
    float  = true,
    size   = { 520, 160 },
    center = true,
})

hl.window_rule({
    name   = "hypr-update-terminal",
    match  = { class = "footclient", title = "hypr-update" },
    float  = true,
    size   = { "monitor_w*0.95", "monitor_h*0.9" },
    center = true,
})

-- ── Layer rules ──────────────────────────────────────────────

hl.layer_rule({
    match = { namespace = "rofi|logout_dialog|waybar" },
    blur  = true,
})

