return {
  {
    "anurag3301/nvim-platformio.lua",
    -- Load shortly after startup so the <leader>p which-key menu is registered.
    event = "VeryLazy",
    -- The plugin runs `pio` when it loads. Skip it where PlatformIO is not installed.
    cond = function()
      return vim.fn.executable("pio") == 1
        or vim.fn.isdirectory(vim.fn.expand("~/.platformio/penv/bin")) == 1
    end,
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-lua/plenary.nvim",
      "folke/which-key.nvim",
    },
    keys = {
      -- Runs `pio run -t compiledb`, gitignores compile_commands.json, restarts the LSP.
      { "<leader>pi", "<cmd>PioLSP<cr>", desc = "PlatformIO: Regen LSP DB (compiledb)" },
    },
    -- Add the PlatformIO installer's venv to PATH, for machines where `pio` is
    -- not in ~/.local/bin. This is in `init`, not `config`, because the plugin
    -- runs `pio` before `config` runs.
    init = function()
      local pio_bin = vim.fn.expand("~/.platformio/penv/bin")
      if vim.fn.isdirectory(pio_bin) == 1 and not string.find(vim.env.PATH, pio_bin, 1, true) then
        vim.env.PATH = pio_bin .. ":" .. vim.env.PATH
      end
    end,
    config = function()
      require("platformio").setup({
        lsp = "clangd",
        clangd_source = "compiledb",
        -- The full menu is listed in nvim/Platformio.md.
        menu_key = "<leader>p",
        menu_name = "PlatformIO",
      })
    end,
  },
}
