-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- DB connections hold credentials, so the file lives outside the repo.
-- pcall: nvim still starts on a machine where the file does not exist.
pcall(dofile, vim.fn.stdpath("data") .. "/db_connections.lua")
