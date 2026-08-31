-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()

-- Font settings to match Guake
-- FiraCode has no CJK glyphs; Noto CJK fills them in for Japanese/Chinese/Korean text.
config.font = wezterm.font_with_fallback({
	{ family = "FiraCode Nerd Font", weight = "Medium" },
	"Noto Sans CJK JP",
})
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

-- Remove decorations like Guake
config.enable_tab_bar = false

-- Windows has no tiling compositor to move or resize the window, so it keeps a
-- resize border. On Linux sway does that job and the border is not needed.
local is_windows = wezterm.target_triple:find("windows") ~= nil
config.window_decorations = is_windows and "RESIZE" or "NONE"

-- On Windows the shell lives in WSL, so open there instead of PowerShell.
-- Only when that distro is actually installed: naming a domain that does not
-- exist stops WezTerm opening at all, and not every machine has WSL.
if is_windows then
	for _, domain in ipairs(wezterm.default_wsl_domains()) do
		if domain.name == "WSL:Ubuntu" then
			config.default_domain = domain.name
			break
		end
	end
end

-- Remove padding
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- Start maximized. The handler must also honour a command passed on the command
-- line: WezTerm hands it in as `cmd`, and once a gui-startup handler exists
-- WezTerm stops spawning the initial window itself. Ignoring `cmd` therefore
-- spawns the default (WSL) window *in addition to* the requested one -- which is
-- how `wezterm start -- powershell.exe` ended up opening two windows, one zsh
-- and one PowerShell. With no command, `cmd` is nil and this behaves as before.
wezterm.on("gui-startup", function(cmd)
	-- A command from the CLI is spawned by WezTerm itself; spawning it here as
	-- well produces two windows. Stand aside and let it do that.
	if cmd then
		return
	end
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

-- Send the Kitty keyboard protocol so combos like Ctrl+. and Ctrl+, reach
-- apps distinctly. Without it, terminals fall back to clearing the top bits
-- of the key's ASCII code, which makes Ctrl+. collide with Ctrl+N and
-- Ctrl+, collide with Ctrl+L.
--
-- This only takes effect once the running app *asks* for the protocol, which
-- Neovim does -- but only when it is talking to WezTerm directly. Under tmux
-- the app on the other end is tmux, and tmux never asks for Kitty; it asks
-- for xterm's modifyOtherKeys instead, which WezTerm does not answer. So in
-- the WezTerm > WSL > tmux > Neovim stack nothing distinct was being sent and
-- the keys silently did nothing. See CSI_U below.
config.enable_kitty_keyboard = true

-- Emit the CSI u encoding for a key ourselves, instead of waiting to be asked
-- for it. CSI u spells a key out as <ESC>[<codepoint>;<mods>u, so Ctrl+. is
-- ESC [46;5u (46 = ".", 5 = 1 + 4 for Ctrl).
--
-- tmux decodes these on input regardless of which protocol it negotiated
-- upstream, then re-encodes them for Neovim in whatever format its
-- extended-keys-format says -- so the whole chain works without depending on
-- WezTerm and tmux agreeing on a protocol. Neovim reading WezTerm directly
-- gets the same bytes the Kitty protocol would have produced, so nothing
-- regresses outside tmux.
local function csi_u(codepoint, mods)
	return wezterm.action.SendString("\x1b[" .. codepoint .. ";" .. mods .. "u")
end

local CTRL = 5 -- 1 + 4

-- Key bindings
config.keys = {
	-- Ctrl+. and Ctrl+, -- ToggleTerm in LazyVim.
	{ key = ".", mods = "CTRL", action = csi_u(46, CTRL) },
	{ key = ",", mods = "CTRL", action = csi_u(44, CTRL) },
	-- Ctrl+; -- tmux copy-mode in a shell, exit terminal mode inside Neovim.
	{ key = ";", mods = "CTRL", action = csi_u(59, CTRL) },
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
