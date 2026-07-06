-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable inlay hints by default (LazyVim setting)
vim.g.lazyvim_inlay_hints_enabled = false

-- Keep the eslint LSP for diagnostics only. Its format-on-save is synchronous
-- and freezes the cursor; eslint fixes run async via eslint_d instead
-- (see autocmds.lua).
vim.g.lazyvim_eslint_auto_format = false

vim.o.relativenumber = false

-- vim.o.exrc = true
