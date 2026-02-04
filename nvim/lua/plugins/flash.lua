return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        keys = { "F", "t", "T", ";", "," }, -- removed "f" from char mode
      },
    },
  },
  keys = {
    { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}
