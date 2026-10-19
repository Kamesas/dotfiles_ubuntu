return {
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    -- Sonokai reads its g: options when the colorscheme loads, so set them
    -- in init. LazyVim applies the colorscheme itself (opts below).
    init = function()
      vim.g.sonokai_enable_italic = true
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "macchiato" } },
  { "folke/tokyonight.nvim", opts = { style = "storm" } },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, opts = { variant = "moon" } },

  {
    "LazyVim/LazyVim",
    opts = {
      -- Also installed: catppuccin, tokyonight, gruvbox, rose-pine, habamax
      colorscheme = "sonokai",
    },
  },
}
