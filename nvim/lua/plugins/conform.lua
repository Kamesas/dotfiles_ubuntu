return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.format_on_save = nil
    opts.format_after_save = function(bufnr)
      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
        return
      end
      return { lsp_format = "fallback" }
    end
  end,
}
