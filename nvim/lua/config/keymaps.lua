-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local fn = require("config.functions")

vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })

vim.keymap.set("n", "<C-Enter>", "o<Esc>", { desc = "Add line below" })

vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "x" }, "<C-x>", '"+d', { desc = "Cut to clipboard" })

vim.keymap.set("n", "<leader>qw", function()
  require("persistence").save()
end, { desc = "Write Session" })

vim.keymap.set("n", "<C-z>", "<nop>", { desc = "Do not suspend nvim" })

vim.keymap.set("n", "gV", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Go to Definition (vsplit)" })

vim.keymap.set("n", "<leader>l", fn.console_log, { desc = "Console log" })
vim.keymap.set("n", "<leader>cj", fn.console_log_json, { desc = "Console log JSON" })
vim.keymap.set("n", "<leader>cx", ":%g/console.log/d<CR>", { desc = "Clear all console.logs" })

vim.keymap.set("v", "<leader>cs", fn.copy_for_claude, { desc = "Copy for Claude Code (Send)" })
vim.keymap.set("n", "<leader>ct", fn.add_todo, { desc = "Add TODO" })
vim.keymap.set("n", "gcb", fn.comment_block, { desc = "Go Comment Block" })
vim.keymap.set("n", "<leader>wz", fn.zoom_toggle, { desc = "Toggle zoom window" })

-- <C-H> is what most terminals send for Ctrl+Backspace
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backward" })
