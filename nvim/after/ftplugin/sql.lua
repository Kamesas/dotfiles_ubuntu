-- File: ~/.config/nvim/after/ftplugin/sql.lua
-- SQL-specific keymaps for dadbod database queries
if vim.fn.exists("*DB") == 0 then
  return
end

vim.keymap.set("n", "<leader>de", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute Query" })
vim.keymap.set("v", "<leader>dc", "<Plug>(DBUI_ExecuteRangeQuery)", { buffer = true, desc = "Execute Range Query" })
