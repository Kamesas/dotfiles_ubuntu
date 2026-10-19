return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
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
