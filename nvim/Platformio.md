# PlatformIO in Neovim (LazyVim)

How embedded / ESP32 development works in this config now that VSCode is gone.
Two pieces: **`nvim-platformio.lua`** (build/upload/monitor commands) and
**clangd** (real C/C++ intellisense fed by PlatformIO).

## ⚡ Most used

| Keybinding | Command | Action |
| --- | --- | --- |
| `<leader>pg b` | `:Piorun` | **Build** |
| `<leader>pg u` | `:Piorun upload` | **Upload** (flash the board) |
| `<leader>pg m` | `:Piomon` | **Monitor** (serial output) |
| `<leader>pi` | `:PioLSP` | **Regen LSP DB** — run after changing `lib_deps`/headers |
| `<leader>pg c` | `:Piorun clean` | Clean build |

Tip: just press `<leader>p` and let which-key show you the rest.

---

Relevant files:

| File | Role |
| --- | --- |
| `lua/plugins/platformio.lua` | The PlatformIO plugin + `<leader>p` which-key menu |
| `lua/plugins/clangd.lua` | clangd `--query-driver` so it finds the ESP32 GCC toolchain headers |
| `<project>/compile_commands.json` | Generated include/flag database clangd reads (gitignored) |
| `<project>/.clangd` | Strips GCC-only flags that clang rejects |

---

## Prerequisites

- The `pio` CLI. It lives at `~/.platformio/penv/bin/pio` and is **not on
  PATH** by default. Add this to your shell rc to call it as just `pio`:

  ```sh
  export PATH="$HOME/.platformio/penv/bin:$PATH"
  ```

- A PlatformIO project (a `platformio.ini` in the project root).

---

## First-time setup in a project

Open any source file in the project, then run:

```
:PioLSP
```

This runs `pio run -t compiledb`, generates `compile_commands.json`, adds it to
`.gitignore`, and restarts the LSP. After that clangd resolves `Arduino.h`,
`uint8_t`, your classes, etc.

> If clangd still complains about an unknown GCC flag, add it to the `Remove:`
> list in the project's `.clangd` file. The common ESP32 offenders
> (`-fno-tree-switch-conversion`, `-fstrict-volatile-bitfields`,
> `-mtext-section-literals`) are already handled.

**Re-run `:PioLSP` whenever you change `lib_deps` or add new headers** — the
compile database is a snapshot and won't pick up new include paths on its own.

---

## Keybindings — the `<leader>p` menu

Press `<leader>p` to open the PlatformIO which-key menu. The tree:

| Keys | Action |
| --- | --- |
| `<leader>pi` | **Regen LSP DB** (`:PioLSP` — run after changing libraries) |
| `<leader>pl` | List open PlatformIO terminals |
| `<leader>pt` | Terminal core CLI (run any `pio …` command) |
| `<leader>pg b` | **Build** |
| `<leader>pg u` | **Upload** (flash the board) |
| `<leader>pg m` | **Monitor** (serial monitor) |
| `<leader>pg c` | Clean |
| `<leader>pg f` | Full clean |
| `<leader>pg d` | Device list |
| `<leader>pp b/s/u/e` | Platform: build FS / size / upload FS / erase flash |
| `<leader>pd l/o/u` | Dependencies: list / outdated / update |
| `<leader>pa t/c/d/b` | Advanced: test / check / debug / compilation database |
| `<leader>pa v …` | Verbose variants (build/upload/test/check/debug) |
| `<leader>pr u/t/m/d` | Remote: upload / test / monitor / devices |
| `<leader>pm u` | Upgrade PlatformIO Core |

Everything is mnemonic and shown live by which-key, so you don't have to
memorize it — just press `<leader>p` and read.

### Equivalent ex-commands

If you prefer typing commands:

| Command | Action |
| --- | --- |
| `:Piorun` / `:Piorun upload` / `:Piorun clean` | Build / upload / clean |
| `:Piomon [baud] [port]` | Serial monitor (tab-completes baud + port) |
| `:Piolib <args>` | Library manager |
| `:Piodebug` | Start a debug session |
| `:Piocmdf <pio args>` | Run any `pio` command in a full terminal |
| `:Piocmdh <pio args>` | Same, in a horizontal split |
| `:PioTermList` | List/switch PlatformIO terminals |
| `:PioLSP` | Regenerate the clangd database |

This board (`lolin_c3_mini`) has `monitor_speed`, `monitor_port`, and
`upload_port` set in `platformio.ini`, so upload/monitor pick the right serial
device automatically.

---

## Troubleshooting

- **`Arduino.h` not found / unknown type `uint8_t`** → `compile_commands.json`
  is missing or stale. Run `:PioLSP`, then `:LspRestart`.
- **`Unknown argument: -f…` / `-mlongcalls` from clang** → these GCC-only flags
  are stripped globally in `~/.config/clangd/config.yaml`. If a new one appears,
  add it to that file's `CompileFlags.Remove` list, then `:LspRestart`.
- **"Platformio not found in the path"** → the plugin shells out to `pio`.
  `lua/plugins/platformio.lua` prepends `~/.platformio/penv/bin` to Neovim's
  PATH on load, so this should be handled. If it still fails, check that
  `~/.platformio/penv/bin/pio` exists, then restart Neovim.
- **Menu doesn't appear on `<leader>p`** → `:Lazy sync`, then restart Neovim
  (the menu registers on the `VeryLazy` event).
- **Check the plugin's own diagnostics** → `:checkhealth platformio`.

---

## Installing on a fresh Linux machine

No VSCode required. The whole stack is: Neovim + this config, PlatformIO Core
(standalone), clangd (auto-installed by Mason), and serial-port permissions.

### 1. System packages

```sh
# Debian/Ubuntu
sudo apt update
sudo apt install -y git curl python3 python3-venv

# Neovim 0.10+ — use a recent build (distro packages are often too old).
# e.g. the official tarball, or your preferred method.
```

### 2. This Neovim config

The config is the `nvim/` folder of the dotfiles repo, symlinked into place.

```sh
git clone git@github.com:Kamesas/dotfiles_ubuntu.git ~/dotfiles
ln -s ~/dotfiles/nvim ~/.config/nvim
```

Launch `nvim`. Lazy installs the plugins automatically, and Mason installs
**clangd** (pulled in by the LazyVim `lang.clangd` extra). Let it finish.

### 3. PlatformIO Core (standalone)

This installs Core into `~/.platformio/penv` — the same location the VSCode
extension would use, but without VSCode.

```sh
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o /tmp/get-platformio.py
python3 /tmp/get-platformio.py
```

`lua/plugins/platformio.lua` already prepends `~/.platformio/penv/bin` to
Neovim's PATH, so nvim finds `pio` automatically. To call `pio` in a terminal
too, add to your shell rc:

```sh
export PATH="$HOME/.platformio/penv/bin:$PATH"
```

### 4. Serial port permissions (for upload + monitor)

Without this, uploading/monitoring fails with permission-denied on the
`/dev/tty*` device.

```sh
# PlatformIO's udev rules
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/platformio/assets/system/99-platformio-udev.rules \
  | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Add yourself to the serial groups, then LOG OUT and back in
sudo usermod -aG dialout,plugdev "$USER"
```

### 5. Per project

Open a source file in the PlatformIO project and run `:PioLSP` (or `<leader>pi`)
once to generate `compile_commands.json`. Done — build/upload/monitor with the
`<leader>p` menu.

> Toolchains, frameworks, and libraries are downloaded automatically by Core on
> the first `:Piorun` (build) for a given board/framework.
