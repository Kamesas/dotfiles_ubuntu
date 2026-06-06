# Why disabling the laptop keyboard was tricky

The goal looked simple: turn off the built-in laptop keyboard so a split
keyboard resting on top doesn't press its keys. Two obvious methods failed.
Here's what happened and why the final fix is what it is.

## Setup that matters

- **kanata** grabs the laptop keyboard and remaps it to the Corne layout.
  "Grab" means kanata takes the device exclusively at the kernel input layer
  (below X11). The external Ferris is *excluded* from kanata (it remaps itself
  in firmware).
- So the laptop keyboard is always held by kanata while kanata runs.

## Method 1 — `xinput disable` (failed)

`xinput` works at the **X11** layer. But kanata reads the keyboard at the
**kernel evdev** layer, which is *below* X11. So disabling it in X11 did nothing
to kanata — keys still came through. Wrong layer.

## Method 2 — unbind the kernel driver (failed in a sneaky way)

Idea: detach the keyboard's driver (`atkbd` / `serio0`) so the device
disappears. While **idle**, this worked — the input device vanished.

But the moment a key was pressed, the **hardware re-detected itself** and the
driver re-bound instantly. Worse: kanata had been stopped to release its grab,
so the freshly re-bound keyboard typed **raw** (unmapped). Net result: press a
key and the keyboard came right back. A dead end for this hardware.

Symptom we saw: the notification said "disabled", but typing still worked and
produced raw characters.

## Method 3 — the `inhibited` attribute (works)

Modern Linux input devices expose `/sys/class/input/inputN/inhibited`.
Writing `1` tells the **input core** to stop the device — it stops delivering
events to everyone, including grabbers like kanata. Crucially it does **not**
unbind the device, so:

- A keypress can't re-detect it (the device was never removed).
- kanata keeps its grab. When we write `0` again, events flow and remapping
  resumes on its own — no kanata restart needed.

That's what `keyb` uses. The input node number (`inputN`) changes over time, so
the scripts look it up by name each run.

## One-line lesson

To disable an input device that another program (kanata) has grabbed, use the
kernel `inhibited` flag — not X11 (`xinput`), and not a driver unbind (the
hardware re-detects on keypress).
