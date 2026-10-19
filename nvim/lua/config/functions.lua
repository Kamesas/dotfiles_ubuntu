local M = {}

M.console_log = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', %s)", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

M.console_log_json = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s --->:', JSON.stringify(%s, null, 2))", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

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

M.copy_for_claude = function()
  local filepath = vim.fn.expand("%:p")
  -- "v" and ".", not "'<" and "'>": those marks update only after visual mode ends
  local pos1 = vim.fn.line("v")
  local pos2 = vim.fn.line(".")
  local line_start = math.min(pos1, pos2)
  local line_end = math.max(pos1, pos2)

  local code = table.concat(vim.fn.getline(line_start, line_end), "\n")
  vim.fn.setreg("+", string.format("File: %s:%d-%d\n---\n%s", filepath, line_start, line_end, code))

  vim.cmd([[execute "normal! \<Esc>"]])
  vim.notify("Copied to clipboard for Claude Code!", vim.log.levels.INFO)
end

M.add_todo = function()
  local line = string.format("// TODO: (Alex %s): ", os.date("%Y-%m-%d"))
  vim.api.nvim_put({ line }, "c", false, true)
  vim.cmd("startinsert!")
end

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
