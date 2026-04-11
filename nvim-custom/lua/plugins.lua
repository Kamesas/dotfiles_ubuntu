-- vim.pack is Neovim 0.12's built-in plugin manager.
-- First run clones each plugin under ~/.local/share/nvim-custom/site/pack/
-- and adds them to runtimepath synchronously.

vim.pack.add({
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
})

-- Colorscheme
pcall(vim.cmd.colorscheme, "tokyonight")

-- Mason: installs LSP servers, linters, formatters, and tree-sitter-cli into
-- ~/.local/share/nvim-custom/mason/ — no system packages needed.
-- mason.setup() prepends mason's bin dir to PATH so native vim.lsp.config()
-- finds the servers without any bridge plugin.
require("mason").setup({
  PATH = "prepend",
  ui = { border = "rounded" },
})

require("mason-tool-installer").setup({
  ensure_installed = {
    "typescript-language-server",
    "tailwindcss-language-server",
    "css-lsp",
    "lua-language-server",
    "tree-sitter-cli",
  },
  run_on_start = true,
  auto_update = false,
})

-- Treesitter (main-branch API). install() spawns the `tree-sitter` CLI to build
-- parsers from source, so it must run AFTER mason has finished downloading
-- tree-sitter-cli on first launch.
local function install_parsers()
  local ok, ts = pcall(require, "nvim-treesitter")
  if not ok then return end
  ts.install({
    "lua", "vim", "vimdoc", "query",
    "javascript", "typescript", "tsx",
    "css", "scss", "html",
    "json", "markdown", "markdown_inline",
  })
end

-- Best-effort attempt at startup (works on every launch after the first).
pcall(install_parsers)

-- On first launch, mason's downloads run async — hook into its completion event
-- so parsers install automatically once tree-sitter-cli is available.
vim.api.nvim_create_autocmd("User", {
  pattern = "MasonToolsUpdateCompleted",
  callback = function()
    pcall(install_parsers)
  end,
})

-- Enable treesitter highlighting for installed parsers
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "lua", "javascript", "javascriptreact",
    "typescript", "typescriptreact",
    "css", "scss", "html", "json", "markdown",
  },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- fzf-lua
local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
  fzf.setup({})
end
