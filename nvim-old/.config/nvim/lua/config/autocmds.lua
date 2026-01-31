-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)

-- Disable LSP semantic tokens to prevent conflicts with Treesitter
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
  desc = "Disable LSP semantic tokens to fix Treesitter highlighting",
})

-- Force re-enable syntax highlighting when entering buffers
-- This fixes the issue where highlighting is lost after opening files from Telescope
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function()
    -- Re-enable treesitter highlighting
    if vim.fn.exists(":TSBufEnable") > 0 then
      vim.cmd("TSBufEnable highlight")
    end
  end,
  desc = "Ensure Treesitter highlighting stays enabled",
})

-- Additional fix: ensure colorscheme is applied after buffer operations
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    -- Reapply colorscheme if it seems to be lost
    local current_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    if not current_bg or current_bg == 0 then
      vim.cmd("colorscheme tokyonight")
    end
  end,
  desc = "Reapply colorscheme if lost",
})
