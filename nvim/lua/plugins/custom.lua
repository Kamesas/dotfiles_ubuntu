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
        -- TypeScript Language Server for component props and auto-imports
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "none",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              },
              suggest = {
                includeCompletionsForModuleExports = true,
                includeAutomaticOptionalChainCompletions = true,
              },
              preferences = {
                includePackageJsonAutoImports = "auto",
                importModuleSpecifierPreference = "relative",
                quotePreference = "double",
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "none",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              },
              suggest = {
                includeCompletionsForModuleExports = true,
                includeAutomaticOptionalChainCompletions = true,
              },
              preferences = {
                includePackageJsonAutoImports = "auto",
                importModuleSpecifierPreference = "relative",
                quotePreference = "double",
              },
            },
          },
        },
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

          -- Rename File with Auto-Update Imports (TypeScript/JavaScript only)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "ts_ls" then
            map("<leader>cR", function()
              local source_file = vim.api.nvim_buf_get_name(event.buf)
              vim.ui.input({
                prompt = "New file path: ",
                default = source_file,
                completion = "file",
              }, function(target_file)
                if target_file and target_file ~= source_file then
                  local params = {
                    command = "_typescript.applyRenameFile",
                    arguments = {
                      {
                        sourceUri = vim.uri_from_fname(source_file),
                        targetUri = vim.uri_from_fname(target_file),
                      },
                    },
                  }
                  vim.lsp.buf.execute_command(params)
                  vim.cmd("e " .. target_file)
                end
              end)
            end, "Rename File (Update Imports)")
          end
        end,
      })
    end,
  },
}
