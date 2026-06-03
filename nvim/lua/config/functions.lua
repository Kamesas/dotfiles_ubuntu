local M = {}

-- Console.log word under cursor
M.console_log = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', %s)", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

-- Insert comment block separator
M.comment_block = function()
  local lines = {
    "// ====================================================================",
    "// ",
    "// ====================================================================",
  }
  vim.api.nvim_put(lines, "l", true, true)
  -- Move cursor to middle line and position at end for typing
  vim.cmd("normal! k$")
  vim.cmd("startinsert!")
end

-- JSON.stringify for objects
M.console_log_json = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', JSON.stringify(%s, null, 2))", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

-- Copy selection to clipboard with file context
M.copy_for_claude = function()
  -- Get file info — always use the full absolute path so the file can be
  -- resolved from anywhere (any repo, the Obsidian vault, scratch files),
  -- regardless of nvim's cwd. `%:.` collapsed subfolders to a bare basename
  -- (e.g. "DOCS.md" instead of the real location), which is ambiguous.
  local filepath = vim.fn.expand("%:p")
  -- Use "v" and "." to get current visual selection (not '< '> which update after leaving visual mode)
  local pos1 = vim.fn.line("v")
  local pos2 = vim.fn.line(".")
  local line_start = math.min(pos1, pos2)
  local line_end = math.max(pos1, pos2)
  -- Get selected lines
  local lines = vim.fn.getline(line_start, line_end)
  local code = table.concat(lines, "\n")
  -- Format with context
  local output = string.format("File: %s:%d-%d\n---\n%s", filepath, line_start, line_end, code)
  -- Copy to system clipboard
  vim.fn.setreg("+", output)
  -- Exit visual mode
  vim.cmd([[execute "normal! \<Esc>"]])
  -- Notify user
  vim.notify("Copied to clipboard for Claude Code!", vim.log.levels.INFO)
end

-- Add TODO comment with your name and date
M.add_todo = function()
  local date = os.date("%Y-%m-%d")
  local line = string.format("// TODO: (Alex %s): ", date)
  vim.api.nvim_put({ line }, "c", false, true)
  vim.cmd("startinsert!")
end

-- Toggle window zoom (maximize/restore)
M.zoom_toggle = function()
  if vim.t.zoomed then
    vim.cmd("wincmd =")
    vim.t.zoomed = false
  else
    vim.cmd("wincmd _")
    vim.cmd("wincmd |")
    vim.t.zoomed = true
  end
end

return M
