-- Neovim config for VS Code
-- This file is loaded by vscode-neovim extension

-- Use system clipboard for all yank/paste operations
vim.opt.clipboard = "unnamedplus"

-- Go to beginning/end of line (like your lvim config)
vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Delete without saving to register (like your lvim config)
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "ciw", '"_ciw', { desc = "Change inner word without yanking" })
vim.keymap.set("n", "caw", '"_caw', { desc = "Change a word without yanking" })

-- Cut to clipboard (since d doesn't yank anymore)
vim.keymap.set({ "n", "x" }, "x", '"+d', { desc = "Cut to clipboard" })
