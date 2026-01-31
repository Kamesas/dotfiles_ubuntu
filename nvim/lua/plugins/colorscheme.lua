return {
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.sonokai_enable_italic = true
      vim.cmd.colorscheme("sonokai")
    end,
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        mini = true,
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        snacks = true,
        telescope = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.special.bufferline").get_theme()
          end
        end,
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
      colorscheme = "sonokai",
      -- colorscheme = "catppuccin",
      -- colorscheme = "habamax",
      -- colorscheme = "rose-pine",
      -- colorscheme = "tokyonight",
    },
  },
}
