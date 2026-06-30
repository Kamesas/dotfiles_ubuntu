return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      -- For files named `index.*` the folder is the real name.
      -- Always show `folder/index.ext` so the tab is not just "index".
      name_formatter = function(buf)
        local name = vim.fn.fnamemodify(buf.path, ":t:r")
        if name == "index" then
          local parent = vim.fn.fnamemodify(buf.path, ":h:t")
          local ext = vim.fn.fnamemodify(buf.path, ":e")
          return parent .. "/index." .. ext
        end
      end,
    },
  },
}
