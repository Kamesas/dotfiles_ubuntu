return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "<A-.>", "<cmd>1ToggleTerm direction=float<cr>", desc = "Toggle floating terminal", mode = { "n", "t" } },
    { "<A-/>", "<cmd>2ToggleTerm direction=float<cr>", desc = "Toggle floating terminal", mode = { "n", "t" } },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 20
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.9)
      end,
      winblend = 0,
    },
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
    env = { TERM = "xterm-256color" },
  },
}
