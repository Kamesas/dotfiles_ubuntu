-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font settings to match Guake
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })
config.font_size = 16
-- Cursor settings
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 800

-- Disable audible bell
config.audible_bell = "Disabled"

-- Enable bold fonts (Guake has this checked)
config.bold_brightens_ansi_colors = true

-- Tango color scheme (Guake's default)
config.colors = {
	foreground = "#d3d7cf",
	background = "#000000",
	cursor_bg = "#ffffff",
	cursor_fg = "#000000",
	selection_bg = "#b5d5ff",
	selection_fg = "#000000",
	ansi = {
		"#000000", -- black
		"#cc0000", -- red
		"#4e9a06", -- green
		"#c4a000", -- yellow
		"#3465a4", -- blue
		"#75507b", -- magenta
		"#06989a", -- cyan
		"#d3d7cf", -- white
	},
	brights = {
		"#555753", -- bright black
		"#ef2929", -- bright red
		"#8ae234", -- bright green
		"#fce94f", -- bright yellow
		"#729fcf", -- bright blue
		"#ad7fa8", -- bright magenta
		"#34e2e2", -- bright cyan
		"#eeeeec", -- bright white
	},
}

-- Transparency (adjust value between 0.0 and 1.0)
config.window_background_opacity = 0.95

-- Remove decorations like Guake
config.enable_tab_bar = false
config.window_decorations = "NONE"

-- Remove padding
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- Or use this to start in fullscreen
wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)

-- Key bindings
config.keys = {
	-- Map F11 to toggle fullscreen
	{
		key = "F11",
		action = wezterm.action.ToggleFullScreen,
	},
	-- Disable Alt+Enter so it passes through to Neovim
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
