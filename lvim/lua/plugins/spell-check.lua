-- Enable built-in spell checking for specific filetypes
-- This is fast, lightweight, and works out of the box
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable ltex if it was previously enabled
        ltex = false,
      },
    },
  },
}
