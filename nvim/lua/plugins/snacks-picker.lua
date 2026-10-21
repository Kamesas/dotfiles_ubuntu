return {
  { "nvim-telescope/telescope.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    init = function()
      -- Inside tmux, snacks.image cannot see the outer terminal. WezTerm sets
      -- $WEZTERM_PANE, which tmux keeps, so use it to turn on WezTerm support.
      if vim.env.WEZTERM_PANE and not vim.env.SNACKS_WEZTERM then
        vim.env.SNACKS_WEZTERM = "1"
      end
    end,
    keys = {
      { "<leader>fr", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recent (cwd)" },
      { "<leader>fR", LazyVim.pick("oldfiles"), desc = "Recent (all)" },
    },
    opts = {
      -- Inside tmux this needs `allow-passthrough on` (tmux.conf).
      image = {
        enabled = true,
        -- No preview window when the cursor is on an image path, like <Image src="..."> in tsx
        doc = { float = false },
      },
      picker = {
        -- Preview is hidden at start. <a-p> shows it.
        layout = { hidden = { "preview" } },
        sources = {
          explorer = { hidden = false, ignored = true },
          grep = { hidden = true, ignored = true },
        },
      },
    },
  },
}
