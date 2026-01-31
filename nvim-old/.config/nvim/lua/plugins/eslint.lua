return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Auto-start ESLint for TypeScript/JavaScript files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        callback = function()
          vim.cmd("LspStart eslint")
        end,
      })
    end,
  },
}
