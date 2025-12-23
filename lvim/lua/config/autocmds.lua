-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--

-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable inlay hints completely
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("disable_inlay_hints", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    -- Disable immediately
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

    -- Also disable after a short delay to catch any LSPs that enable it later
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
      end
    end, 100)
  end,
})
