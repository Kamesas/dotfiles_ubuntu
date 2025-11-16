local fn = require("config.functions")

vim.keymap.set("i", "<A-j>", "<Down>", { desc = "Move cursor down" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "Move cursor up" })
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move cursor right" })

-- Move lines up/down in normal and visual mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Fast escape from insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("i", "jj", "<esc>", { desc = "escape insert mode" })

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })

-- Add empty line below/above (like VSCode)
vim.keymap.set("n", "<C-m>", "o<Esc>", { desc = "Add line below" })
vim.keymap.set("n", "<C-Enter>", "o<Esc>", { desc = "Add line below" })
vim.keymap.set("n", "<C-S-Enter>", "O<Esc>", { desc = "Add line above" })

-- Delete without saving to register
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "ciw", '"_ciw', { desc = "Change inner word without yanking" })
vim.keymap.set("n", "caw", '"_caw', { desc = "Change inner word without yanking" })

vim.keymap.set({ "n", "x" }, "<C-x>", '"+d', { desc = "Cut to clipboard" })

-- Beginning and end of line (easier than ^ and $)
vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })

vim.keymap.set("n", "<leader>qw", function()
	require("persistence").save()
end, { desc = "Write Session" })

vim.keymap.set("n", "<C-z>", "<nop>")

-- LSP document symbols
vim.keymap.set("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "LSP Document Symbols" })

-- Console log word under cursor (inserts line below)
vim.keymap.set("n", "<leader>l", fn.console_log, { desc = "Console log" })
vim.keymap.set("n", "<leader>cj", fn.console_log_json, { desc = "Console log JSON" })
vim.keymap.set("n", "<leader>cx", ":%g/console.log/d<CR>", { desc = "Clear all console.logs" })
