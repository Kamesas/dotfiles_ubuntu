-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    local ts_api = package.loaded["typescript-tools.api"]
    if ts_api then ts_api.request_diagnostics() end
  end,
})
