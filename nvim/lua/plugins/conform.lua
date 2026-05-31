return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    local prettier_files = {
      ".prettierrc", ".prettierrc.js", ".prettierrc.mjs", ".prettierrc.cjs",
      ".prettierrc.json", ".prettierrc.yaml", ".prettierrc.yml",
      "prettier.config.js", "prettier.config.mjs", "prettier.config.cjs",
    }
    local eslint_files = {
      "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
      ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.yaml", ".eslintrc.yml",
      ".eslintrc.json", ".eslintrc",
    }
    local function js_formatters(bufnr)
      local has_prettier = vim.fs.root(bufnr, prettier_files)
      local has_eslint = vim.fs.root(bufnr, eslint_files)
      -- use prettierd when: project has prettier config, or no eslint config (default fallback)
      if has_prettier or not has_eslint then
        return { "prettierd" }
      end
      return {}
    end

    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      typescript = js_formatters,
      typescriptreact = js_formatters,
      javascript = js_formatters,
      javascriptreact = js_formatters,
    })
    opts.default_format_opts = { lsp_format = "never" }
  end,
}
