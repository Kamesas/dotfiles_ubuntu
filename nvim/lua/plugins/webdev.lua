return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- No typescript-language-server: typescript-tools.nvim starts tsserver itself.
        "tailwindcss-language-server",
        "css-lsp",
        "html-lsp",
        "emmet-ls",
        "eslint-lsp",
        "prettierd",
        "eslint_d",
        "js-debug-adapter",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        vtsls = { enabled = false },
        ts_ls = { enabled = false },
        tailwindcss = {
          on_attach = function(_, bufnr)
            -- Turn off the color swatches tailwindcss sends. The API only
            -- exists on nvim 0.12+, so 0.11 has nothing to turn off.
            if vim.lsp.document_color then
              vim.lsp.document_color.enable(false, { bufnr = bufnr })
            end
          end,
          settings = {
            tailwindCSS = {
              lint = {
                suggestCanonicalClasses = "ignore",
              },
              experimental = {
                classRegex = {
                  { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                },
              },
            },
          },
        },
        html = {},
        cssls = {},
        emmet_ls = {
          filetypes = { "html", "typescriptreact", "javascriptreact", "css" },
        },
      },
    },
  },

  -- Used instead of vtsls because it updates imports when a file is renamed (willRenameFiles)
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      on_attach = function(_, bufnr)
        vim.keymap.set(
          "n",
          "<leader>ci",
          "<cmd>TSToolsAddMissingImports<cr>",
          { buffer = bufnr, desc = "Add All Missing Imports" }
        )
      end,
      settings = {
        -- Auto-import uses the path alias (@/...). Projects without one get relative paths.
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "css" })
    end,
  },

  {
    "vuki656/package-info.nvim",
    event = "BufRead package.json",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 100,
      },
    },
  },
}
