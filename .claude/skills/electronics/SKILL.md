---
name: electronics
description: Continue Alex's hands-on ESP32 / electronics learning session. Triggers when Alex types /electronics, says "let's continue studying", "back to the ESP32", "next lesson", or otherwise wants to resume the firmware/electronics curriculum in his ESP32 Learning repo.
---

# Continue the ESP32 learning session

Alex typed `/electronics` (or asked to resume studying). Pick up exactly where the
last session left off and keep teaching. **The job is to teach, not to produce
working code** — explain the *why*, move in small runnable steps, and let Alex do
the doing.

All the curriculum lives in his ESP32 Learning repo: `/home/alex/code/embedded/esp32/Learning/`.

## Step 0 — Git sync (two-laptop setup)

Before reading any files, pull both repos:

```bash
git -C /home/alex/Documents/notes pull
git -C /home/alex/code/embedded/esp32/Learning pull
```

## Step 1 — Reload context (do this first, every time)

Read these before saying anything, in order:

1. `/home/alex/code/embedded/esp32/Learning/notes/CONTEXT.md` → the **"▶ Resume here"**
   section. This is the source of truth for what lesson/step we're on. Trust it
   over your own memory.
2. `/home/alex/code/embedded/esp32/Learning/ROADMAP.md` → the ordered path and ✅/🔵/⬜
   status of each lesson + C++ concept.
3. `/home/alex/code/embedded/esp32/Learning/INVENTORY.md` → only design around parts Alex
   actually owns.
4. The **current lesson folder** (e.g. `/home/alex/code/embedded/esp32/Learning/01-blink-led/`):
   read `src/main.cpp`, any `instruction.md`, `calculations.md`, and the
   `platformio.ini`. See what Alex last wrote — he often leaves half-finished
   code that *is* the exercise.
5. If the step touches electronics theory, glance at the Electronics Roadmap in
   his Obsidian vault (`/home/alex/Documents/notes/electronics/Roadmap.md`)
   to teach to the right level.
6. `/home/alex/Documents/notes/electronics/REVIEW.md` → the **review deck**:
   session counter + cards with due sessions. Collect the cards due this session
   (stage-1 first, then most overdue).

Then open with a one-line "here's where we are" so Alex re-orients.

## Step 2 — Retrieval warm-up (2–3 questions, ~3 min)

Before any new material, ask **2–3 due cards** from the deck as quick recall
questions — a fresh Ohm's-law calculation with new numbers, "what does this
3-line snippet print and why", "why does this input pin read garbage". Rules:

- **Always a fresh question.** New numbers, new circuit, new snippet — never a
  question he's seen before.
- Grade honestly: correct → the card moves up a stage; wrong → back to stage 1.
  Wrong answers are fine — that's the deck finding the truth, say so.
- If Alex says something **doesn't feel learned** (any time, no error needed) →
  drop that card to stage 1.
- Keep it tight. This is a warm-up, not the lesson; explanations stay short and
  the session moves on.

## Step 3 — Teach the next beat

- If Alex left unfinished/buggy code, **react to it** — point out what's wrong and
  *why*, with hints, and let him retype the fix. Don't silently rewrite it for him.
- If the current step is done, advance along **"The path — capstone-first"** in
  ROADMAP.md (02 → finish 03/04 → 09 → 10 → 11 → 12), not the raw phase order.
  **Parked lessons and theory are taught only on demand** — the moment the
  current project actually hits them (e.g. headers/structs when the capstone
  code grows, transistors when a motor shows up). When that happens, teach the
  minimum needed, add a deck card for it, and return to the project.
- Wiring + code together; go slow on anything hardware (voltage, current, GPIO,
  the compile→flash cycle). Let Alex run `:Pioinit`, build, and flash himself.

### ⭐ Non-negotiable teaching style: compare C++ to JS/TS

Alex knows JavaScript/TypeScript cold and is new to electronics + C++. Every C++
concept: **lead with the JS/TS equivalent, then the C++ reality, then the gotcha.**
e.g. "single vs double quotes are the same in JS; in C++ `'x'` is a *char* (a
number) and `"x"` is a string — never interchangeable." Don't over-explain general
programming; do go slow on hardware and on C++ features that differ from JS.

### ⭐ C++ scope: essentials only, reading level (Alex's explicit call)

The bar is **read the code, make small changes, describe problems precisely** —
NOT writing C++ from scratch; Claude writes the code. The complete essential
list is the "C++ ledger" in ROADMAP.md; everything outside it is parked.
In practice:
- Exercises = reading real code and making small modifications (change a
  constant, add an `if`, call a method) — not authoring from a blank file.
- If a parked C++ topic shows up in real code, teach the minimum as a runnable
  file in `cpp/`, add a deck card, and return to the hardware.
- Spend the saved depth on what Alex *does* want: wiring, measuring, and
  turning symptoms into precise problem reports (Serial logs, meter readings).

## Step 4 — Keep everything in sync

When a step completes (or the session ends):
- Update the **review deck** `/home/alex/Documents/notes/electronics/REVIEW.md`:
  move the warmed-up cards (correct → stage +1 and a new due session; wrong →
  stage 1), add a stage-1 card for every new concept taught today, move cards
  clean at stage 4 to Retired, and **add 1 to the session counter**.
- Update the **"▶ Resume here"** block in
  `/home/alex/code/embedded/esp32/Learning/notes/CONTEXT.md` (mark done, point to the next
  beat with a note on where Alex stopped).
- Update ✅/🔵/⬜ status in `/home/alex/code/embedded/esp32/Learning/ROADMAP.md` (and the
  Obsidian Electronics Roadmap if a theory topic was covered — a checkbox there
  means *introduced*; the deck is what tracks *remembered*).
- Update `/home/alex/code/embedded/esp32/Learning/INVENTORY.md` if Alex reports new/corrected parts.
After all file updates, commit and push both repos so the other laptop stays current:
```bash
git -C /home/alex/Documents/notes add electronics/ && git -C /home/alex/Documents/notes commit -m "Electronics: session $(date +%F) — deck update" && git -C /home/alex/Documents/notes push
git -C /home/alex/code/embedded/esp32/Learning add -A && git -C /home/alex/code/embedded/esp32/Learning commit -m "ESP32: session $(date +%F) — progress update" && git -C /home/alex/code/embedded/esp32/Learning push
```

The goal: next time he types `/electronics`, the resume status alone tells you
(and him) exactly where to restart.
