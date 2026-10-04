# PlatformIO in Neovim

ESP32 work in Neovim has two parts:
- `nvim-platformio.lua`: build, upload and monitor commands.
- clangd: C/C++ completion and errors, using data from PlatformIO.

Machine setup (install `pio`, clangd config, serial port access) is in
`SETUP-GUIDE.md`, section "ESP32 / PlatformIO development".

## Most used

| Keys | Command | Action |
| --- | --- | --- |
| `<leader>pg b` | `:Piorun` | Build |
| `<leader>pg u` | `:Piorun upload` | Upload to the board |
| `<leader>pg m` | `:Piomon` | Serial monitor |
| `<leader>pi` | `:PioLSP` | Rebuild the clangd database |
| `<leader>pg c` | `:Piorun clean` | Clean build |

Press `<leader>p` and which-key shows the full menu.

## Files

- `lua/plugins/platformio.lua`: the plugin and the `<leader>p` menu.
- `lua/plugins/clangd.lua`: clangd options. `--query-driver` lets clangd find the ESP32 compiler headers.
- `~/.config/clangd/config.yaml` (stow package `clangd`): removes GCC-only flags that clang rejects. Covers every project.
- `<project>/compile_commands.json`: list of include paths and flags for clangd. Made by `pio run -t compiledb`. Gitignored.

Projects need no `.clangd` file.

## When to run `:PioLSP`

`:PioLSP` (or `<leader>pi`) runs `pio run -t compiledb`, adds
`compile_commands.json` to `.gitignore`, and restarts clangd.

Run it:
- once in each project on a new machine
- after you change `lib_deps` in `platformio.ini`
- after you move or rename the project folder

## The `<leader>p` menu

| Keys | Action |
| --- | --- |
| `<leader>pi` | Rebuild the clangd database |
| `<leader>pl` | List PlatformIO terminals |
| `<leader>pt` | Terminal for any `pio …` command |
| `<leader>pg b` | Build |
| `<leader>pg u` | Upload |
| `<leader>pg m` | Monitor |
| `<leader>pg c` | Clean |
| `<leader>pg f` | Full clean |
| `<leader>pg d` | Device list |
| `<leader>pp b/s/u/e` | Platform: build FS / size / upload FS / erase flash |
| `<leader>pd l/o/u` | Libraries: list / outdated / update |
| `<leader>pa t/c/d/b` | Advanced: test / check / debug / compile database |
| `<leader>pa v …` | Verbose build/upload/test/check/debug |
| `<leader>pr u/t/m/d` | Remote: upload / test / monitor / devices |
| `<leader>pm u` | Upgrade PlatformIO |

## Commands

| Command | Action |
| --- | --- |
| `:Piorun` / `:Piorun upload` / `:Piorun clean` | Build / upload / clean |
| `:Piomon [baud] [port]` | Serial monitor (Tab completes baud and port) |
| `:Piolib <args>` | Library manager |
| `:Piodebug` | Start a debug session |
| `:Piocmdf <pio args>` | Any `pio` command in a full terminal |
| `:Piocmdh <pio args>` | Same, in a horizontal split |
| `:PioTermList` | List PlatformIO terminals |
| `:PioLSP` | Rebuild the clangd database |

Set `monitor_speed`, `monitor_port` and `upload_port` in `platformio.ini`.
Then upload and monitor use the right port without asking.

## Troubleshooting

- **`Arduino.h` not found, unknown type `uint8_t`, undeclared `Serial`**
  - `compile_commands.json` is missing or old. For example, it was made on another machine.
  - Run `:PioLSP`.
- **A library header not found (`DHT.h`, `U8g2lib.h`, …)**
  - `lib_deps` must be inside the `[env:...]` section of `platformio.ini`.
  - In `[platformio]`, PlatformIO ignores it. The build prints `Ignore unknown configuration option 'lib_deps'`.
- **`Bluepad32.h` not found** (project with a custom framework in `platform_packages`)
  - Run `pio run` first, then `:PioLSP`.
  - If you make the database while packages still download, it gets the wrong framework paths.
- **Bluepad32 project broke after you built another project**
  - The first build of a project with the normal framework moves Bluepad32 into `framework-arduinoespressif32@src-…`.
  - Run `:PioLSP` in the Bluepad32 project again. After that, both frameworks have their own folder.
- **`Unknown argument: -m…` or `-f…` from clang**
  - Add the flag to `CompileFlags.Remove` in `~/.config/clangd/config.yaml`.
  - Then run `:LspRestart`.
- **`~/.platformio` or a project's `.pio/` is missing or broken**
  - Both are only download caches.
  - Delete the broken folder and run `pio run`. It downloads what the project needs.
- **"Platformio not found in the path"**
  - Check that `pio` runs in a terminal. Then restart Neovim.
- **No menu on `<leader>p`**
  - Run `:Lazy sync`, then restart Neovim.
- **Plugin health check:** `:checkhealth platformio`
