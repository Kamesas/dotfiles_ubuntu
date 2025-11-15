local M = {}

-- Console.log word under cursor
M.console_log = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s:', %s)", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

-- JSON.stringify for objects
M.console_log_json = function()
  local word = vim.fn.expand("<cword>")
  local line = string.format("console.log('%s:', JSON.stringify(%s, null, 2))", word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end

return M
