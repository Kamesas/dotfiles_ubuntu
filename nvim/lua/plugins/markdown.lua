return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  },
  {
    -- https://github.com/jakewvincent/mkdnflow.nvim
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown",
    opts = {
      modules = {
        bib = false,
        conceal = false,
        folds = false,
      },
      -- The vault root is the folder with .git, so [[full/path]] links work from every note.
      path_resolution = {
        primary = "root",
        root_marker = ".git",
      },
      links = {
        transform_on_create = function(text)
          return text:gsub(" ", "-"):lower()
        end,
      },
      mappings = {
        MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>ml" },
        MkdnDestroyLink = { "n", "<leader>md" },
        MkdnIncreaseHeading = { "n", "+" },
        MkdnDecreaseHeading = { "n", "-" },
        -- Not the default <C-Space>: that is the tmux leader and never reaches nvim.
        MkdnToggleToDo = { { "n", "v" }, "<leader>mt" },
        MkdnUpdateNumbering = { "n", "<leader>mn" },
        MkdnTableNextCell = false,
        MkdnTablePrevCell = false,
        MkdnTablePrevRow = false,
        MkdnTableNewRowBelow = { "n", "<leader>mir" },
        MkdnTableNewRowAbove = { "n", "<leader>miR" },
        MkdnTableNewColAfter = { "n", "<leader>mic" },
        MkdnTableNewColBefore = { "n", "<leader>miC" },
      },
    },
    -- In init, not config: the key must work before a markdown file loads the plugin.
    init = function()
      vim.keymap.set("n", "<leader>wn", function()
        local notes_dir = vim.fn.expand("~/Documents/notes/diary")
        vim.fn.mkdir(notes_dir, "p")
        vim.cmd("edit " .. notes_dir .. "/" .. os.date("%Y-%m-%d") .. ".md")
      end, { desc = "Open daily note" })
    end,
  },
}
