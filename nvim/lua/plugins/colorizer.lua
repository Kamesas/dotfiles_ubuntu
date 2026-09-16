-- Colour swatches shown next to colour values in the buffer.
--
-- Why the extra parser: shadcn and react-native-reusables keep their theme in
-- CSS custom properties that hold bare HSL channels, with no function around
-- them:
--
--   --destructive: 0 84.2% 60.2%;
--
-- The `hsl()` wrapper lives in tailwind.config.js instead. So the built-in hsl
-- parser, which only fires on the literal text "hsl(", never sees these lines
-- and a whole theme file shows no colour at all. `bare_hsl` below covers that
-- shape.
--
-- Two traps when editing this:
--
--   * `parsers.custom` exists only under the `options` key. The older
--     `user_default_options` key drops it without any error - the config loads
--     fine and no swatch ever appears. Do not move these settings back.
--
--   * The parser has no prefix to dispatch on, so it is called at every column
--     of every line. It bails on the first byte unless that byte is a digit,
--     then requires a `--name:` just before it. That guard is what keeps plain
--     numbers in .tsx and .md files from turning into colours.
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
        if not ctx.line:sub(1, ctx.col - 1):match("%-%-[%w-]+:%s*$") then
          return
        end

        local h, s, l, stop =
          ctx.line:match("^(%d+%.?%d*)%s+(%d+%.?%d*)%%%s+(%d+%.?%d*)%%()", ctx.col)
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
            -- For the plain hsl() strings in files that feed React Navigation,
            -- which cannot use Tailwind classes and repeat the palette by hand.
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
