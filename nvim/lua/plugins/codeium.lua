return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("codeium").setup({
      enable_cmp_source = false,
      enable_chat = false, -- Disable chat to reduce API calls
      enable_local_search = false, -- Disable to reduce background activity
      enable_index_service = false, -- Disable indexing to reduce memory/API usage
      virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 150, -- Increased delay to reduce request frequency
        key_bindings = {
          accept = "<Tab>",
          accept_word = false,
          accept_line = false,
          clear = "<C-]>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    })

    vim.keymap.set("n", "<leader>ai", function()
      vim.cmd("Codeium Toggle")
    end, { desc = "Toggle Codeium" })
  end,
}
