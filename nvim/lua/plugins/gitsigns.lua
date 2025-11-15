return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- Show at end of line
      delay = 100, -- Show blame after 100ms when cursor stops
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",
    current_line_blame_formatter_opts = {
      relative_time = true,
    },
  },
}
