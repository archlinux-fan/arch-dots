-- ============================================================
-- nvidia.lua  –  OPTIONAL NVIDIA-specific environment tweaks
-- Place at: ~/.config/hypr/nvidia.lua
--
-- HOW TO USE:
--   Add the following line to the BOTTOM of env.lua (or
--   directly in hyprland.lua after require("env")):
--
--       require("nvidia")
--
--   Only enable this if you are running Hyprland on an NVIDIA
--   GPU.  These vars are NOT needed on AMD/Intel and may
--   cause issues if applied on non-NVIDIA systems.
--
-- CHANGES vs the old nvidia.conf:
--   • WLR_DRM_NO_ATOMIC=1 is removed – it was a wlroots 0.16
--     workaround that no longer applies to Hyprland 0.55+.
--   • cursor:no_hardware_cursors is now set via hl.config()
--     instead of the old bare assignment syntax.
-- ============================================================

-- VA-API driver (hardware video decode)
hl.env("LIBVA_DRIVER_NAME",        "nvidia")

-- Force Mesa GLX to use the NVIDIA proprietary vendor
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Allow variable refresh rate on NVIDIA (G-Sync / FreeSync)
hl.env("__GL_VRR_ALLOWED", "1")

-- Disable hardware cursors – required on many NVIDIA setups
-- to avoid invisible or flickering cursors under Wayland.
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
