-- ========================
-- STARTUP
-- ========================
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
end)

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1400x900@60",
    position = "0x0",
    scale    = "1",
})

-- ========================
-- CONFIGURAÇÕES
-- ========================
hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 10,

        ["col.active_border"] = "rgba(89b4faff)",
        ["col.inactive_border"] = "rgba(44475aff)",
    },

    decoration = {
        rounding = 10,

        active_opacity = 0.95,
        inactive_opacity = 0.85,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- ========================
-- VARIÁVEIS
-- ========================
local mod = "SUPER"
local terminal = "kitty"
local fileManager = "nautilus"

-- ========================
-- KEYBINDS BÁSICOS
-- ========================
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))

-- launcher noctalia
hl.bind(mod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

-- ========================
-- FOCO DE JANELA
-- ========================
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ========================
-- WORKSPACES
-- ========================
for i = 1, 9 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- ========================
-- MOUSE
-- ========================
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ========================
-- NOCTALIA
-- ========================
require("noctalia")