local function find_css_var_lines(root, names)
  local lines = {}
  for _, file in ipairs(vim.fn.systemlist({ "rg", "--files", "--glob", "*.css", root })) do
    local selector = ""
    for line in io.lines(file) do
      selector = line:match("^%s*([^{}]-)%s*{%s*$") or selector
      for _, name in ipairs(names) do
        local value = line:match("^%s*%-%-" .. vim.pesc(name) .. ":%s*([^;]+);")
        if value then
          table.insert(lines, ("--%s: %s; /* %s */"):format(name, value, selector))
        end
      end
    end
  end
  return lines
end

local function add_css_var_values(result, root)
  local contents = result and result.contents
  if type(contents) ~= "table" or type(contents.value) ~= "string" then
    return
  end

  local names, seen = {}, {}
  for name in contents.value:gmatch("var%(%-%-([%w-]+)") do
    if not seen[name] then
      seen[name] = true
      table.insert(names, name)
    end
  end

  local lines = #names > 0 and find_css_var_lines(root, names) or {}
  if #lines > 0 then
    contents.value = contents.value .. "\n" .. table.concat(lines, "\n")
  end
end

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- No typescript-language-server: typescript-tools.nvim starts tsserver itself.
        "tailwindcss-language-server",
        "css-lsp",
        "html-lsp",
        "emmet-ls",
        "eslint-lsp",
        "prettierd",
        "prettier",
        "eslint_d",
        "js-debug-adapter",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        vtsls = { enabled = false },
        ts_ls = { enabled = false },
        tailwindcss = {
          on_init = function(client)
            local request = client.request
            client.request = function(self, method, params, handler, bufnr)
              if method == "textDocument/hover" and handler then
                local hover_handler = handler
                handler = function(err, result, ctx, config)
                  add_css_var_values(result, self.root_dir)
                  return hover_handler(err, result, ctx, config)
                end
              end
              return request(self, method, params, handler, bufnr)
            end
          end,
          on_attach = function(_, bufnr)
            -- Turn off the color swatches tailwindcss sends. The API only
            -- exists on nvim 0.12+, so 0.11 has nothing to turn off.
            if vim.lsp.document_color then
              vim.lsp.document_color.enable(false, { bufnr = bufnr })
            end
          end,
          settings = {
            tailwindCSS = {
              lint = {
                suggestCanonicalClasses = "ignore",
              },
              experimental = {
                classRegex = {
                  { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                },
              },
            },
          },
        },
        eslint = {
          flags = { allow_incremental_sync = false },
        },
        html = {},
        cssls = {},
        emmet_ls = {
          filetypes = { "html", "typescriptreact", "javascriptreact", "css" },
        },
      },
    },
  },

  -- Used instead of vtsls because it updates imports when a file is renamed (willRenameFiles)
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      on_attach = function(_, bufnr)
        vim.keymap.set(
          "n",
          "<leader>ci",
          "<cmd>TSToolsAddMissingImports<cr>",
          { buffer = bufnr, desc = "Add All Missing Imports" }
        )
      end,
      settings = {
        -- Auto-import uses the path alias (@/...). Projects without one get relative paths.
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "css" })
    end,
  },

  {
    "vuki656/package-info.nvim",
    event = "BufRead package.json",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 100,
      },
    },
  },
}
