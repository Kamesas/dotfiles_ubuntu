-- TypeScript Tools for better file operations and import management
return {
  -- Install typescript-tools.nvim for enhanced TypeScript support
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      -- Disable code lens
      code_lens = "off",
      
      settings = {
        -- Completely disable all inlay hints
        typescript_inlay_hints = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        javascript_inlay_hints = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },
        -- TypeScript server file preferences
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          quotePreference = "double",
          importModuleSpecifierPreference = "relative",
          importModuleSpecifierEnding = "auto",
        },
        -- Enable auto-import updates on file rename/move
        tsserver_plugins = {},
      },
    },
    config = function(_, opts)
      require("typescript-tools").setup(opts)
      
      -- Set up keymaps for TypeScript-specific operations
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(event)
          -- Forcefully disable inlay hints for TypeScript files
          vim.defer_fn(function()
            vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
          end, 100)
          
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "TS: " .. desc })
          end
          
          -- File operations with auto-import updates
          map("<leader>cR", ":TSToolsRenameFile<CR>", "Rename File (Update Imports)")
          map("<leader>co", ":TSToolsOrganizeImports<CR>", "Organize Imports")
          map("<leader>cO", ":TSToolsSortImports<CR>", "Sort Imports")
          map("<leader>cu", ":TSToolsRemoveUnused<CR>", "Remove Unused Imports")
          map("<leader>cF", ":TSToolsFixAll<CR>", "Fix All")
          map("<leader>cA", ":TSToolsAddMissingImports<CR>", "Add Missing Imports")
          
          -- Additional useful commands
          map("<leader>cI", ":TSToolsGoToSourceDefinition<CR>", "Go to Source Definition")
          map("<leader>cD", ":TSToolsFileReferences<CR>", "File References")
        end,
      })
    end,
  },

  -- Disable ts_ls from the custom.lua since typescript-tools provides its own server
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Make sure ts_ls doesn't conflict with typescript-tools
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = opts.servers.ts_ls or {}
      opts.servers.ts_ls.enabled = false
      
      return opts
    end,
  },
}
