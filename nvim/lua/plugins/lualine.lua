return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == "" then
        return ""
      end
      return "  REC @" .. reg
    end

    table.insert(opts.sections.lualine_x, 1, {
      macro_recording,
      color = { fg = "#ff5555", gui = "bold" },
    })

    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      callback = function()
        require("lualine").refresh()
      end,
    })
  end,
}
