return {
  { "nvim-telescope/telescope.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fw",
        function()
          Snacks.picker.files({ cwd = vim.fn.expand("~/Documents/notes") })
        end,
        desc = "Find Wiki Files",
      },
    },
  },
}
