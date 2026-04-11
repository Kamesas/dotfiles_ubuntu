return {
  { "nvim-telescope/telescope.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fw",
        function()
          Snacks.picker.files({ cwd = vim.fn.expand("~/Documents/ObsidianVault") })
        end,
        desc = "Find Wiki Files",
      },
    },
  },
}
