local M = {}

-- Console.log word under cursor
M.console_log = function()
	local word = vim.fn.expand("<cword>")
	local line = string.format("console.log('%s --->:', %s)", word, word)
	vim.api.nvim_put({ line }, "l", true, true)
end

-- JSON.stringify for objects
M.console_log_json = function()
	local word = vim.fn.expand("<cword>")
	local line = string.format("console.log('%s --->:', JSON.stringify(%s, null, 2))", word, word)
	vim.api.nvim_put({ line }, "l", true, true)
end

-- Copy selection to clipboard with file context
M.copy_for_claude = function()
	-- Get file info
	local filepath = vim.fn.expand("%:.")
	local line_start = vim.fn.line("'<")
	local line_end = vim.fn.line("'>")
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

return M
