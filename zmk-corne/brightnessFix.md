# External Monitor Brightness Fix

## Problem

Pressing F3/F4/F5 (bound via GNOME custom shortcuts to ext-bright scripts) caused the entire system to freeze.

**Root cause:** The scripts called `ddcutil setvcp 10` without specifying an I2C bus. `ddcutil` then probed all 8 I2C buses (`/dev/i2c-0` through `/dev/i2c-7`). Bus `/dev/i2c-7` is the internal laptop eDP panel (LGD), which does not support DDC/CI — this caused a kernel-level I2C hang that froze the whole system.

## Setup

- ZMK Corne keyboard, **Layer 3**: `C_BRI_UP` / `C_BRI_DN` control laptop backlight (via `XF86MonBrightnessUp/Down`)
- ZMK Corne keyboard, **Layer 3**: **F3** = brightness up, **F4** = brightness down, **F5** = brightness default (20%) for **external monitor**
- GNOME custom shortcuts bind F3/F4/F5 to scripts in `~/.local/bin/`
- External monitor: **Lenovo Legion R27qe**, connected via HDMI → `/dev/i2c-6`
- Laptop internal display: LGD eDP on `/dev/i2c-7` (does NOT support DDC/CI)

## Fix Applied

Added `--bus 6` to all three scripts so `ddcutil` talks only to the correct I2C bus:

- `~/.local/bin/ext-bright-up.sh`      → `ddcutil --bus 6 setvcp 10 + 5`
- `~/.local/bin/ext-bright-down.sh`    → `ddcutil --bus 6 setvcp 10 - 5`
- `~/.local/bin/ext-bright-default.sh` → `ddcutil --bus 6 setvcp 10 20`

## If the Bus Number Changes

Bus numbers can rarely change after reconnecting the monitor or rebooting. To find the correct bus run:

```bash
ddcutil detect
```

Look for the Lenovo Legion R27qe entry and note its `I2C bus: /dev/i2c-X`. Update the `--bus X` value in all three scripts above.

## GNOME Shortcuts (for reference)

| Key | Action              | Script                              |
|-----|---------------------|-------------------------------------|
| F3  | Brightness up (+3)  | `~/.local/bin/ext-bright-up.sh`     |
| F4  | Brightness down (-3)| `~/.local/bin/ext-bright-down.sh`   |
| F5  | Brightness default  | `~/.local/bin/ext-bright-default.sh`|
