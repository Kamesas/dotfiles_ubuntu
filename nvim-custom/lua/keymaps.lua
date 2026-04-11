local map = vim.keymap.set

-- Basics
map("i", "jk", "<Esc>", { desc = "Escape insert" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all (force)" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- fzf-lua pickers
map("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Doc diagnostics" })

-- Netrw explorer sidebar
map("n", "<leader>e", "<cmd>Vex<cr>", { desc = "Open explorer (Vex)" })
