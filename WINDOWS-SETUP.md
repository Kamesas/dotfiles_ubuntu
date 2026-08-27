# Windows setup — the Sway-alike half

The Windows half is in this repo, under `windows/`, but it is **not** stowed by
`install.sh`. Stow makes symlinks, and a Windows symlink into `\\wsl.localhost`
breaks whenever the distro is not running. So these are copies, kept honest by
`sync-windows`. See "Files" below.

The goal driving all of it: alex used Arch + Sway before this machine and wants
Windows to feel the same — keyboard-first, no mouse, a Linux userland
underneath. When choosing between "the Sway way" and "the idiomatic Windows
way", Sway wins.

Verified against the live machine on **2026-08-27**. Re-check anything before
relying on it.

---

## Ground truth

| | |
|---|---|
| OS | Windows 11 Home 25H2, build 26200 |
| Display | single, 2048×1152, taskbar bottom edge, icons **centre**-aligned, no auto-hide |
| WSL | Ubuntu 26.04 LTS, login shell `/usr/bin/zsh` |
| Terminal | WezTerm 20240203-110809-5046fc22 |
| Multiplexer | tmux 3.6, prefix `C-Space` |
| Editor | Neovim 0.11.6 (LazyVim) |
| Hotkeys | AutoHotkey v2 — `%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe` |

Stack: **sway.ahk** and **PowerToys Run** sit on Windows as the window-manager
layer; the terminal is WezTerm → WSL Ubuntu → tmux → Neovim.

---

## The keymap is split across two programs

This is the trap. `sway.ahk` reads like the complete keymap and is not — a
collision with PowerToys is silent in both configs. Check both before binding
anything. Rough division: **Win**-prefixed is `sway.ahk`, **Alt**-prefixed is
PowerToys and the terminal.

### sway.ahk

| Key | Does |
|---|---|
| `Alt+W` | Toggle the **Linux** dropdown — WezTerm into WSL Ubuntu, zsh, tmux |
| `Alt+E` | Toggle the **Windows** dropdown — WezTerm into PowerShell |
| `Win+1`…`Win+5` | Jump straight to that desktop |
| `Win+H` / `Win+L` | Previous / next desktop, no wrap at the ends |
| `Win+C` | Close focused window (sway's kill; sends `WM_CLOSE`) |
| `Win+Shift+L` | Lock the workstation |
| `Win+Shift+W` | Rescue — unhide every WezTerm window |

### PowerToys

| Key | Does |
|---|---|
| `Alt+U` | PowerToys Run — the rofi stand-in, and how apps get launched |

Defined in `%LOCALAPPDATA%\Microsoft\PowerToys\PowerToys Run\settings.json`
under `properties.open_powerlauncher` (`alt=true, code=85`). Also enabled and
holding their own shortcuts: FancyZones, AlwaysOnTop, ColorPicker, Peek, Awake,
Shortcut Guide, Measure Tool, PowerRename, Image Resizer, File Locksmith,
FindMyMouse, MouseHighlighter, CmdPal.

There are deliberately **no per-application launch hotkeys** — `Win+L` to an
empty desktop then `Alt+U` is the whole "open this somewhere new" flow.

### WezTerm

| Key | Does |
|---|---|
| `Ctrl+=` / `Ctrl+-` | Font size ±0.5 pt per press, clamped 6–36 |
| `Ctrl+0` | Reset font size |
| `F11` | Toggle fullscreen |
| `Ctrl+.` `Ctrl+,` `Ctrl+;` | Emitted as CSI u — see below |
| `Ctrl+Backspace` | Rewritten to `Ctrl+W` (vim-tmux-navigator owns `Ctrl+H`) |
| `Alt+0`…`Alt+9` | Passed through to tmux |
| `Alt+Enter` | Passed through to Neovim |

---

## Files (Windows side)

Every one of these is copied into this repo. `sync-windows` moves them either
way — see "The Windows files are copies" at the bottom.

| Live path | In the repo | What |
|---|---|---|
| `C:\Users\alex\.config\ahk\sway.ahk` | `windows/.config/ahk/sway.ahk` | All Windows-side behaviour: hotkeys, dropdown, workspace indicator |
| `C:\Users\alex\.config\ahk\*-winl.reg` | `windows/.config/ahk/` | Frees Win+L, and the undo for it |
| `C:\Users\alex\.wezterm.lua` | `wezterm/.wezterm.lua` | Terminal config, shared with Linux |
| `C:\Users\alex\.wezterm-win.lua` | `windows/.wezterm-win.lua` | Read only by the Alt+E dropdown; adds WezTerm tabs and panes |
| `C:\Users\alex\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` | `windows/Documents/…` | Loaded by the Alt+E dropdown; defines the `ya` function |

Two more pieces of the setup are not files, so no copy can carry them.
`windows/install.ps1` creates both:

| | What |
|---|---|
| `%APPDATA%\…\Startup\sway.ahk.lnk` | Runs `AutoHotkey64.exe "…\sway.ahk"` at login |
| `YAZI_FILE_ONE` (user env var) | Points yazi at `file.exe` for MIME detection |

**Left out on purpose:** `%LOCALAPPDATA%\Microsoft\PowerToys\PowerToys Run\settings.json`.
PowerToys owns that file and rewrites it by itself, so tracking it would produce
diffs nobody made. The only setting that matters is `Alt+U`, written down above.

WSL side, symlinked from this repo as usual:
`~/.config/tmux/tmux.conf` → `tmux/.config/tmux/tmux.conf`, and
`~/.config/nvim` → `nvim/`.

---

## The desktop-switch animation

**No Windows animation setting is left changed.** An earlier attempt did change
one; this section exists so nobody repeats it.

### Why turning it off system-wide was wrong

Desktop switching animated for ~400 ms. The governing setting is
`SPI_CLIENTAREAANIMATION`, and turning it off did make switching instant — but
**Chromium maps `prefers-reduced-motion: reduce` directly onto that same
setting**, so every website and Chrome's own UI immediately began cutting their
animations. alex noticed within the day.

The two behaviours are one Windows switch and cannot be separated at the OS
level. Chromium cannot be told to ignore it either: `--force-prefers-reduced-motion`
only forces it *on*, and a flag for the opposite direction is an open feature
request, not a shipping option.

### What is done instead

What *can* be separated is who finds out. The shell reads the value **live**,
while applications only re-read it when a `WM_SETTINGCHANGE` broadcast arrives.
So `sway.ahk` flips it off with `fWinIni = 0` — neither persisted to the
registry nor broadcast — for the ~30 ms of a switch, and puts it straight back.
No application ever observes a change.

Measured: 402 ms of slide with it on, 0 ms with it quietly off, and
`SPI_GETCLIENTAREAANIMATION` reads 1 at rest before and after every switch.

Guards, because a leaked suppression is silent — the only symptom is websites
quietly going still:

- depth-counted, so a multi-step `Win+N` suppresses once rather than per step
- `try`/`finally` on every path that holds it, plus an `OnExit` handler
- a 1-second watchdog that force-releases anything still held after 3 seconds
- `VdGoto` abandons a walk the moment a step makes no progress, instead of
  retrying into repeated timeouts (that bug once held it suppressed for ~6 s)

Knob: `VD_QUIET_SWITCH := false` in `sway.ahk` leaves Windows entirely alone.

`MinAnimate` was also turned off during the first attempt and has been restored
to 1 — it turned out not to affect desktop switching at all.

### Five virtual desktops

Matches the persistent workspaces 1–5 the old waybar showed on Arch.
`VdEnsure()` tops the set up at startup and walks back to where you were; once
they exist it is a no-op. `VD_DESKTOPS` at the top of `sway.ahk` drives the
hotkey registration and the indicator width, so it is the only edit needed to
change the count.

---

## Mechanisms worth not re-deriving

**The workspace indicator is not a taskbar widget.** Windows 11 has no taskbar
extension point — deskbands were removed with Windows 10 and the taskbar is
closed XAML. The numbers are a borderless, topmost, `WS_EX_NOACTIVATE` window
laid over the empty left end of the bar. That space is empty *only because the
taskbar icons are centre-aligned*; left-aligning them would put icons on top of
it. It re-asserts its z-order every tick because Explorer periodically raises
the taskbar above it.

**Desktop state comes from the registry, not COM.** The documented interface
needs a build-matched helper DLL that breaks on most Windows releases. Instead
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops` gives
`VirtualDesktopIDs` (one 16-byte GUID per desktop, in order) and
`CurrentVirtualDesktop`. `RegRead` returns both as hex strings, so the active
index is a substring search. Measured to update within ~120 ms of a switch.

**Measured shell behaviour** (Windows 11 25H2 — re-measure on a major update):

- `Win+Ctrl+D` appends a desktop at the **end** and switches to it (1/3 → 4/4),
  never next to the current one.
- `Win+Ctrl+F4` closes the current desktop and lands you on the one to its
  **left** (3/4 → 2/3).
- There is no "go to desktop N" shortcut, so `VdGoto` walks one step at a time.

**Why the dropdown hands focus back explicitly.** `WinHide` leaves the hidden
window as the foreground window, so keystrokes go nowhere until something is
clicked. `ToggleTerm` picks the window to focus *before* hiding — afterwards the
foreground window is a hidden one and tells you nothing.

**Why WezTerm emits CSI u itself.** Neovim asks for the Kitty keyboard
protocol, but under tmux the program on the other end of WezTerm is tmux, and
tmux asks for xterm's `modifyOtherKeys` instead, which WezTerm does not answer.
So `Ctrl+.` and `Ctrl+,` silently did nothing. WezTerm now spells those keys out
as `ESC[<codepoint>;<mods>u` without waiting to be asked; tmux decodes that
regardless of what it negotiated upstream.

---

## Working on this machine

**Reload `sway.ahk`:** tray icon → Reload, or just run the script again —
`#SingleInstance Force` replaces the running copy.

**Validate before reloading** (exit 0 = clean):

```
AutoHotkey64.exe /ErrorStdOut /validate C:\Users\alex\.config\ahk\sway.ahk
```

**Tray menu:** Reload · Edit · Open log · Unhide all terminals · Workspace bar ·
Exit. Set `DEBUG := true` to get `sway.log` beside the script.

### Traps that cost real time

- **Inline shell through `wsl.exe` from PowerShell is unusable.** Quotes are
  stripped while building the Windows command line, `$vars` come out empty, and
  the remains land in zsh. Write the script to the scratchpad and run it by its
  `/mnt/c/…` path. Simple single-word commands (`wsl.exe -d Ubuntu tmux ls`)
  are fine.
- **An uncaught AHK v2 error opens a modal dialog and hangs.** `FileDelete` on a
  missing file is enough. Anything run unattended must wrap risky calls in
  `try`, and be launched with a timeout.
- **Driving these hotkeys from a test harness is a minefield.** Two independent
  problems, and both look identical from outside — nothing happens:
  - *Who is sending.* From another **AHK** script, `SendInput` is ignored by
    `sway.ahk`'s hook; it needs `SendMode "Event"` **and** `SendLevel 1`. From a
    **non-AHK** process, plain `keybd_event` is ordinary input and does fire the
    hotkeys — no special handling needed.
  - *How long the modifier is held.* `VdKeys` uses `{Blind}` so the Win key the
    user is physically holding gets reused. A harness that taps `Win+N` and
    releases Win microseconds later leaves `{Blind}^{Right}` sending a bare
    `Ctrl+Right`, which switches nothing. Hold the modifier down across the
    whole press, the way a hand does.

  A test that "passes" because nothing happened is the failure mode for both.
  Always assert the state actually changed, never just the absence of an error.
- **Verifying a desktop switch:** the registry updates while the animation is
  still playing, so keystroke-to-registry latency says nothing about what the
  user sees. Sample the framebuffer if the question is visual.
- **After installing anything, every process in the launch chain is stale.** A
  process inherits its environment at launch and never re-reads it. Installing
  yazi put it on the user `PATH`, but the dropdown could not find it because the
  chain was `this shell -> sway.ahk -> WezTerm -> PowerShell`, and *this shell*
  had started before the install. Restarting only the dropdown was not enough,
  and the symptom ("command not found") pointed at the wrong layer entirely.
  Refresh explicitly before relaunching anything:

  ```powershell
  $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' +
              [Environment]::GetEnvironmentVariable('PATH','User')
  ```

  A logout/login is the guaranteed fix, since every process then starts from the
  current registry environment.
- **Do not drive the screen while alex is using it.** Keystroke and screenshot
  tests land in whatever window has focus. One screenshot came back showing
  their live nvim session, which means the test keystrokes had been going there.
  Prefer checks that read state; when a visual check is genuinely needed, use a
  throwaway window with its own `--class`, or hand the verification to alex.

---

## The two dropdowns

`Alt+W` and `Alt+E` are the same Guake-style mechanism pointed at different
shells: WSL/zsh and PowerShell. Neither has a tab bar — window management is
`Win+1..5` and `Win+H/L`, the way it was under Sway. Stacking WezTerm tabs on
top of tmux windows on top of LazyVim buffers was considered and rejected as
three tab bars deep.

Both windows come from the same `.wezterm.lua`, so the font, size and Tango
colours are necessarily identical.

**Only one is ever on screen** (`DROP_EXCLUSIVE`): raising either puts the other
away. At `HEIGHT_PCT 100` they cover the same space, so the newer one buries the
older one regardless — this makes it deliberate and keeps the hidden one
tracked. Hidden, never closed: closing would take the tmux session and shell
history with it.

`HideOthers()` hands the outgoing dropdown's "what was underneath" memory to the
incoming one. Without that handover the incoming dropdown records the *outgoing
dropdown* as the window underneath it, and hiding it later tries to focus a
window that is itself hidden by then — dropping the user somewhere arbitrary
instead of where they started.

They are told apart by **window class**, and getting that right has two
requirements that are easy to miss:

- `--class` applies to every window of a WezTerm *instance*, so the Windows
  dropdown needs `--always-new-process`. Without it the new window joins the
  running WezTerm and inherits its class, and the two hotkeys start fighting
  over the same window.
- AHK's `ahk_class` is **not** an exact match by default. Match mode 2 means
  "contains", and `org.wezfurlong.wezterm.winshell` contains
  `org.wezfurlong.wezterm` — so a lookup for the Linux dropdown would happily
  return the PowerShell window. `SetTitleMatchMode 3` is what prevents that,
  and removing it would break the pair in a way that looks random.

`--domain local` is what selects PowerShell: `default_domain` is `WSL:Ubuntu`,
so a bare `-- powershell.exe` would try to run PowerShell *inside* Ubuntu.

The `gui-startup` handler in `.wezterm.lua` had to learn to stand aside when a
command is passed on the command line. Once such a handler exists WezTerm stops
spawning the initial window itself, but it still spawns a CLI-provided command —
so a handler that also spawns produces two windows. It now returns early when
`cmd` is present, and is unchanged for a plain launch.

The Windows dropdown is created lazily on the first `Alt+E` (a few seconds,
since it is a whole second WezTerm process) and then persists.

---

## Yazi on the Windows side

Installed 2026-08-26 via `winget install sxyazi.yazi` — version 26.8.15, the
same build as the WSL one.

`ya.exe` is yazi's CLI/IPC tool (`ya pkg`, `ya emit`), not a launcher — bare
`ya` prints usage and exits 2, in WSL just as much as here. alex wanted it to
open the file manager, so **`C:\Users\alex\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`**
(created 2026-08-26, there was no profile before) defines a `ya` function:

- no arguments → runs `yazi.exe --cwd-file`, then `Set-Location`s to wherever
  you were when you quit. Navigate in yazi, quit, and the shell is already there.
- any arguments → forwarded to `ya.exe`, so `ya pkg add ...` and `ya emit ...`
  still work. Calling `ya.exe` by full name resolves to the application rather
  than recursing into the function.

The dropdown runs `powershell.exe -NoLogo`, which does load profiles — but an
already-open shell needs `. $PROFILE` or a restart to see changes.

**Image preview works**, through the iTerm2 inline image protocol. `ya env` run
*inside WezTerm* reports `Brand: WezTerm` and `Drivers.matches: Iip`; run in the
plain console it reports `Sixel` instead, so the diagnostic is only meaningful
from the terminal you actually care about.

It needs the Unix `file` utility to detect MIME types — without it yazi refuses
to preview anything and says so. There is no standalone `file`/`libmagic`
package in winget, so it comes from **Git for Windows**, which bundles a Unix
userland (248 utilities in `C:\Program Files\Git\usr\bin\`: bash, sed, awk,
grep, curl, ssh...). Yazi wants none of git, only that one binary; the pairing
is a coincidence of packaging.

```
YAZI_FILE_ONE = C:\Program Files\Git\usr\bin\file.exe    (user scope, persisted)
```

Still absent, so those previews stay inert: `ffmpeg`/`ffprobe` (video
thumbnails), `pdftoppm` (PDF), `resvg` (SVG), plus `fzf`, `rg`, `fd`, `zoxide`,
`jq` for the fuzzy-jump integrations. All winget-installable.

---

## Installed programs

Three lists, and they are **not** the same list:

| Route | Coverage |
|---|---|
| `winget list` | ~95 packages — Win32 **and** Store/MSIX |
| Settings → Apps → Installed apps (`ms-settings:appsfeatures`) | same coverage, GUI |
| `appwiz.cpl` (Programs and Features) | **Win32 only** — silently omits every Store app |

That last one is the trap: it looks authoritative and is incomplete. Never use
it to answer "what is installed".

`winget` (v1.29.290) works from the WSL shell — the `WindowsApps` execution
alias survives interop here, which it often does not. Verified three ways:
`winget.exe`, `cmd.exe /c winget`, and `powershell.exe -Command winget` all
respond. So the pacman-equivalent flow runs straight from the dropdown terminal:

```
winget list | grep -i chrome          # find it
winget uninstall --id Google.Chrome   # remove it
```

Use `--id` with the Id column rather than the display name — names collide, Ids
do not. Machine-scope packages raise a UAC prompt on the Windows side even when
invoked from zsh.

PowerToys Run reaches the same places, but the relevant plugins are **not
global**, so their prefix is mandatory — typing `uninstall` bare matches nothing:

| Prefix | Plugin | Use |
|---|---|---|
| `$` | Windows settings | `$uninstall` or `$apps` → opens `ms-settings:appsfeatures` |
| `>` | Shell | `> winget uninstall --id X` |
| `.` | Program | launches only; PowerToys Run has no uninstall action |

---

## Deliberately not implemented

**Moving a window between desktops (`Win+J/K` in Sway).** Asked for on
2026-08-26 and declined after measuring the options. Do not re-propose without
new information.

Windows has no shortcut for this at all. The documented
`IVirtualDesktopManager::MoveWindowToDesktop`
(CLSID `{AA509086-5CA9-4C25-8F95-589D3C07B48A}`, vtable slot 5) **fails with
`0x80070005 Access is denied` for windows owned by another process** — measured
here against Notepad. It only works on the caller's own windows, so it is
useless for a hotkey script.

The working route is the undocumented `IVirtualDesktopManagerInternal`, either
via Ciantic's prebuilt `VirtualDesktopAccessor.dll`
(`MoveWindowToDesktopNumber`; requires ≥ 24H2 26100.2605, tested on 25H2
26200.8117 — this machine is 26200.8653, so it would work) or by hand-rolling
the same COM plumbing in AutoHotkey.

**alex chose to stay dependency-free** rather than add a third-party binary
pinned to the Windows build. Treat that as a standing preference for this
setup, not a one-off: prefer a missing feature over a downloaded binary unless
alex says otherwise. Moving a window between desktops is a Task View job
(`Win+Tab`, drag) for now.

---

## The Windows files are copies, not symlinks

`windows/` in this repo and the live files under `C:\Users\alex` are copies of
each other, currently byte-identical.

They are not symlinked, on purpose: these files are read at launch, and a Windows
symlink into `\\wsl.localhost\…` fails whenever the distro is not yet running.
`sway.ahk` starts at login, before WSL is up. A copy always works; it just has to
be kept honest.

**Keeping them honest:** `sync-windows` (in `bin/.local/bin`, so it stows onto
`$PATH`). Run it from WSL.

```
sync-windows          # show what drifted, change nothing
sync-windows pull     # Windows -> repo, capturing edits made on Windows
sync-windows push     # repo -> Windows, then reload sway.ahk / restart WezTerm
```

It assumes the WSL user name matches the Windows one. Set `WIN_HOME` if not.

### Rebuilding this on a new machine

1. Install the pieces:
   `winget install AutoHotkey.AutoHotkey Git.Git Microsoft.PowerToys sxyazi.yazi wez.wezterm`
   Git is wanted only for the Unix `file.exe` that yazi needs.
2. Install WSL Ubuntu, clone this repo into it, run `./install.sh`.
3. From WSL: `sync-windows push` — puts every config file in place.
4. From PowerShell: `powershell -ExecutionPolicy Bypass -File windows\install.ps1`
   — makes the login shortcut and sets `YAZI_FILE_ONE`.
5. By hand: run `.config\ahk\enable-winl.reg` as admin and sign out, then bind
   `Alt+U` in PowerToys Run settings.

### Why .wezterm.lua is not in windows/

One file serves both platforms — it branches on `wezterm.target_triple`, so
`window_decorations` is `RESIZE` on Windows and `NONE` on Linux (where Sway drew
the border), and `default_domain = "WSL:Ubuntu"` is set only on Windows. There is
no per-platform version to keep apart, so it stays in the `wezterm` stow package:
Linux gets it as a symlink, and `sync-windows` copies that same file to Windows.

`.wezterm-win.lua` is genuinely Windows-only, so it does live in `windows/`.

*History, so the same reasoning is not redone:* the repo copy sat 37 lines
behind for a while — it was missing the `is_windows` branch, the WSL default
domain, and the whole CSI u block, meaning the Windows terminal config was not
backed up anywhere. Reconciled 2026-08-26 by copying Windows → repo. That was
safe rather than a merge: the Windows file was a strict superset, and the repo's
one uncommitted change (`enable_kitty_keyboard = true`) was an earlier, partial
version of work the Windows file already carried in full. The live Windows file
was deliberately not touched — it was working.
