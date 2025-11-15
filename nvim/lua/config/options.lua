-- Set leader key early, before lazy.nvim startup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Options are automatically loaded before lazy.nvim startup Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
-- Configure diagnostic display settings
vim.diagnostic.config({
  -- Show diagnostic messages inline next to problematic code
  virtual_text = true,

  -- Show diagnostic symbols (icons) in the left gutter/sign column
  signs = true,

  -- Underline problematic code with wavy/squiggly lines
  underline = true,

  -- Don't update diagnostics while you're actively typing (only after you stop)
  update_in_insert = false,

  -- Sort diagnostics by severity: errors first, then warnings, then info, etc.
  severity_sort = true,
})
