-- Config for the PowerShell dropdown (Alt+E in sway.ahk), passed with
-- --config-file. It loads the shared .wezterm.lua and adds WezTerm's own tabs
-- and panes, using the same letters as ~/.config/tmux/tmux.reset.conf.
--
-- There is no tmux in this window, so these keys can be plain Alt combos with
-- no prefix. The WSL dropdown never reads this file, so nothing here can reach
-- tmux or Neovim.
--
-- Alt+W and Alt+E belong to sway.ahk and never reach WezTerm, so they are not
-- used below. Alt+Shift is Windows' keyboard-layout switch (three layouts are
-- installed and HKCU\Keyboard Layout\Toggle is unset), so it is avoided too.
local wezterm = require("wezterm")

local config = dofile(wezterm.home_dir .. "/.wezterm.lua")

-- WezTerm reloads only the file it was told to load. Watch the shared one too,
-- so editing it still refreshes this window.
wezterm.add_to_config_reload_watch_list(wezterm.home_dir .. "/.wezterm.lua")

-- The shared config hides the tab bar. Here it is the only way to see tabs.
-- Set hide_tab_bar_if_only_one_tab to false to keep it on screen always.
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 24

-- The shared config forwards Alt+<number> to tmux. Nothing to forward to here,
-- so drop those and give the keys to tab switching below.
local keys = {}
for _, k in ipairs(config.keys) do
	if not (k.mods == "ALT" and type(k.key) == "string" and k.key:match("^%d$")) then
		table.insert(keys, k)
	end
end

local act = wezterm.action

local function bind(key, mods, action)
	table.insert(keys, { key = key, mods = mods, action = action })
end

-- Tabs = tmux windows. Alt+d and Alt+s are what tmux itself uses, no prefix.
bind("n", "ALT", act.SpawnTab("CurrentPaneDomain"))
bind("d", "ALT", act.ActivateTabRelative(1))
bind("s", "ALT", act.ActivateTabRelative(-1))
for i = 1, 9 do
	bind(tostring(i), "ALT", act.ActivateTab(i - 1))
end

-- Panes. tmux's split letters s and v are taken by the tab keys above, so the
-- splits sit on the two keys that draw the line they make.
bind("-", "ALT", act.SplitVertical({ domain = "CurrentPaneDomain" }))
bind("\\", "ALT", act.SplitHorizontal({ domain = "CurrentPaneDomain" }))

bind("h", "ALT", act.ActivatePaneDirection("Left"))
bind("j", "ALT", act.ActivatePaneDirection("Down"))
bind("k", "ALT", act.ActivatePaneDirection("Up"))
bind("l", "ALT", act.ActivatePaneDirection("Right"))

bind("z", "ALT", act.TogglePaneZoomState)
-- tmux's kill-pane does not ask either. Set confirm = true to be asked.
bind("c", "ALT", act.CloseCurrentPane({ confirm = false }))

bind("LeftArrow", "ALT", act.AdjustPaneSize({ "Left", 5 }))
bind("DownArrow", "ALT", act.AdjustPaneSize({ "Down", 3 }))
bind("UpArrow", "ALT", act.AdjustPaneSize({ "Up", 3 }))
bind("RightArrow", "ALT", act.AdjustPaneSize({ "Right", 5 }))

config.keys = keys

return config
