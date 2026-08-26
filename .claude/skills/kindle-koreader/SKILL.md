---
name: kindle-koreader
description: Manage the user's Kindle Paperwhite 7th gen running KOReader — copy books, manage dictionaries, clean junk files, safely eject. Triggers when user types /kindle, says "transfer books to kindle", "add books to reader", "sync kindle", "new books for reader", or mentions Kindle/KOReader file operations.
---

# Kindle + KOReader management

The user has a **Kindle Paperwhite 7th generation** running **KOReader** (with KUAL launcher). The device was bought used and is **deliberately not registered** with Amazon and must **never receive updates**. Avoid Wi-Fi suggestions unless asked — work via USB.

## Where things are

The paths differ per machine. Work out these two first, then use them everywhere below.

| | Linux desktop | WSL on the HP |
|---|---|---|
| `$KINDLE` | `/media/alex/Kindle` | `/mnt/kindle` — mount it first, see below |
| `$BOOKS` | `/home/alex/Downloads/books` | `/mnt/c/Users/alex/Downloads/books` |

Inside the Kindle, the layout is the same either way:

- **Books:** `$KINDLE/documents/`
- **KOReader dictionaries:** `$KINDLE/koreader/data/dict/`

Check it is connected with `ls $KINDLE/documents/`. If that errors with "No such
file", the device is not mounted — on Linux ask the user to plug it in, on WSL
mount it first.

### Mounting on WSL

WSL cannot see USB devices. It does not need to — the Kindle is plain mass storage,
so Windows mounts it as a drive letter and WSL reaches it through drvfs.

Find the letter in Explorer (usually `E:`), then:

```bash
sudo mkdir -p /mnt/kindle
sudo mount -t drvfs E: /mnt/kindle
```

Every command below then works unchanged.

## Source library on the user's PC

Root: `$BOOKS`

Subfolders (organized by category):
- `fiction/` — novels
- `non_fiction/` — general non-fiction
- `electronics/` — electronics/embedded systems technical books

The user prefers organized subfolders. When new books appear in the `books/` root (typically downloaded with `_OceanofPDF.com_` prefix and underscores), categorize them and rename to a clean format: `Title - Author.ext`.

## Standard workflow when user adds new books

1. **Find new books** in `$BOOKS/` (root level — that's where downloads land):
   ```bash
   find $BOOKS -maxdepth 1 -type f \( -name "*.epub" -o -name "*.mobi" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.fb2" \)
   ```

2. **List them to the user**, identify categories, ask if they want them organized into a specific subfolder.

3. **Rename & move:** strip the `_OceanofPDF.com_` prefix, replace underscores with spaces, normalize to `Title - Author.ext`. Move into the appropriate subfolder.

4. **Check if Kindle is connected:** `ls $KINDLE/documents/` — if not, tell user to plug in.

5. **Copy books to Kindle:**
   ```bash
   cp "$BOOKS/<subfolder>/<book>" $KINDLE/documents/
   ```
   For a category like electronics, the user prefers a subfolder on the Kindle too: `$KINDLE/documents/electronics/`.

6. **Clean junk files** that the Kindle's native firmware creates between sessions (always check after connecting):
   ```bash
   rm -rf $KINDLE/documents/KPP*
   rm -f $KINDLE/documents/._*
   ```
   - `KPP*` = Kindle crash logs (`.tgz`, `.txt`, `.sdr` folders) — safe to delete
   - `._*` = macOS metadata junk — safe to delete
   - **Keep** `KUAL.kual` (launcher file for the jailbreak), and **keep `.sdr` folders next to real book files** (they hold reading progress)

7. **Safely eject** when done:
   ```bash
   sync && sudo umount $KINDLE
   ```
   If "target is busy", use `sudo umount -l $KINDLE` (lazy unmount).

   On WSL that only detaches it from Linux. Windows still holds the drive, so the
   user must also eject it there — tray icon, or right-click the drive in Explorer.
   Tell them to do that; the agent cannot eject from inside WSL.

## Vocabulary builder (saved words)

KOReader's Vocabulary Builder plugin stores words the user saves while reading. Location:

**`$KINDLE/koreader/settings/vocabulary_builder.sqlite3`**

Two tables: `vocabulary` (word, title_id, create_time, review_time, due_time, review_count, prev_context, next_context, streak_count) and `title` (id, name — the book title).

Query saved words with book titles, newest first:
```bash
sqlite3 $KINDLE/koreader/settings/vocabulary_builder.sqlite3 \
  "SELECT v.word, t.name, datetime(v.create_time, 'unixepoch') FROM vocabulary v LEFT JOIN title t ON v.title_id = t.id ORDER BY v.create_time DESC;"
```

Use this when the user asks about words they've saved, wants to extract them (for Anki/CSV/Obsidian), or wants a progress report.

## Highlights & notes

KOReader stores per-book annotations in **sidecar folders** next to each book:

**`$KINDLE/documents/<Book Name>.sdr/metadata.epub.lua`**

The file is a Lua table. Highlights live under the `annotations` key — each entry has:
- `notes` — the highlighted text (and any user note appended)
- `text` — formatted as `Page N <highlighted text> @ <timestamp>`
- `page` — internal location reference
- `highlighted = true` — whether it's a highlight

Quick extraction of all highlights/notes from a specific book:
```bash
grep -E '"notes"|"text"' "$KINDLE/documents/<Book>.sdr/metadata.epub.lua"
```

To find all books that have annotations:
```bash
find $KINDLE/documents -name "metadata.epub.lua" -path "*.sdr/*"
```

Use this when the user asks about highlights, notes, what they've marked in a book, or wants to export annotations.

**Important:** `.sdr` folders also hold reading progress. **Never delete a `.sdr` folder unless the user explicitly asks** — except `KPP*.sdr` (crash log folders) which are always safe to delete.

## Dictionaries (already installed)

Inside `$KINDLE/koreader/data/dict/`:
- **`en-ru.*`** — bookname "AA EN-RU WikDict" (the "AA" prefix makes it sort first so it's the default when long-pressing words). English → Russian, 61k words, FreeDict+WikDict source.
- **`en-en.*`** — bookname "EN-EN Wiktionary" (secondary). English → English definitions, 944k words.

KOReader picks the default dictionary alphabetically by bookname. **Don't rename them unless the user asks** — the "AA" prefix is intentional.

If the user wants more dictionaries:
- **WikDict** (lightweight FreeDict bilingual): `https://download.wikdict.com/dictionaries/stardict/` — files named `wikdict-<from>-<to>.zip`
- **Wiktionary StarDict** (richer, monthly snapshots): `https://xxyzz.github.io/wiktionary_stardict/` — files named `<from>-<to>.tar.zst`
- Extract to `/tmp/`, copy `.ifo`, `.idx`, `.dict.dz`, `.syn` files into the Kindle dict folder.

## Important guardrails

- **Never suggest enabling Wi-Fi on the Kindle.** The seller warned against updates and registration. Stick to USB transfer.
- **Never suggest registering the Kindle with Amazon.**
- **Don't run `apt install` or other sudo commands without explaining first** — the user runs commands themselves when sudo is needed (the agent's bash can't prompt for passwords).
- **Don't auto-eject** — wait for the user to confirm they're done. Just remind them of the eject command at the end.

## Format guidance

- **epub** = best for the 6" e-ink screen, reflows perfectly
- **pdf** = only usable if text-based and reflowed in KOReader (Settings → document settings → Reflow). Scanned PDFs are painful on this screen.
- The user sometimes keeps duplicate epub+pdf versions to compare rendering on the device — don't dedupe unless asked.

## Quick reference

| Task | Command |
|---|---|
| Check if connected | `ls $KINDLE/documents/` |
| Copy book | `cp "<source>" $KINDLE/documents/` |
| Clean junk | `rm -rf $KINDLE/documents/KPP* $KINDLE/documents/._*` |
| Safe eject | `sync && sudo umount $KINDLE` |
| Force eject | `sudo umount -l $KINDLE` |
