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

  -- 3. LSP CONFIGURATION FOR TAILWIND AND COMPONENT AUTOCOMPLETION
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
        -- TypeScript Language Server for component props
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
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
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
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
  },

  -- 4. ENHANCED COMPLETION
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      -- Ensure LSP has highest priority for autocompletion
      for i, source in ipairs(opts.sources) do
        if source.name == "nvim_lsp" then
          source.priority = 1000
        end
      end
    end,
  },

  -- 5. FORCE LSP AUTOSTART (debugging)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      -- Setup servers
      local lspconfig = require("lspconfig")

      -- Force Tailwind to start
      lspconfig.tailwindcss.setup({
        autostart = true,
        settings = opts.servers and opts.servers.tailwindcss and opts.servers.tailwindcss.settings or {
          tailwindCSS = {
            classAttributes = { "class", "className", "classList", "ngClass" },
            validate = true,
          },
        },
      })

      -- Force TypeScript to start
      lspconfig.ts_ls.setup({
        autostart = true,
        settings = opts.servers and opts.servers.ts_ls and opts.servers.ts_ls.settings or {
          typescript = {
            suggest = {
              includeCompletionsForModuleExports = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
          javascript = {
            suggest = {
              includeCompletionsForModuleExports = true,
            },
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
        },
      })
    end,
  },

  -- 6. LSP KEYBINDINGS
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Set up keybindings when LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- map('gd', vim.lsp.buf.definition, 'Go to Definition')
          map("gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("gr", vim.lsp.buf.references, "Go to References")
          map("gd", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
          end, "Go to Definition in Split")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action (including Add Missing Import)")
          map("<leader>ci", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = {
                only = { "source.addMissingImports.ts" },
                diagnostics = {},
              },
            })
          end, "Add Missing Imports")
        end,
      })
    end,
  },
}
