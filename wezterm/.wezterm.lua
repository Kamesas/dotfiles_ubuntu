-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font settings to match Guake
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })
config.font_size = 14
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

-- Default Ctrl+=/Ctrl+- zoom by ~10% per step, growing coarser each press.
-- These instead step by a fixed 0.5pt, so every press changes size by the
-- same small amount.
local FONT_STEP = 0.5
local FONT_MIN = 6
local FONT_MAX = 36

local function step_font_size(window, delta)
	local overrides = window:get_config_overrides() or {}
	local size = overrides.font_size or config.font_size
	overrides.font_size = math.max(math.min(size + delta, FONT_MAX), FONT_MIN)
	window:set_config_overrides(overrides)
end

local function reset_font_size(window)
	local overrides = window:get_config_overrides() or {}
	overrides.font_size = config.font_size
	window:set_config_overrides(overrides)
end

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
	-- Ctrl+Backspace → Ctrl+w (delete word backward in shells).
	-- Ctrl+Backspace and Ctrl+h send the same byte in traditional terminals,
	-- and vim-tmux-navigator claims Ctrl+h for pane navigation.
	{
		key = "Backspace",
		mods = "CTRL",
		action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }),
	},
	-- Send Alt+number keys through to tmux
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

-- WezTerm's own keytable has separate default entries for the "shifted" and
-- "unshifted" forms of the same physical key (e.g. "=" and "+" both produce
-- IncreaseFontSize by default, each under both CTRL and CTRL|SHIFT mods).
-- Overriding just one form leaves the others still wired to the built-in
-- zoom, which is how a single Ctrl+0 press fell through to the default
-- ResetFontSize. Cover every form so none of them can fall through.
local increase_keys = { { key = "=", mods = "CTRL" }, { key = "=", mods = "CTRL|SHIFT" }, { key = "+", mods = "CTRL" }, { key = "+", mods = "CTRL|SHIFT" } }
local decrease_keys = { { key = "-", mods = "CTRL" }, { key = "-", mods = "CTRL|SHIFT" }, { key = "_", mods = "CTRL" }, { key = "_", mods = "CTRL|SHIFT" } }
local reset_keys = { { key = "0", mods = "CTRL" }, { key = "0", mods = "CTRL|SHIFT" }, { key = ")", mods = "CTRL" }, { key = ")", mods = "CTRL|SHIFT" } }

for _, k in ipairs(increase_keys) do
	table.insert(config.keys, {
		key = k.key,
		mods = k.mods,
		action = wezterm.action_callback(function(window, pane)
			step_font_size(window, FONT_STEP)
		end),
	})
end
for _, k in ipairs(decrease_keys) do
	table.insert(config.keys, {
		key = k.key,
		mods = k.mods,
		action = wezterm.action_callback(function(window, pane)
			step_font_size(window, -FONT_STEP)
		end),
	})
end
for _, k in ipairs(reset_keys) do
	table.insert(config.keys, {
		key = k.key,
		mods = k.mods,
		action = wezterm.action_callback(function(window, pane)
			reset_font_size(window)
		end),
	})
end

return config
