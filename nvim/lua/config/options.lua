-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Keep the eslint LSP for diagnostics only. Its format-on-save is slow and
-- freezes the cursor. eslint_d runs the fixes instead (see plugins/conform.lua).
vim.g.lazyvim_eslint_auto_format = false

vim.o.relativenumber = false
vim.opt.spelllang = { "en_us" }
