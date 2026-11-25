local function hsl_to_hex(value)
  local h, s, l = value:match("^([%d.]+)%s+([%d.]+)%%%s+([%d.]+)%%$")
  if not h then
    return nil
  end

  h, s, l = h / 360, s / 100, l / 100
  local function channel(n)
    local k = (n + h * 12) % 12
    local c = l - s * math.min(l, 1 - l) * math.max(-1, math.min(k - 3, 9 - k, 1))
    return math.floor(c * 255 + 0.5)
  end
  return ("#%02X%02X%02X"):format(channel(0), channel(8), channel(4))
end

local function find_css_var_lines(root, names)
  local lines = {}
  for _, file in ipairs(vim.fn.systemlist({ "rg", "--files", "--glob", "*.css", root })) do
    local selector = ""
    for line in io.lines(file) do
      selector = line:match("^%s*([^{}]-)%s*{%s*$") or selector
      for _, name in ipairs(names) do
        local value, rest = line:match("^%s*%-%-" .. vim.pesc(name) .. ":%s*([^;]+);(.*)")
        if value then
          local parts = { ("--%s: %s;"):format(name, value) }
          table.insert(parts, hsl_to_hex(value))
          table.insert(parts, rest:match("/%*%s*(.-)%s*%*/"))
          table.insert(parts, ("/* %s */"):format(selector))
          table.insert(lines, table.concat(parts, " "))
        end
      end
    end
  end
  return lines
end

local function add_css_var_values(contents, root)
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
              local field = ({ ["textDocument/hover"] = "contents", ["completionItem/resolve"] = "documentation" })[method]
              if field and handler then
                local original_handler = handler
                handler = function(err, result, ctx, config)
                  add_css_var_values(result and result[field], self.root_dir)
                  return original_handler(err, result, ctx, config)
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
