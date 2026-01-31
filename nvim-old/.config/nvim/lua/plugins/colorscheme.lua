return {
  {
    "folke/tokyonight.nvim", -- or whatever colorscheme you use
    lazy = false, -- Load immediately, not lazily
    priority = 1000, -- Load before other plugins
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}
