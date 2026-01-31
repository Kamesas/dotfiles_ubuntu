return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    provider = "ollama",
    providers = {
      ollama = {
        endpoint = "http://127.0.0.1:11434",
        model = "qwen2.5-coder:3b",
        timeout = 60000,
      },
    },
  },
}
