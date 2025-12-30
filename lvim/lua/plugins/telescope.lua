return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Override or add telescope keybindings
      {
        "<leader>fw",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Documents/ObsidianVault") })
        end,
        desc = "Find Wiki Files",
      },
    },
  },
}
