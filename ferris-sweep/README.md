# Ferris Sweep QMK Configuration

cd ~/qmk_firmware && qmk compile -e CONVERT_TO=rp2040_ce -kb ferris/sweep -km alex
cp ~/qmk_firmware/ferris_sweep_alex_rp2040_ce.uf2 /media/alex/RPI-RP2/

Clicking keys: Tab Esc   Del Backspace   Space Enter 

Working combos:
  - J + K = ESC ✓
  - K + L = Backspace ✓
  - D + F = CAPS LOCK ✓
  - E + R = [ ✓
  - U + I = ] ✓
  - C + V = { ✓
  - M + , = } ✓
  - Space + Backspace = Layer 5 ✓

Custom keymap for the Ferris Sweep keyboard with home row mods, layers, and combos.

## Installation & Setup

### 1. Install QMK CLI
```bash
curl -fsSL https://install.qmk.fm | sh
```

### 2. Setup QMK Firmware Repository
```bash
qmk setup
```
This clones the QMK firmware repository to `~/qmk_firmware` and sets up the build environment.

### 3. Create Symlink to Dotfiles
```bash
ln -s ~/dotfiles/ferris-sweep ~/qmk_firmware/keyboards/ferris/keymaps/alex

```
This links your dotfiles configuration to the QMK firmware directory, so any changes you make in your dotfiles are automatically available for compilation.

### 4. Set QMK Defaults (Optional but Recommended)
```bash
qmk config user.keyboard=ferris/sweep
qmk config user.keymap=alex
```

**Purpose of defaults:** These settings save you from typing `-kb ferris/sweep -km alex` every time you compile. Without defaults, you need the full command; with defaults, you can use the shorter version.

Without defaults:
```bash
qmk compile -e CONVERT_TO=rp2040_ce -kb ferris/sweep -km alex
```

With defaults:
```bash
qmk compile -e CONVERT_TO=rp2040_ce
```

## Making Changes to Your Keymap

1. **Edit the keymap files** in this directory (`~/dotfiles/ferris-sweep/`):
   - `keymap.c` - Layer definitions, key mappings, combos
   - `config.h` - Configuration (tapping term, mouse settings, etc.)
   - `rules.mk` - Feature flags (combos, split keyboard, etc.)

2. **Compile the firmware** after making changes:
   ```bash
   # Short version (uses defaults configured in step 4)
   qmk compile -e CONVERT_TO=rp2040_ce

   # Full version (works without defaults)
   # Replace <keymap> with your keymap name (e.g., "alex")
   # This is the keymap directory name, not a file name
   qmk compile -e CONVERT_TO=rp2040_ce -kb ferris/sweep -km <keymap>
   ```

3. **The compiled firmware** will be at:
   ```
   ~/qmk_firmware/ferris_sweep_alex_rp2040_ce.uf2
   ```

## Flashing Your Ferris Sweep

When you receive your Ferris Sweep keyboard:

1. **Enter bootloader mode:**
   - Hold the BOOT button on the microcontroller
   - While holding BOOT, plug in the USB cable
   - Release the BOOT button
   - The keyboard should appear as a USB mass storage device (like a USB drive)

2. **Flash the firmware:**
   - Copy the `.uf2` file to the mounted drive:
     ```bash
     cp ~/qmk_firmware/ferris_sweep_alex_rp2040_ce.uf2 /path/to/mounted/drive/
     ```
   - Or use drag-and-drop in your file manager
   - The keyboard will automatically reboot with the new firmware

3. **Test your keymap** and iterate on changes as needed

## Current Keymap Features

- **Home row mods:** Win/Alt/Ctrl/Shift on A/S/D/F (left), J/K/L/; (right)
- **6 layers:**
  - Layer 0: Base (QWERTY)
  - Layer 1: Numbers & Navigation
  - Layer 2: Symbols
  - Layer 3: Media & Function keys
  - Layer 4: Mouse keys
  - Layer 5: F-keys
- **Combos:**
  - E+R → [
  - U+I → ]
  - C+V → {
  - M+, → }
  - J+K → ESC
  - D+F → CAPS
  - SPC+TAB → Layer 5
- **Tapping term:** 200ms for home row mods
- **Mouse key support:** Layer 4

## Useful Commands

- **Compile (short):** `qmk compile -e CONVERT_TO=rp2040_ce`
- **Compile (full):** `qmk compile -e CONVERT_TO=rp2040_ce -kb ferris/sweep -km <keymap>`
  - Replace `<keymap>` with your keymap directory name (e.g., "alex")
- **Clean build:** `qmk clean && qmk compile -e CONVERT_TO=rp2040_ce`
- **View current config:** `qmk config`
- **Format code:** `qmk format-c`

## Notes

- The `CONVERT_TO=rp2040_ce` flag is required for RP2040-based controllers
- Changes in this directory are immediately available for compilation (no copying needed, thanks to symlink)
- Commit your keymap changes to dotfiles repository to track your layout evolution
