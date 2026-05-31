return {
  {
    "anurag3301/nvim-platformio.lua",
    -- Load shortly after startup so the <leader>p which-key menu is registered.
    event = "VeryLazy",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-lua/plenary.nvim",
      "folke/which-key.nvim",
    },
    keys = {
      -- Regenerate compile_commands.json (runs `pio run -t compiledb`,
      -- gitignores it, and restarts the LSP). Run after editing lib_deps.
      { "<leader>pi", "<cmd>PioLSP<cr>", desc = "PlatformIO: Regen LSP DB (compiledb)" },
    },
    -- Runs at startup, BEFORE the plugin loads. Must be here (not in `config`)
    -- because the plugin's plugin/ script shells out to `pio` the moment it is
    -- sourced — which Lazy does before running `config`. The `pio` CLI ships
    -- under PlatformIO's bundled venv and is usually not on PATH, so make sure
    -- Neovim's child processes can find it however nvim was launched.
    init = function()
      local pio_bin = vim.fn.expand("~/.platformio/penv/bin")
      if vim.fn.isdirectory(pio_bin) == 1 and not string.find(vim.env.PATH, pio_bin, 1, true) then
        vim.env.PATH = pio_bin .. ":" .. vim.env.PATH
      end
    end,
    config = function()
      require("platformio").setup({
        -- We use clangd (LazyVim clangd extra), fed by compile_commands.json.
        lsp = "clangd",
        clangd_source = "compiledb",
        -- Registers a full which-key menu under <leader>p:
        --   pg → General (build/upload/monitor/clean/fullclean/devices)
        --   pp → Platform (buildfs/size/uploadfs/erase)
        --   pd → Dependencies   pa → Advanced (test/check/debug/compiledb)
        --   pr → Remote         pm → Misc
        --   pl → List terminals pt → Terminal core CLI
        menu_key = "<leader>p",
        menu_name = "PlatformIO",
      })
    end,
  },
}
