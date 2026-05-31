-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local fn = require("config.functions")

-- Fast escape from insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Move lines up/down in normal and visual mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Buffer reordering
vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })

-- Add empty line below/above
vim.keymap.set("n", "<C-Enter>", "o<Esc>", { desc = "Add line below" })

-- Delete without saving to register
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "ciw", '"_ciw', { desc = "Change inner word without yanking" })
vim.keymap.set("n", "caw", '"_caw', { desc = "Change inner word without yanking" })

-- Cut to clipboard
vim.keymap.set({ "n", "x" }, "<C-x>", '"+d', { desc = "Cut to clipboard" })

-- Disables Ctrl+z (suspends Neovim to background)
vim.keymap.set("n", "<C-z>", "<nop>")

-- Go to definition in vertical split
vim.keymap.set("n", "gV", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Go to Definition (vsplit)" })

-- Console log word under cursor (inserts line below)
vim.keymap.set("n", "<leader>l", fn.console_log, { desc = "Console log" })
vim.keymap.set("n", "<leader>cj", fn.console_log_json, { desc = "Console log JSON" })
vim.keymap.set("n", "<leader>cx", ":%g/console.log/d<CR>", { desc = "Clear all console.logs" })

-- Copy selection to clipboard for Claude Code
vim.keymap.set("v", "<leader>cs", fn.copy_for_claude, { desc = "Copy for Claude Code (Send)" })

-- Add TODO comment with your name and date
vim.keymap.set("n", "<leader>ct", fn.add_todo, { desc = "Add TODO" })

-- Insert comment block separator
vim.keymap.set("n", "gcb", fn.comment_block, { desc = "Go Comment Block" })

-- Zoom/maximize current window (toggle)
vim.keymap.set("n", "<leader>wz", fn.zoom_toggle, { desc = "Toggle zoom window" })

-- Enter in insert mode → call blink directly (bypasses nvim-autopairs stealing CR)
vim.keymap.set("i", "<CR>", function()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    local handled = blink.accept()
    if handled then return end
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
end, { desc = "Accept completion or newline" })

-- Arrow keys in insert mode → call blink directly so Enter still works
vim.keymap.set("i", "<Down>", function()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    local handled = blink.select_next()
    if handled then return end
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, true, true), "n", true)
end, { desc = "Next completion or move down" })
vim.keymap.set("i", "<Up>", function()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    local handled = blink.select_prev()
    if handled then return end
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, true, true), "n", true)
end, { desc = "Prev completion or move up" })

-- Ctrl+Backspace to delete word backward in insert mode
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backward" })

