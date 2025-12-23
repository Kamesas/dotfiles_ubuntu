return {
  "nvim-mini/mini.surround",
  version = false,
  event = "VeryLazy",
  opts = {
    mappings = {
      -- Add surrounding
      -- Example: visually select `word`, then press `gsa"` → becomes `"word"`
      -- Example: visually select `{children}`, then press `gsa<t>` → becomes `<t>{children}</t>`
      add = "gsa",

      -- Delete surrounding
      -- Example: cursor inside `"word"` → `gsd"` → removes quotes → `word`
      -- Example: cursor inside `<div>text</div>` → `gsd>` → removes tags → `text`
      delete = "gsd",

      -- Find surrounding (move cursor to next surrounding)
      -- Example: `gsf"` jumps to next `"..."` block
      find = "gsf",

      -- Find left surrounding (move cursor to previous surrounding)
      -- Example: `gsF"` jumps to previous `"..."` block
      find_left = "gsF",

      -- Highlight surrounding (temporarily shows the surrounding pair)
      -- Example: cursor inside `"text"`, press `gsh` → highlights `"..."` range
      highlight = "gsh",

      -- Replace surrounding
      -- Example: cursor inside `"word"` → `gsr"`` → changes to `` `word` ``
      -- Example: cursor inside `<p>text</p>` → `gsr>div>` → changes to `<div>text</div>`
      replace = "gsr",

      -- Update number of lines to search for surroundings
      -- Example: `gsn` then enter a number → increases or decreases how many lines mini.surround searches for pairs
      update_n_lines = "gsn",
    },
  },
}
