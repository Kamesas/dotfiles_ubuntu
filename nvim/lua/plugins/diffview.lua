return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
      { "<leader>gF", ":DiffviewFileHistory<cr>", mode = "v", desc = "File History (range)" },
    },
    opts = {},
  },
}
