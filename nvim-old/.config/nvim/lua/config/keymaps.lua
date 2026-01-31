local fn = require("config.functions")
-- candidates for removing:
-- 1. Fast escape from insert mode
vim.keymap.set("i", "jj", "<esc>", { desc = "escape insert mode" })
-- 2.Save file
vim.keymap.set("n", "<A-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<A-s>", "<Esc><cmd>w<CR>", { desc = "Save file and stay in normal mode" })
-- 3. Add line below/above
vim.keymap.set("n", "<C-Enter>", "o<Esc>", { desc = "Add line below" })
vim.keymap.set("n", "<C-S-Enter>", "O<Esc>", { desc = "Add line above" })
-- 4. Beginning and end of line (easier than ^ and $)
vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })
-- TODO: end of candidates for removing list.

-- 1. Fast escape from insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
-- Move lines up/down in normal and visual mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Buffer reordering
vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })

-- Add empty line below/above
vim.keymap.set("n", "<C-m>", "o<Esc>", { desc = "Add line below" })
-- vim.keymap.set("n", "<C-k>", "O<Esc>", { desc = "Add line above" })

-- Delete without saving to register
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "ciw", '"_ciw', { desc = "Change inner word without yanking" })
vim.keymap.set("n", "caw", '"_caw', { desc = "Change inner word without yanking" })

-- Cut to clipboard
vim.keymap.set({ "n", "x" }, "<C-x>", '"+d', { desc = "Cut to clipboard" })

-- Save current session
vim.keymap.set("n", "<leader>qw", function()
	require("persistence").save()
end, { desc = "Write Session" })

-- Disables the default Ctrl+z behavior which suspends Neovim and sends it to background (you'd need fg command to bring it back)
vim.keymap.set("n", "<C-z>", "<nop>")

-- LSP document symbols
vim.keymap.set("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "LSP Document Symbols" })

-- Console log word under cursor (inserts line below)
vim.keymap.set("n", "<leader>l", fn.console_log, { desc = "Console log" })
vim.keymap.set("n", "<leader>cj", fn.console_log_json, { desc = "Console log JSON" })
vim.keymap.set("n", "<leader>cx", ":%g/console.log/d<CR>", { desc = "Clear all console.logs" })

-- Copy selection to clipboard for Claude Code
vim.keymap.set("v", "<leader>cs", fn.copy_for_claude, { desc = "Copy for Claude Code (Send)" })

-- Add TODO comment with your name and date
vim.keymap.set("n", "<leader>ct", fn.add_todo, { desc = "Add TODO" })
