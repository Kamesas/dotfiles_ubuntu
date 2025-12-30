return {
  {
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown", -- only load for markdown files
    keys = {
      { "<leader>ww", mode = "n", desc = "Open daily note" },
    },
    opts = {
      modules = {
        bib = false,
        buffers = true,
        conceal = false, -- keep it minimal, no concealment
        cursor = true,
        folds = false,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        yaml = false,
      },
      filetypes = { md = true, rmd = true, markdown = true },
      create_dirs = true,
      perspective = {
        priority = "root", -- use root directory perspective
        fallback = "current",
        root_tell = false,
        nvim_wd_heel = false,
      },
      wrap = false,
      bib = {
        default_path = nil,
        find_in_root = true,
      },
      silent = false,
      links = {
        style = "markdown", -- use standard markdown links
        name_is_source = false,
        conceal = false,
        context = 0,
        implicit_extension = nil,
        transform_implicit = false,
        transform_explicit = function(text)
          text = text:gsub(" ", "-")
          text = text:lower()
          return text
        end,
      },
      new_file_template = {
        use_template = false,
      },
      to_do = {
        symbols = { " ", "-", "X" }, -- unchecked, in-progress, checked
        update_parents = true,
        not_started = " ",
        in_progress = "-",
        complete = "X",
      },
      tables = {
        trim_whitespace = true,
        format_on_move = true,
        auto_extend_rows = false,
        auto_extend_cols = false,
      },
      yaml = {
        bib = { override = false },
      },
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" }, -- follow/create link
        MkdnTab = false, -- disable tab in favor of default behavior
        MkdnSTab = false,
        MkdnNextLink = { "n", "<Tab>" }, -- jump to next link
        MkdnPrevLink = { "n", "<S-Tab>" }, -- jump to previous link
        MkdnGoBack = { "n", "<BS>" }, -- go back
        MkdnGoForward = { "n", "<Del>" }, -- go forward
        MkdnCreateLink = false, -- use default <leader>l behavior if needed
        MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>ml" }, -- create link from clipboard
        MkdnFollowLink = false, -- handled by Enter
        MkdnDestroyLink = { "n", "<leader>md" }, -- destroy link
        MkdnTagSpan = { "v", "<M-CR>" },
        MkdnMoveSource = { "n", "<F2>" }, -- rename file and update links
        MkdnYankAnchorLink = { "n", "yaa" },
        MkdnYankFileAnchorLink = { "n", "yfa" },
        MkdnIncreaseHeading = { "n", "+" },
        MkdnDecreaseHeading = { "n", "-" },
        MkdnToggleToDo = { { "n", "v" }, "<C-Space>" }, -- toggle checkbox
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { "n", "o" },
        MkdnNewListItemAboveInsert = { "n", "O" },
        MkdnExtendList = false,
        MkdnUpdateNumbering = { "n", "<leader>mn" },
        MkdnTableNextCell = false, -- disabled to avoid conflict with Codeium
        MkdnTablePrevCell = false,
        MkdnTableNextRow = false,
        MkdnTablePrevRow = false,
        MkdnTableNewRowBelow = { "n", "<leader>mir" },
        MkdnTableNewRowAbove = { "n", "<leader>miR" },
        MkdnTableNewColAfter = { "n", "<leader>mic" },
        MkdnTableNewColBefore = { "n", "<leader>miC" },
        MkdnFoldSection = { "n", "<leader>mf" },
        MkdnUnfoldSection = { "n", "<leader>mF" },
      },
    },
    config = function(_, opts)
      require("mkdnflow").setup(opts)
    end,
    init = function()
      -- Daily notes functionality - set up in init so it's always available
      local function open_daily_note()
        local notes_dir = vim.fn.expand("~/Documents/ObsidianVault/diary")
        vim.fn.mkdir(notes_dir, "p")
        local date = os.date("%Y-%m-%d")
        local filename = notes_dir .. "/" .. date .. ".md"
        vim.cmd("edit " .. filename)
      end

      -- Keybinding for daily notes (similar to vimwiki)
      vim.keymap.set("n", "<leader>ww", open_daily_note, { desc = "Open daily note" })
    end,
  },
}
