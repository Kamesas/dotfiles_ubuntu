-- Neovim config for VS Code
-- This file is loaded by vscode-neovim extension

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          keys = { "F", "t", "T", ";", "," }, -- removed "f" from char mode
        },
      },
    },
    keys = {
      { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },
  {
    "echasnovski/mini.surround",
    version = false,
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
    init = function()
      vim.g.VM_default_mappings = 1
    end,
  },
})

-- Options
vim.opt.clipboard = "unnamedplus"
vim.o.relativenumber = false

-- Functions
local fn = {}

fn.console_log = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', %s)", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

fn.console_log_json = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', JSON.stringify(%s, null, 2))", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

fn.copy_for_claude = function()
  local filepath = vim.fn.expand("%:.")
  local pos1 = vim.fn.line("v")
  local pos2 = vim.fn.line(".")
  local line_start = math.min(pos1, pos2)
  local line_end = math.max(pos1, pos2)
  local lines = vim.fn.getline(line_start, line_end)
  local code = table.concat(lines, "\n")
  local output = string.format("File: %s:%d-%d\n---\n%s", filepath, line_start, line_end, code)
  vim.fn.setreg("+", output)
  vim.cmd([[execute "normal! \<Esc>"]])
  vim.notify("Copied to clipboard for Claude Code!", vim.log.levels.INFO)
end

fn.add_todo = function()
  local date = os.date("%Y-%m-%d")
  local line = string.format("// TODO: (Alex %s): ", date)
  vim.api.nvim_put({ line }, "c", false, true)
  vim.cmd("startinsert!")
end

fn.comment_block = function()
  local lines = {
    "// ====================================================================",
    "// ",
    "// ====================================================================",
  }
  vim.api.nvim_put(lines, "l", true, true)
  vim.cmd("normal! k$")
  vim.cmd("startinsert!")
end

-- Keymaps
-- Fast escape from insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })

-- Beginning/end of line
vim.keymap.set({ "n", "x", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "x", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Add empty line below
vim.keymap.set("n", "<C-Enter>", "o<Esc>", { desc = "Add line below" })

-- Delete without saving to register
vim.keymap.set({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "dd", '"_dd', { desc = "Delete line without yanking" })
vim.keymap.set("n", "ciw", '"_ciw', { desc = "Change inner word without yanking" })
vim.keymap.set("n", "caw", '"_caw', { desc = "Change a word without yanking" })

-- Cut to clipboard
vim.keymap.set({ "n", "x" }, "<C-x>", '"+d', { desc = "Cut to clipboard" })

-- Disable Ctrl+z (suspend)
vim.keymap.set("n", "<C-z>", "<nop>")

-- Ctrl+Backspace to delete word backward in insert mode
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward" })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backward" })

-- Console log
vim.keymap.set("n", "<leader>l", fn.console_log, { desc = "Console log" })
vim.keymap.set("n", "<leader>cj", fn.console_log_json, { desc = "Console log JSON" })
vim.keymap.set("n", "<leader>cx", ":%g/console.log/d<CR>", { desc = "Clear all console.logs" })

-- Copy selection for Claude Code
vim.keymap.set("v", "<leader>cs", fn.copy_for_claude, { desc = "Copy for Claude Code" })

-- Add TODO comment
vim.keymap.set("n", "<leader>ct", fn.add_todo, { desc = "Add TODO" })

-- Insert comment block separator
vim.keymap.set("n", "gcb", fn.comment_block, { desc = "Comment block" })
