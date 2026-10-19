return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "marilari88/neotest-vitest",
  },
  -- stylua: ignore
  keys = {
    { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Test Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show Test Output" },
    { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last Test" },
    { "<leader>tx", function() require("neotest").run.stop() end, desc = "Stop Test" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
      },
    })
  end,
}
