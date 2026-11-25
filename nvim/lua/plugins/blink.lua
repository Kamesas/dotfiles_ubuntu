return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        -- <C-space> is the tmux leader, so <C-x> opens completion
        ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
        -- "fallback": when the menu is closed, the key goes to other mappings (mini.pairs on Enter)
        ["<CR>"] = { "accept", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },

      sources = {
        per_filetype = {
          sql = { "dadbod" },
          mysql = { "dadbod" },
          plsql = { "dadbod" },
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function()
      require("blink.cmp.sources.snippets.default.builtin").lazy.FILENAME_PASCAL = function()
        local name = vim.fn.expand("%:t:r")
        return (name:gsub("^%l", string.upper):gsub("[-_](%w)", string.upper))
      end
    end,
  },
}
