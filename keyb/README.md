# keyb — toggle the laptop keyboard

Turns the laptop's **built-in** keyboard off and on. Made for resting an
external split keyboard (Ferris/Corne) on top of the laptop without the laptop
keys firing by accident. External keyboards are never affected.

## Use

```bash
keyb        # run once → disable. run again → enable.
```

A notification shows the new state ("DISABLED" / "ENABLED").

> When the laptop keyboard is disabled, turn it back on from your **external**
> keyboard (the laptop keys are dead).

## What's in this package

| File | Goes to | What it is |
|------|---------|------------|
| `.local/bin/keyb` | `~/.local/bin/keyb` (Stow) | the command you run |
| `system/laptop-kbd` | `/usr/local/sbin/laptop-kbd` (manual, root) | does the privileged on/off |
| `system/kbdtoggle` | `/etc/sudoers.d/kbdtoggle` (manual, root) | lets `keyb` run the helper with no password |

The `keyb` command is a normal Stow package. The two `system/` files can't be
Stow-linked (they live in root-owned folders), so they're installed by hand —
see below.

## Where to edit

- **The command itself:** `~/dotfiles/keyb/.local/bin/keyb` (live via Stow — edit
  and it works right away).
- **Which keyboard it targets:** the `NAME=` line, in **both** `keyb` and
  `system/laptop-kbd`. They must match. On a new laptop the built-in keyboard
  may have a different name — find it with:
  ```bash
  grep -i keyboard /proc/bus/input/devices     # look for the built-in one
  # (often "AT Translated Set 2 keyboard")
  ```
  If you change `system/laptop-kbd`, re-copy it to `/usr/local/sbin/` (below).

## Install on a new machine

1. Stow the command:
   ```bash
   cd ~/dotfiles && stow keyb
   ```
2. Install the root helper:
   ```bash
   sudo cp ~/dotfiles/keyb/system/laptop-kbd /usr/local/sbin/
   sudo chmod 755 /usr/local/sbin/laptop-kbd
   ```
3. Install the sudo rule (no password prompt):
   ```bash
   sudo cp ~/dotfiles/keyb/system/kbdtoggle /etc/sudoers.d/kbdtoggle
   sudo chmod 440 /etc/sudoers.d/kbdtoggle
   ```
4. Check: `keyb` should toggle the laptop keyboard.

## Optional: a keyboard shortcut

Bind a key on your **external** keyboard to run `keyb`:

Settings → Keyboard → Keyboard Shortcuts → Custom Shortcuts → **+**
- Command: `/home/alex/.local/bin/keyb`
- Shortcut: a key on the external keyboard (so you can re-enable when the
  laptop keys are off).

## Why it works this way

See [PROBLEM.md](PROBLEM.md) — the simpler methods (xinput, driver unbind) failed
for a specific reason, and `inhibited` is the one that works.
