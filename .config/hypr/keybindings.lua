-- ============================================================
-- keybindings.lua  –  All keybinds
-- Place at: ~/.config/hypr/keybindings.lua
-- ============================================================

local mainMod = "SUPER"

-- ── App launchers ────────────────────────────────────────────
local terminal    = "footclient"
local editor      = "lite-xl"
--local editor      = "lite-xl ~/.config/lite-xl/ws/"
local editor2     = "mousepad"
local fileManager = "thunar"
local browser     = "brave-origin"
local menu        = "rofi -combi-modi window,drun,run -show combi -modi combi"

-- ── Wallpaper variables ──────────────────────────────────────
local home = os.getenv("HOME")
local wp   = home .. "/pictures/wallpapers/webp/"

-- Nord colours, made by ~/pictures/wallpapers/make-wallpaper.sh
local wallpapers = {
    wp .. "arch_nord1_2160p.webp",   -- 1 polar night
    wp .. "arch_nord13_2160p.webp",  -- 2 yellow
    wp .. "arch_nord10_2160p.webp",  -- 3 blue
    wp .. "arch_nord14_2160p.webp",  -- 4 green
    wp .. "arch_nord11_2160p.webp",  -- 5 red
    wp .. "arch_nord8_2160p.webp",   -- 6 cyan
    wp .. "arch_nord12_2160p.webp",  -- 7 orange
}

local function setWallpaper(path)
    hl.exec_cmd("hyprctl hyprpaper wallpaper '," .. path .. "'")
end

-- ============================================================
-- WINDOW / SESSION MANAGEMENT
-- ============================================================

hl.bind(mainMod .. " + Q",              hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.exec_cmd("hyprctl kill"))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + C", hl.dsp.window.center())

-- Dwindle helpers
hl.bind(mainMod .. " + K", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + J", hl.dsp.layout("swapsplit"))

-- Cycle windows + bring active to top
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)


-- ── Lock / DPMS ──────────────────────────────────────────────
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- DPMS off after 0.5s, so key releases don't wake it again (key_press_enables_dpms)
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(
    "touch /tmp/hypr_idle_override; sleep 0.5 && hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'"
))


-- ── Hyprland reload ──────────────────────────────────────────
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.exec_cmd(
    "hyprctl reload;" ..
    "notify-send -t 5000 --app-name=hyprland 'Hyprland was reloaded'"
))


-- ── Waybar restart ───────────────────────────────────────────
hl.bind(mainMod .. " + CTRL + SHIFT + W", hl.dsp.exec_cmd(
    "pkill -x waybar; waybar &" ..
    "notify-send -t 5000 --app-name=hyprland 'Waybar was reloaded'"
))


-- ── Color picker ─────────────────────────────────────────────
-- The colour is copied (-a) and shown; Escape cancels without a message
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(
    "c=$(hyprpicker -a) && [ -n \"$c\" ] &&" ..
    "notify-send -t 5000 --app-name=hyprland \"Color picked: $c\""
))

-- ============================================================
-- APPLICATION SHORTCUTS
-- ============================================================

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd(editor2))
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(menu))

-- Root variants
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(
    'pkexec env WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DISPLAY="$DISPLAY" ' .. fileManager
))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(
    'pkexec env WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DISPLAY="$DISPLAY" ' .. editor
))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(
    'pkexec env WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DISPLAY="$DISPLAY" ' .. editor2
))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(
    'pkexec env WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DISPLAY="$DISPLAY" firewall-config'
))

-- Brave (profiles per key can be set in local.lua)
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --incognito"))

-- Audacious – open only if not already running
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(
    "sh -c 'if ! hyprctl clients | grep -q audacious; then audacious & fi'"
))

-- FIX: original string was cut off — missing  & fi'  at the end
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(
    "sh -c 'if ! hyprctl clients | grep -q obsidian; then obsidian & fi'"
))

-- System monitors
hl.bind("CTRL + SHIFT + Escape",        hl.dsp.exec_cmd(terminal .. " --title btop -e btop"))
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd(terminal .. " --title btop -e htop"))
hl.bind(mainMod .. " + CTRL + Escape",  hl.dsp.exec_cmd(terminal .. " --title fastfetch -e sh -c 'fastfetch; read -n 1'"))

-- ── System actions (with confirmation prompts) ───────────────
-- power-confirm (~/.local/bin) is also used by the waybar power icon
hl.bind(mainMod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("power-confirm reboot"))
hl.bind(mainMod .. " + CTRL + SHIFT + P", hl.dsp.exec_cmd("power-confirm poweroff"))

-- ── Package updates ──────────────────────────────────────────
-- Same as the right click on the update counter in waybar
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(
    "[float] " .. terminal .. " --title hypr-update -e ~/.config/waybar/scripts/updates.sh upgrade"
))

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(string.format(
    "[float] %s --title hypr-update -e sh -c 'yay -Sua'",
    terminal
)))

-- ============================================================
-- FOCUS MOVEMENT
-- ============================================================

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- ============================================================
-- WINDOW MOVEMENT  (tiled: swap direction; floating: nudge 30px)
-- ============================================================

local function moveActive(dx, dy, dir)
    return function()
        local w = hl.get_active_window()
        if w ~= nil and w.floating then
            hl.dispatch(hl.dsp.window.move({ delta = { dx, dy } }))
        else
            hl.dispatch(hl.dsp.window.move({ direction = dir }))
        end
    end
end

hl.bind(mainMod .. " + SHIFT + CTRL + left",  moveActive(-30,  0,  "l"))
hl.bind(mainMod .. " + SHIFT + CTRL + right", moveActive( 30,  0,  "r"))
hl.bind(mainMod .. " + SHIFT + CTRL + up",    moveActive(  0, -30, "u"))
hl.bind(mainMod .. " + SHIFT + CTRL + down",  moveActive(  0,  30, "d"))

-- ── Mouse move / resize ──────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================
-- WORKSPACES
-- ============================================================

for i = 1, 7 do
    local key    = tostring(i % 10)
    local wp_path = wallpapers[i]

    -- Switch to workspace
    hl.bind(mainMod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
        if wp_path then setWallpaper(wp_path) end
    end)

    -- Move window + follow
    hl.bind(mainMod .. " + CTRL + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i }))
        if wp_path then setWallpaper(wp_path) end
    end)

    -- Move window + do not follow
    hl.bind(mainMod .. " + ALT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = false }))
    end)
end

-- Workspaces 8, 9, 0
for _, v in ipairs({ {8,"8"}, {9,"9"}, {10,"0"} }) do
    local num, key = v[1], v[2]
    hl.bind(mainMod .. " + ALT + " .. key,
        hl.dsp.window.move({ workspace = num, follow = false })
    )
end

-- Relative workspace navigation
hl.bind(mainMod .. " + CTRL + right",     hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left",      hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + down",      hl.dsp.focus({ workspace = "empty" }))

-- Move window to relative workspace
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + left",  hl.dsp.window.move({ workspace = "r-1" }))

-- ============================================================
-- AUDIO
-- ============================================================

-- ~/.local/bin/sound: the default output and mic (best connected device, see
-- ~/.config/wireplumber); with Super the keys are for the microphone;
-- Super+Shift+Mute connects silent Bluetooth headphones again (~/.local/bin/bt)
hl.bind("XF86AudioRaiseVolume",                    hl.dsp.exec_cmd("sound up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",                    hl.dsp.exec_cmd("sound down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",                           hl.dsp.exec_cmd("sound mute"),     { locked = true })
hl.bind(mainMod .. " + XF86AudioRaiseVolume",      hl.dsp.exec_cmd("sound mic-up"),   { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioLowerVolume",      hl.dsp.exec_cmd("sound mic-down"), { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioMute",             hl.dsp.exec_cmd("sound mic-mute"), { locked = true })
hl.bind(mainMod .. " + SHIFT + XF86AudioMute",     hl.dsp.exec_cmd("bt headphones"),  { locked = true })

-- ============================================================
-- MEDIA
-- ============================================================

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("Pause",          hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ============================================================
-- SCREENSHOTS  (via hyprshot)
-- ============================================================

-- Files: ~/pictures/screenshots/YYYYMMDD-HHMMSS_WxH.png; size is added after capture
local function shot(cmd)
    return "d=$HOME/pictures/screenshots n=$(date +%Y%m%d-%H%M%S); " .. cmd
        .. "; f=$d/$n.png; [ -f $f ] && mv $f $d/${n}_$(file -b $f | grep -o '[0-9]* x [0-9]*' | tr -d ' ').png"
end

-- Print: select a region, save + copy to clipboard
hl.bind("Print", hl.dsp.exec_cmd(shot("hyprshot -m region --freeze -o $d --filename $n.png")))
-- Super+Print: click a window, save + copy to clipboard
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(shot("hyprshot -m window --freeze -o $d --filename $n.png")))
-- Shift+Print: select a region and edit it in satty
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(shot("hyprshot -m region --freeze --raw | satty --filename - --output-filename $d/$n.png")))
-- Super+Shift+Print: click a monitor, save + copy to clipboard
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(shot("hyprshot -m output -o $d --filename $n.png")))


-- ============================================================
-- BRIGHTNESS
-- ============================================================

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(
    [[d=/sys/class/backlight/amdgpu_bl1; read c < $d/brightness; read m < $d/max_brightness; ]] ..
    [[n=$((c + m/10)); [ $n -gt $m ] && n=$m; ]] ..
    [[busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu backlight amdgpu_bl1 $n; ]] ..
    [[b=$(( (n*100 + m/2) / m )); ]] ..
    [[notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:$b -t 2000 --app-name=brightness "Brightness: $b%"]]
), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(
    [[d=/sys/class/backlight/amdgpu_bl1; read c < $d/brightness; read m < $d/max_brightness; ]] ..
    [[n=$((c - m/10)); [ $n -lt $((0)) ] && n=$((0)); ]] ..
    [[busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session SetBrightness ssu backlight amdgpu_bl1 $n; ]] ..
    [[b=$(( (n*100 + m/2) / m )); ]] ..
    [[notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:$b -t 2000 --app-name=brightness "Brightness: $b%"]]
), { locked = true, repeating = true })
