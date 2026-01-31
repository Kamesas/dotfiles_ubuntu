return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
      },
      -- Ensure syntax highlighting is preserved when opening files
      wrap_results = true,
      -- Use better buffer previewer that preserves highlighting
      buffer_previewer_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        
        -- Use the default previewer
        require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
        
        -- Ensure treesitter is enabled for the preview buffer
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.bo[bufnr].syntax = "on"
            if vim.fn.exists(":TSBufEnable") > 0 then
              vim.cmd("TSBufEnable highlight")
            end
          end
        end)
      end,
    },
  },
}
