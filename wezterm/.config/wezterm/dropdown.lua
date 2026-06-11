local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })
config.font_size = 14
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 800
config.audible_bell = "Disabled"
config.bold_brightens_ansi_colors = true

config.colors = {
	foreground = "#d3d7cf",
	background = "#000000",
	cursor_bg = "#ffffff",
	cursor_fg = "#000000",
	selection_bg = "#b5d5ff",
	selection_fg = "#000000",
	ansi = {
		"#000000", "#cc0000", "#4e9a06", "#c4a000",
		"#3465a4", "#75507b", "#06989a", "#d3d7cf",
	},
	brights = {
		"#555753", "#ef2929", "#8ae234", "#fce94f",
		"#729fcf", "#ad7fa8", "#34e2e2", "#eeeeec",
	},
}

config.window_background_opacity = 0.95
config.enable_tab_bar = false
config.window_decorations = "NONE"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Attach to the persistent dropdown tmux session
config.default_prog = { "tmux", "new-session", "-As", "dropdown" }

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)

config.keys = {
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }) },
	{ key = "0", mods = "ALT", action = wezterm.action.SendKey({ key = "0", mods = "ALT" }) },
	{ key = "1", mods = "ALT", action = wezterm.action.SendKey({ key = "1", mods = "ALT" }) },
	{ key = "2", mods = "ALT", action = wezterm.action.SendKey({ key = "2", mods = "ALT" }) },
	{ key = "3", mods = "ALT", action = wezterm.action.SendKey({ key = "3", mods = "ALT" }) },
	{ key = "4", mods = "ALT", action = wezterm.action.SendKey({ key = "4", mods = "ALT" }) },
	{ key = "5", mods = "ALT", action = wezterm.action.SendKey({ key = "5", mods = "ALT" }) },
	{ key = "6", mods = "ALT", action = wezterm.action.SendKey({ key = "6", mods = "ALT" }) },
	{ key = "7", mods = "ALT", action = wezterm.action.SendKey({ key = "7", mods = "ALT" }) },
	{ key = "8", mods = "ALT", action = wezterm.action.SendKey({ key = "8", mods = "ALT" }) },
	{ key = "9", mods = "ALT", action = wezterm.action.SendKey({ key = "9", mods = "ALT" }) },
}

return config
