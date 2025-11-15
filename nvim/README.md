# LazyVim Configuration

Custom configuration files for LazyVim.

## Features

- **Blink.cmp** for autocompletion
  - Codeium AI disabled in completion menu
  - Custom keymaps (Ctrl+Space, Tab, Enter, Ctrl+J/K)
  - SQL dadbod integration with inherit_defaults
- **SQL Support** via vim-dadbod
- **Custom Keymaps** for navigation and productivity
- **JavaScript/TypeScript snippets**
- **Custom diagnostics settings**

## Installation

### Fresh Install

```bash
# Clone dotfiles
git clone <your-repo> ~/dotfiles

# Backup existing config (if any)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup

# Create symlink
ln -s ~/dotfiles/nvim ~/.config/nvim

# Start Neovim (LazyVim will auto-install)
nvim
```

### Update Existing Config

```bash
# Pull latest changes
cd ~/dotfiles
git pull

# Restart Neovim to apply changes
```

## Structure

```
nvim/
├── init.lua                  # Entry point
├── lazyvim.json             # LazyVim extras (Codeium AI, SQL)
├── lua/
│   ├── config/
│   │   ├── autocmds.lua     # Auto commands
│   │   ├── functions.lua    # Custom functions
│   │   ├── keymaps.lua      # Key mappings
│   │   ├── lazy.lua         # Lazy.nvim setup
│   │   └── options.lua      # Vim options
│   ├── plugins/
│   │   ├── blink.lua        # ⭐ Autocomplete config (fixed!)
│   │   ├── dadbod.lua       # Database UI
│   │   └── ...              # Other plugin configs
│   └── db_connections.lua   # Database connections
├── snippets/
│   ├── javascript.json
│   └── typescript.json
└── after/
    └── ftplugin/
        └── sql.lua          # SQL-specific settings
```

## Key Configurations

### Blink.cmp (lua/plugins/blink.lua)

- ✅ Automatic completions
- ✅ Codeium disabled in menu (still available as ghost text)
- ✅ SQL files get LSP + path + snippets + buffer + dadbod
- ✅ No treesitter errors
- ✅ Auto-brackets disabled

### Keymaps (lua/config/keymaps.lua)

- `jk` / `jj` - Escape insert mode
- `Alt+j/k` - Move cursor/lines up/down
- `Ctrl+Space` - Show completions (in Neovim)
- `<leader>D` - Toggle database UI

## Database Setup

Edit `lua/db_connections.lua` to add your database connections.

See [LazyVim SQL docs](https://www.lazyvim.org/extras/lang/sql) for more info.

## Notes

- This repo only contains **custom configurations**
- LazyVim and plugins are auto-installed on first run
- `lazy-lock.json` is gitignored (plugins update independently)
