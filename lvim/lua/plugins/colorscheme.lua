return {
  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
        },
      },
    },
  },

  -- Tokyo Night
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "storm", -- storm, moon, night, day
      transparent = false,
    },
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    opts = {
      transparent_mode = false,
    },
  },

  -- Rose Pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      variant = "moon", -- auto, main, moon, dawn
    },
  },

  -- Set as default
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "catppuccin-macchiato",
      colorscheme = "habamax",
      -- colorscheme = "rose-pine",
      -- colorscheme = "tokyonight",
    },
  },
}
