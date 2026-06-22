return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        -- <C-space> is the tmux leader key, so C-x triggers completion manually instead
        ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
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
          sql = { inherit_defaults = true, "dadbod" },
          mysql = { inherit_defaults = true, "dadbod" },
          plsql = { inherit_defaults = true, "dadbod" },
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
}
