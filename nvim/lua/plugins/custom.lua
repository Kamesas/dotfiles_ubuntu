-- File: ~/.config/nvim/lua/plugins/custom.lua
-- THIS IS NOW YOUR ONLY FILE FOR PERSONAL SETTINGS
return {
  -- 1. FORMATTING
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua" },
      },
    },
  },

  -- 2. LSP CONFIGURATION (Consolidated - Tailwind, TypeScript, Auto-imports, Keybindings)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Tailwind CSS Language Server
        tailwindcss = {
          settings = {
            tailwindCSS = {
              classAttributes = { "class", "className", "classList", "ngClass" },
              lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidConfigPath = "error",
                invalidScreen = "error",
                invalidTailwindDirective = "error",
                invalidVariant = "error",
                recommendedVariantOrder = "warning",
              },
              validate = true,
            },
          },
        },
        -- Note: TypeScript is now handled by typescript-tools.nvim (see typescript.lua)
      },
    },
    init = function()
      -- Set up keybindings when LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- LSP Navigation
          map("gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("gr", vim.lsp.buf.references, "Go to References")
          map("gd", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
          end, "Go to Definition in Split")

          -- Code Actions and Auto-Import
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>ai", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = {
                only = { "source.addMissingImports" },
                diagnostics = {},
              },
            })
          end, "Add Missing Imports")
          
          -- Note: TypeScript-specific keymaps (like <leader>cR for rename file)
          -- are now in typescript.lua using typescript-tools.nvim
        end,
      })
    end,
  },
}
