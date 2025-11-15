return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      {
        "folke/snacks.nvim",
        opts = {
          input = {},
          picker = {},
        },
      },
    },
    config = function()
      -- Force Neovim to use bash for terminal commands
      vim.o.shell = "/bin/bash"

      vim.g.opencode_opts = {
        auto_reload = true,
        opencode_binary = "/home/alex/.opencode/bin/opencode",
      }
      vim.opt.autoread = true

      -- Keymaps
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode about this" })

      vim.keymap.set({ "n", "x" }, "<leader>o+", function()
        require("opencode").prompt("@this")
      end, { desc = "Add this to opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select opencode prompt" })

      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode terminal" })

      vim.keymap.set("n", "<leader>on", function()
        require("opencode").command("session_new")
      end, { desc = "New opencode session" })

      vim.keymap.set({ "n", "x" }, "<leader>oe", function()
        local explain = require("opencode.config").opts.prompts.explain
        require("opencode").prompt(explain.prompt, explain)
      end, { desc = "Explain this code" })
    end,
  },
}
