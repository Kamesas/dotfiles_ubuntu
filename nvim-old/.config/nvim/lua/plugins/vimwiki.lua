return {
  "vimwiki/vimwiki",
  -- The 'init' function runs before the plugin is loaded
  init = function()
    -- Set global variables for configuration
    -- This is the Lua equivalent of `let g:vimwiki_list = [...]` in vimrc
    vim.g.vimwiki_list = {
      {
        path = "~/Documents/ObsidianVault/",
        syntax = "markdown",
        ext = ".md",
      },
    }
  end,
}
