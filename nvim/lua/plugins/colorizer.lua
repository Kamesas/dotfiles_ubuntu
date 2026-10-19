-- shadcn themes keep colours as bare HSL: `--destructive: 0 84.2% 60.2%;`
-- The built-in hsl parser needs the text "hsl(", so `bare_hsl` covers these lines.
-- `parsers.custom` works only under `options`. Under `user_default_options`
-- it is dropped with no error, and no swatch appears.
return {
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = function()
      local color = require("colorizer.color")
      local utils = require("colorizer.utils")

      -- "0 84.2% 60.2%" -> consumed length, "ee4444"
      local function parse_bare_hsl(ctx)
        local byte = ctx.line:byte(ctx.col)
        if not byte or byte < 0x30 or byte > 0x39 then
          return
        end
        -- The parser runs at every column. Without this check, plain numbers become colours.
        if not ctx.line:sub(1, ctx.col - 1):match("%-%-[%w-]+:%s*$") then
          return
        end

        local h, s, l, stop = ctx.line:match("^(%d+%.?%d*)%s+(%d+%.?%d*)%%%s+(%d+%.?%d*)%%()", ctx.col)
        if not h then
          return
        end

        local r, g, b = color.hsl_to_rgb(tonumber(h) / 360, tonumber(s) / 100, tonumber(l) / 100)
        if not r then
          return
        end

        return stop - ctx.col, utils.rgb_to_hex(r, g, b)
      end

      return {
        filetypes = { "*" },
        options = {
          parsers = {
            css = false,
            tailwind = { enable = false },
            hsl = { enable = true },
            custom = {
              { name = "bare_hsl", parse = parse_bare_hsl },
            },
          },
        },
      }
    end,
  },
}
