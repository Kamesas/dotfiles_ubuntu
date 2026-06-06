return {
  "folke/snacks.nvim",
  init = function()
    -- Inside tmux, $TERM/$TERM_PROGRAM are masked to "tmux", so snacks.image
    -- can't detect the outer terminal and wrongly reports "no kitty graphics
    -- protocol". WezTerm (which DOES support it) sets $WEZTERM_PANE, which
    -- survives tmux — use it to force snacks' wezterm detection on.
    if vim.env.WEZTERM_PANE and not vim.env.SNACKS_WEZTERM then
      vim.env.SNACKS_WEZTERM = "1"
    end
  end,
  opts = {
    -- Image preview: shows image files when opened, renders images inline in
    -- markdown, and powers image previews in the picker. Uses the terminal
    -- graphics protocol (WezTerm/Kitty). Inside tmux this needs
    -- `allow-passthrough on` (set in ~/.config/tmux/tmux.conf).
    image = { enabled = true },
    picker = {
      -- Start every picker with the preview pane hidden. This stops images
      -- (and other files) from being previewed as you move the cursor.
      -- Press <a-p> (Alt+p) inside the picker to show the preview when you
      -- actually want it.
      layout = { hidden = { "preview" } },
      sources = {
        -- explorer = { hidden = true, ignored = true },
        -- files = { hidden = true, ignored = true },
        grep = { hidden = true, ignored = true },
      },
    },
  },
}
