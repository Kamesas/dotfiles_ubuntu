return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>d", group = "dad bod", icon = "󰆼" },
        { "<leader>D", group = "debug", icon = " " },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    -- stylua: ignore
    keys = {
      -- Disable LazyVim's default <leader>d bindings
      { "<leader>dB", false },
      { "<leader>db", false },
      { "<leader>dc", false },
      { "<leader>dC", false },
      { "<leader>da", false },
      { "<leader>dg", false },
      { "<leader>di", false },
      { "<leader>dj", false },
      { "<leader>dk", false },
      { "<leader>dl", false },
      { "<leader>do", false },
      { "<leader>dO", false },
      { "<leader>dp", false },
      { "<leader>dr", false },
      { "<leader>ds", false },
      { "<leader>dt", false },
      { "<leader>dw", false },
      -- Our <leader>D bindings
      { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>DB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
      { "<leader>Dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>DC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>Dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>Di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>Dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>Dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>Dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>Do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>DO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>Dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>Dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>Ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>Dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>Dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    -- stylua: ignore
    keys = {
      { "<leader>du", false },
      { "<leader>de", false },
      { "<leader>Du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>De", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
    },
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
    },
    config = function(_, opts)
      require("dap-vscode-js").setup(opts)

      local dap = require("dap")

      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
