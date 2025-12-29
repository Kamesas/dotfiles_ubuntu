return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("codeium").setup({
      enable_cmp_source = false, -- Disable cmp source to avoid popup suggestions
      virtual_text = {
        enabled = true, -- Enable ghost/shadow text
        manual = false, -- Auto-trigger suggestions
        idle_delay = 75, -- Delay before showing suggestions
        key_bindings = {
          accept = "<Tab>", -- Accept suggestion with Tab
          accept_word = false,
          accept_line = false,
          clear = "<C-]>", -- Clear suggestion with Ctrl-]
          next = "<M-]>", -- Next suggestion with Alt-]
          prev = "<M-[>", -- Previous suggestion with Alt-[
        },
      },
    })
  end,
}
