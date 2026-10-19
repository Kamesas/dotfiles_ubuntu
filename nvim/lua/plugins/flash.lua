return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        -- No "f": it is flash jump (keys below)
        keys = { "F", "t", "T", ";", "," },
      },
    },
  },
  keys = {
    {
      "f",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
  },
}
