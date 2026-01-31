return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = "VeryLazy",
  init = function()
    -- Basic settings for vim-visual-multi
    vim.g.VM_default_mappings = 1

    -- vim.g.VM_default_mappings = 0
    -- vim.g.VM_maps = {
    -- 	["Find Under"] = "",
    -- }
    -- vim.g.VM_add_cursor_at_pos_no_mappings = 1

    -- ============================================================================
    -- HOW TO IMITATE VSCODE CTRL+D (Multi-Cursor Selection)
    -- ============================================================================
    --
    -- METHOD 1: Select word under cursor and add next occurrences (most common)
    --   1. Place cursor on a word
    --   2. Press <C-n> (first press selects the word, enters VM mode)
    --   3. Press <C-n> again to add next occurrence
    --   4. Keep pressing <C-n> to add more occurrences
    --   5. Press 'i' or 'c' to edit all at once
    --   6. Press <Esc> to exit VM mode
    --
    -- METHOD 2: Select custom text first (like in VSCode)
    --   1. Visually select text (v or V)
    --   2. Press <C-n> (selects current and finds next occurrence)
    --   3. Press <C-n> again to add more occurrences
    --   4. Press 'i' or 'c' to edit all at once
    --   5. Press <Esc> to exit VM mode
    --
    -- TIP: Press 'q' to skip current occurrence and go to next (like Ctrl+K, Ctrl+D in VSCode)
    -- TIP: Press 'Q' to remove current cursor/selection
    -- TIP: Press '\\A' to select ALL occurrences at once (like Ctrl+Shift+L in VSCode)
    --
    -- ============================================================================
    -- Default Keymaps Reference (with VM_default_mappings = 1)
    -- ============================================================================

    -- BASIC SELECTION (Most Common - VSCode-like)
    -- <C-n>           - Find word under cursor, select it, and go to next occurrence
    -- <C-n>           - (in visual mode) Select current selection and go to next
    -- <C-Down>        - Create cursor vertically down
    -- <C-Up>          - Create cursor vertically up
    -- n / N           - Get next/previous occurrence
    -- [ / ]           - Select next/previous cursor
    -- q               - Skip current and get next occurrence (like Ctrl+K, Ctrl+D in VSCode)
    -- Q               - Remove current cursor/selection

    -- MODE SWITCHING
    -- <Tab>           - Switch between cursor mode and extend mode
    -- <S-Arrows>      - Select one character at a time (extend mode)

    -- INSERT MODE
    -- i, a, I, A      - Start insert mode at all cursors
    -- c               - Change (delete and enter insert mode)
    -- s               - Substitute (delete character and enter insert mode)

    -- MOTIONS (work in cursor mode)
    -- h, j, k, l      - Move cursors left, down, up, right
    -- w, b, e         - Word motions
    -- 0, ^, $         - Line start, first non-blank, line end
    -- f{char}         - Find character forward
    -- t{char}         - Till character forward
    -- %               - Jump to matching bracket

    -- TEXT OBJECTS (work in extend mode)
    -- iw, aw          - Inner word, a word
    -- i", a"          - Inner quotes, a quotes (also works with ', `, (, [, {, <)
    -- ip, ap          - Inner paragraph, a paragraph
    -- it, at          - Inner tag, a tag (HTML/XML)

    -- EDITING
    -- r{char}         - Replace character at all cursors
    -- ~               - Change case at all cursors
    -- x, X            - Delete character under/before cursor
    -- d{motion}       - Delete with motion (dd for line)
    -- y{motion}       - Yank with motion (yy for line)
    -- p, P            - Paste after/before cursor
    -- u               - Undo
    -- <C-r>           - Redo

    -- ADVANCED SELECTION
    -- \\A             - Select all occurrences of word under cursor
    -- \\/             - Add selection with regex pattern
    -- \\\\            - Add cursor at position
    -- \\gS            - Reselect last set of regions

    -- VISUAL COMMANDS (in VM mode)
    -- \\c             - Run ex command on all cursors
    -- \\a             - Align cursors
    -- \\<             - Align char left
    -- \\>             - Align char right
    -- \\n             - Number selection (increment)
    -- \\t             - Transpose selections

    -- MACROS
    -- @{register}     - Run macro at all cursors

    -- SEARCH & REPLACE
    -- \\f             - Filter regions by pattern
    -- \\R             - Start replace mode

    -- MISC
    -- <Esc> / <C-c>   - Exit VM mode
    -- \\<CR>          - Toggle single region on/off
    -- \\z             - Toggle mappings

    -- ============================================================================
    -- Custom Mappings (uncomment and modify if needed)
    -- ============================================================================
    -- vim.g.VM_maps = {
    --   -- Basic selections
    --   ["Find Under"] = '<C-n>',                    -- Find word under cursor
    --   ["Find Subword Under"] = '<C-n>',            -- Find subword under cursor
    --   ["Add Cursor Down"] = '<C-Down>',            -- Add cursor down
    --   ["Add Cursor Up"] = '<C-Up>',                -- Add cursor up
    --
    --   -- Navigation
    --   ["Select Cursor Down"] = '<M-C-Down>',       -- Select and move down
    --   ["Select Cursor Up"] = '<M-C-Up>',           -- Select and move up
    --   ["Skip Region"] = 'q',                       -- Skip current region
    --   ["Remove Region"] = 'Q',                     -- Remove current region
    --
    --   -- Advanced
    --   ["Select All"] = '\\A',                      -- Select all occurrences
    --   ["Start Regex Search"] = '\\/',              -- Start regex search
    --   ["Add Cursor At Pos"] = '\\\\',              -- Add cursor at position
    --   ["Reselect Last"] = '\\gS',                  -- Reselect last regions
    --
    --   -- Visual commands
    --   ["Visual Regex"] = '\\/',                    -- Regex search in visual
    --   ["Visual All"] = '\\A',                      -- Select all in visual
    --   ["Visual Add"] = '\\a',                      -- Add region in visual
    --   ["Visual Find"] = '\\f',                     -- Find in visual
    --   ["Visual Cursors"] = '\\c',                  -- Run ex command
    --
    --   -- Align
    --   ["Align"] = '\\a',                           -- Align cursors
    --   ["Align Char"] = '\\<',                      -- Align on character
    --
    --   -- Tools
    --   ["Tools Menu"] = '\\`',                      -- Show tools menu
    --   ["Case Setting"] = '\\c',                    -- Case conversion menu
    --
    --   -- Misc
    --   ["Toggle Mappings"] = '\\z',                 -- Toggle VM mappings
    --   ["Toggle Single Region"] = '\\<CR>',         -- Toggle region
    -- }

    -- ============================================================================
    -- Plugin Settings
    -- ============================================================================
    -- vim.g.VM_theme = 'iceblue'                     -- Color theme
    -- vim.g.VM_highlight_matches = 'underline'       -- How to highlight matches
    -- vim.g.VM_mouse_mappings = 1                    -- Enable mouse support
    -- vim.g.VM_silent_exit = 1                       -- Don't show message on exit
    -- vim.g.VM_show_warnings = 1                     -- Show warning messages
  end,
}
