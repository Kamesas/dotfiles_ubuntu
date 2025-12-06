return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sql = { "sqlfluff" },
    },
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "sql" then
        return { timeout_ms = 500, lsp_fallback = true }
      end
    end,
  },
  keys = {
    {
      "<leader>fs",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
}
