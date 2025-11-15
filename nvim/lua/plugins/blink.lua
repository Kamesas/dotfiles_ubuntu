return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Tab>"] = { "select_and_accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = false,
        },
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = true,
        },
      },
      menu = {
        auto_show = true,
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
          treesitter = {}, -- Disable treesitter highlighting to fix errors
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        sql = { inherit_defaults = true, "dadbod" },
        mysql = { inherit_defaults = true, "dadbod" },
        plsql = { inherit_defaults = true, "dadbod" },
      },
      providers = {
        -- Disable Codeium from completion menu
        codeium = {
          enabled = false,
        },
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
        },
      },
    },
  },
}
