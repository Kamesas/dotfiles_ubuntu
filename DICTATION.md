# Voice Dictation Setup

Offline push-to-talk dictation for the whole desktop (Sway session).
Press **Alt+V** anywhere, speak, press **Alt+V** again — the text is typed
into the focused window. Works in English and Ukrainian (auto-detected).
Everything runs locally, no internet needed, no cost.

## How to use

- **Alt+V** or click the mic icon in waybar → start recording.
  The bar shows a red ` REC`.
- Speak.
- **Alt+V** (or click `REC`) → stop. The bar shows ` …` while the model
  works (about 1 s per short phrase), then the text is typed into the
  focused window.
- **Alt+Shift+V** to stop instead → forced-Ukrainian mode: slower (~6 s)
  but clean Ukrainian. The key that *stops* the recording picks the
  engine, so you can decide at the end.

The keyboard layout also steers the language:

- **Ukrainian layout active** → every dictation is pinned to Ukrainian
  automatically (~6 s), no Alt+Shift+V needed.
- **English layout** → the fast engine runs (~1 s). If it returns mostly
  Cyrillic anyway (it sometimes writes English speech in Ukrainian
  letters), the script notices the mismatch with the layout and redoes it
  pinned to English (~+2.5 s).
- Consequence: to dictate Ukrainian, either switch the layout to Ukrainian
  first or stop with Alt+Shift+V. Ukrainian spoken with an English layout
  and stopped with plain Alt+V will be forced into English.
- Idle state: dim mic icon in the bar. Hover it for a hint.
- In **nvim** enter insert mode first — otherwise the letters run as
  normal-mode commands.

Notifications appear only on problems:

- **"Mic is muted"** — unmute first (Alt+M menu or click the mic module).
- **"Heard nothing"** — the model returned empty text. The audio is kept at
  `/run/user/1000/dictate-failed.wav`; play it to check what the mic heard.
  Usual causes: muted mic or the wrong default source (dock mic vs internal).
- **"Can't reach wezterm"** — the wezterm CLI socket was not found.

## Parts

| File | Role |
|---|---|
| `bin/.local/bin/dictate` | Toggle script: record → transcribe → type |
| `bin/.local/bin/dictate-status` | Waybar module state (idle / recording / busy) |
| `sway/.config/sway/config` | `bindsym Alt+v exec ~/.local/bin/dictate` |
| `waybar/.config/waybar/config` | `custom/dictate` module (signal 10, click to toggle) |
| `waybar/.config/waybar/style.css` | Module colors: dim idle, red recording, peach busy |
| `~/.local/opt/whisper.cpp/` | Speech-to-text engine (outside dotfiles, see below) |

Runtime files live in `/run/user/1000/`: `dictate.pid`, `dictate.wav`,
`dictate.state`, `dictate.log` (one line per run with timings and the mic
used), `dictate-failed.wav` (audio of the last empty result).

## How it works

1. First run: `pw-record` starts capturing the default mic to a 16 kHz mono
   WAV. A pidfile marks "recording". The script refuses to start if the mic
   is muted.
2. Second run: the recorder is stopped and the engine is chosen — forced
   Ukrainian (whisper small `-l uk`) when the `uk` argument was given or
   any keyboard reports a Ukrainian active layout (checked via
   `swaymsg -t get_inputs`), otherwise `parakeet-cli` (NVIDIA Parakeet TDT
   0.6B v3, quantized q8_0). Parakeet is the default because on this CPU
   (i7-8550U) it is ~20x faster than whisper `small` and ~3x faster than
   whisper `base`, with punctuation and better accuracy. Whisper pads every
   clip to 30 s, so it costs seconds even for a 2-second phrase; Parakeet's
   cost scales with the real audio length. If Parakeet returns a mostly
   Cyrillic result under an English layout, the run is redone with whisper
   `base` pinned to English (Parakeet sometimes writes English speech in
   Ukrainian letters). The `engine=` field in the log shows what ran:
   `auto`, `uk`, or `en-retry`.
3. The text is delivered to the focused window:
   - **WezTerm windows**: WezTerm ignores the Wayland virtual-keyboard
     protocol, so `wtype` never reaches it. The script detects a focused
     wezterm window via `swaymsg -t get_tree` and injects the text with
     `wezterm cli send-text --pane-id N`. Outside a wezterm pane the CLI
     picks the mux socket and sees no windows, so the script first points
     `WEZTERM_UNIX_SOCKET` at the newest
     `$XDG_RUNTIME_DIR/wezterm/gui-sock-*`.
   - **Chrome/Chromium windows**: Chrome unreliably drops text typed
     through the virtual-keyboard protocol, so the script pastes instead —
     the text is always copied to the clipboard first, and Chrome gets a
     single Ctrl+V keystroke.
   - **Everything else** (kitty, GTK apps…): `wtype` types the text
     through the virtual-keyboard protocol. Full Unicode works.
4. The waybar module re-reads the state file whenever the script sends
   `SIGRTMIN+10` to waybar (signals 8 and 9 are already used by the
   notification and mic modules).

## Models

Engine and models live in `~/.local/opt/whisper.cpp` (built from
[ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp)):

- `models/ggml-parakeet-tdt-0.6b-v3-q8_0.bin` — default engine (Alt+V).
  25 European languages, auto language detection, ~1 s per phrase. No way
  to force a language — the CLI has no language option. Weakness: mixes
  Russian into Ukrainian speech.
- `models/ggml-small.bin` — Ukrainian engine (Alt+Shift+V), run with
  `-l uk` pinned, ~6 s per phrase. Pinning the language matters twice:
  it skips the detection pass (auto-detect costs ~20 s, pinned ~6 s) and
  it stops the Russian drift.
- `models/ggml-base.bin` — spare. Faster than small (~3 s), weaker quality;
  not wired to any key.

Other options if quality ever needs a push, all slower on this CPU:
`ggml-medium.bin` (~1.5 GB, several times slower than small, noticeably
better Ukrainian) and `ggml-large-v3-turbo.bin` — download with
`sh ./models/download-ggml-model.sh medium` and swap the model path in
`dictate`. Community fine-tuned Ukrainian Whisper models exist on Hugging
Face but need manual conversion to ggml.

## Rebuild from scratch

```sh
sudo pacman -S --needed wtype cmake wl-clipboard
git clone --depth 1 https://github.com/ggml-org/whisper.cpp ~/.local/opt/whisper.cpp
cd ~/.local/opt/whisper.cpp
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j$(nproc)

# Parakeet model (~1.2 GB f16), then quantize to ~640 MB q8_0
curl -L -o models/ggml-parakeet-tdt-0.6b-v3-f16.bin \
  "https://huggingface.co/ggml-org/parakeet-GGUF/resolve/main/ggml-parakeet-tdt-0.6b-v3-f16.bin"
./build/bin/parakeet-quantize models/ggml-parakeet-tdt-0.6b-v3-f16.bin \
  models/ggml-parakeet-tdt-0.6b-v3-q8_0.bin q8_0
rm models/ggml-parakeet-tdt-0.6b-v3-f16.bin

# Optional whisper fallback models
sh ./models/download-ggml-model.sh base
sh ./models/download-ggml-model.sh small
```

Then stow/symlink `bin`, reload sway (`Super+Shift+C`) and waybar
(`pkill -SIGUSR2 waybar`).

## Troubleshooting

- Slow or wrong text → check `/run/user/1000/dictate.log`: it shows audio
  length, model time in ms, which mic was used, focused window, and how the
  text was delivered (`wtype` or `wezterm-cli`).
- Text lands nowhere in a terminal → probably a WezTerm window that the
  focus detection missed; check the `focused=` field in the log.
- Text lands nowhere in the browser → the dictated text is always in the
  clipboard as well, so **Ctrl+V** pastes what should have been typed.
  Check the cursor is in a text field. If even the automatic paste fails,
  the next escalation is ydotool (kernel-level input, needs a daemon and
  udev setup).
- Empty results → listen to `dictate-failed.wav`; check the default source
  in the mic menu (dock mic vs internal mic).
- No mic icon in the bar → the icon is a nerd-font private-use character
  inside `dictate-status`; some editors and tools silently drop it, which
  makes the idle text empty and waybar hides an empty module. Check with
  `grep -cP '\x{f130}' ~/.local/bin/dictate-status` (should print 4).
