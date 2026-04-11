-- nvim-custom: minimal Neovim config for experimenting with 0.12 features.
-- Launch with alias `n` (sets NVIM_APPNAME=nvim-custom).
--
-- Prerequisites on a new machine: nvim 0.12+, git, node, npm.
-- Everything else — LSPs, tree-sitter-cli, parsers — auto-installs on first
-- launch via Mason. No system packages, no install scripts.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")
require("plugins")
require("lsp")
