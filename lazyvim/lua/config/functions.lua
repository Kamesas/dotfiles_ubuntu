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
