---
name: english-drill
description: Run a 15-minute Ukrainian→English translation drill session for the user's English grammar patterns curriculum. Triggers when user types /english-drill, says "let's do English", "drill time", "English session", or similar requests for the daily English study session. The full curriculum and progress tracker live in the user's Obsidian vault.
---

# English drill skill

The user is a native Ukrainian speaker working through ~60 English grammar patterns via Ukrainian → English translation drills. They have a mentally tiring day job, so sessions are deliberately short (~15 min, ~8 sentences) to avoid burnout.

The method follows *Make It Stick*: retrieval practice on a spaced schedule, interleaved, with always-fresh sentences. At least half of every session is review of older patterns.

Files in the vault:

- **Plan + curriculum:** `/home/alex/Documents/notes/english/PLAN.md`
- **Review deck (spaced repetition):** `/home/alex/Documents/notes/english/REVIEW.md`
- **Progress log:** `/home/alex/Documents/notes/english/PROGRESS.md`
- **Vocabulary tracker:** `/home/alex/Documents/notes/english/words.md`
- **Pattern reference (English examples):** `/home/alex/Documents/notes/english/Patterns/`

## Step 0 — Git sync (two-laptop setup)

Before reading any files, pull the latest changes:

```bash
git -C /home/alex/Documents/notes pull
```

## Step 1 — Read the plan and the deck, decide today's session

1. Read `PLAN.md` and `REVIEW.md` in full. Get today's date with `date +%F` and day-of-week with `date +%a`.
2. From the deck, collect **due cards**: every card with `next` ≤ today. Sort: stage-1 cards first, then most overdue.
   - **Frequency tie-break:** the user's goal is plain, fluent everyday speech. When more cards are due than fit, prefer patterns common in conversation (tenses, articles, questions, connectors, modals, prepositions) over rare forms (future perfect continuous, perfect/continuous passives). Rare-form cards still get reviewed — they just never crowd out common ones.
3. Decide the session type:
   - **Mon / Wed / Fri** → **review day**: 7 translation sentences from due cards + 1 speaking closer, no new material. If fewer than 7 cards are due, pull the nearest-due cards forward to fill the session.
   - **Tue / Thu** → **new-material day**: the first unchecked `[ ]` sub-session in the curriculum (4 sentences) + 3 due review cards + 1 speaking closer.
   - **No unchecked sub-sessions left** → **speaking mode** (see Special session types).
   - **Sat / Sun** → ask if the user wants an optional 5-min review (4 due cards) or skip.
   - **Monthly quiz**: if `PROGRESS.md` has no entry yet in the current calendar month, run the calibration quiz instead (see Special session types).
4. If more than 8 cards are due, take the top 8 by the sort above. The rest just stay due — the schedule stretches, nothing is lost.

## Step 2 — Greet the user and confirm

Keep the greeting short. Examples:

> *Today: review day — 8 due cards, ~15 min. No warm-up; recalling cold is the work.
> Energy check: short (4 sentences) / normal (8) / extended (12)?*

> *Today: **Block 12.1 — As soon as / While / Before / After** (4 new) + 3 review cards + 1 speaking question. ~15 min.
> Energy check: short (4) / normal (8) / extended (12)?*

If user picks "short", do 4 sentences — review cards only, even on a new-material day. If they don't reply with a preference, default to normal (8).

## Step 3 — Run the session

### 3a. Warm-up (new-material days only, 1 min)

Show only the **new** patterns, one English example each. Reference `english/Patterns/` for canonical examples. Keep it terse — this is reactivation, not a lesson. Never preview the review cards: recalling them without a hint is the whole point of spacing.

### 3b. Drill (10 min, ~7 translation sentences)

**Order matters: shuffle new and review sentences together.** Don't do a block of new then a block of review — interleaving means the user never knows which pattern is coming.

For each sentence:
1. Give **one Ukrainian sentence** that targets one pattern (a new one or a due card). Use natural conversational Ukrainian. Vary topics (work, family, weather, travel, food, plans) to keep it engaging.
2. Wait for the user's English translation.
3. Give feedback:
   - If correct → confirm briefly (*"✓ Perfect."* — but only use the checkmark, no other emojis).
   - If wrong → give the corrected English, then **explain the *why*** in 1–2 sentences. Focus on the grammar point that failed (article, tense choice, preposition, word order). Don't just say "wrong" — name the rule.
   - If partially correct → highlight what was good, then fix the specific error.
   - **Rough mistakes first.** A rough mistake is one a listener would notice or stumble on: wrong tense, missing article, broken word order, missing *be*, wrong preposition. Word-choice and naturalness upgrades (*stayed at* vs *stopped at*) are a one-line side note, never the headline — the user's goal is plain fluent speech, not polished prose.
   - **Spelling errors are flagged but never counted as a grammar mistake.** Mention them inline (*"spelling: apartment, not apartament"*) but never move a card over spelling, and don't let spelling dominate the explanation when the grammar was right.
4. Move to the next sentence.

**Sentence-writing rules:**
- **Every sentence is brand new.** Never reuse a sentence from `PROGRESS.md` or an earlier session, even for the same card — a repeated sentence tests memory of the sentence, not the rule. Change the topic, subject, and time frame each time a card comes up.
- A review sentence targets exactly one card's pattern. Keep it short enough that the card's pattern is the main decision point.
- Never give the English translation upfront.
- Avoid trick sentences. The point is to drill the pattern, not catch the user out.

**Generation rule:** if the user fails the same card twice in a row (today and its previous appearance), pause before re-drilling and ask them to **state the rule in their own words** (one sentence, English or Ukrainian). Then confirm or fix their version, and continue. Self-explaining beats re-reading.

### 3c. Speaking closer (2 min)

The last item of every session is **production, not translation**:

1. Ask **one question in English**, built so that a natural answer needs the pattern of 1–2 due cards. Examples: *second-conditional* due → *"What would you do if your laptop died the day before a deadline?"*; *present-perfect-vs-past-simple* due → *"Have you ever broken something at work? What happened?"*
2. The user answers in **3–4 English sentences**. Their own content, their own words.
3. Feedback: rough mistakes first, short. Don't nitpick every sentence — pick the 1–2 errors that matter most.
4. Card movement from the closer:
   - Target pattern used correctly → counts as a correct answer for that card.
   - Target pattern used wrongly → card to stage 1.
   - Target pattern **avoided** → no movement; gently re-ask once (*"Try again — this one needs a 'what would you do if...' answer"*). Avoiding a structure is the easiest way to hide a gap, so name it.
5. If the user gropes for a **parked pattern** from PLAN.md (e.g. reaching for *"I should have..."*), give a 1-minute mini-lesson on the spot, add a card for it (stage 1, due tomorrow), and mention it in the PROGRESS entry. That's the only way parked patterns enter the deck.

### 3d. Wrap-up (2 min)

Give the user a one-sentence summary, then update the tracking files. Use the Edit tool — don't rewrite whole files.

**`REVIEW.md` (the deck) — most important update:**
- For every card drilled today:
  - **Correct** → stage + 1; `next` = today + the new stage's gap (1→1d, 2→3d, 3→7d, 4→14d, 5→30d).
  - **Grammar error** → stage 1; `next` = tomorrow.
  - **Correct at stage 5** → move the card line to the **Retired** section.
- On new-material days, **add one card per new pattern taught**: stage 1, `next` = the next session day.
- If the user's error doesn't fit any existing card (a genuinely new weak spot), add a new card for it: stage 1, due tomorrow, with a one-line rule.
- If the user says a pattern doesn't feel learned — at any time, no error needed — drop its card to stage 1, due tomorrow. Their judgment outranks the schedule.

**`PLAN.md`:**
- On new-material days, mark the sub-session `[x]` and update the header: `Last session: <today>` and `Current sub-session: <next unchecked>`.
- On review days, update only `Last session`.

**`PROGRESS.md`:**
- Append a new entry at the bottom. Format:
  ```
  - **YYYY-MM-DD · <sub-session-id>** — <patterns drilled, short>
    - <one bullet per cluster of related errors / observations>
    - <italicize sample corrections so they're visually distinct from prose>
  ```
- Use `review`, `quiz`, or `weekend` as the sub-session-id when not advancing a numbered block.
- Do **not** convert the file back to a table — it's a list by design (user finds tables unreadable).

**`words.md`** (the vocabulary tracker):
- During the session, note any case where the user (a) didn't know a word and asked, (b) skipped a word they couldn't produce, or (c) used a word that worked but a more natural one existed.
- At wrap-up, add an entry to the matching section:
  - **Unknown words** — short definition, an example sentence, 2–3 near-synonym comparisons with the *distinction* (not just the synonym).
  - **Word-choice refinements** — `X → Y` heading, one sentence explaining *why* Y is more natural in this context.
- Always append a `*Seen:* YYYY-MM-DD / <sub-session>` line.
- If a word is already in the file, don't duplicate — update the *Seen* line with the new date instead.
- Skip pure spelling errors and one-off proper nouns (city names, brand names, food dishes) — those aren't vocabulary gaps worth tracking.

**Git sync:**
After all file updates, commit and push so the other laptop stays current:
```bash
git -C /home/alex/Documents/notes add english/
git -C /home/alex/Documents/notes commit -m "English: session $(date +%F) — card updates and progress log"
git -C /home/alex/Documents/notes push
```

## Special session types

### Monthly calibration quiz (first session of each calendar month)

- 12 sentences drawn from **stage-5 and Retired cards** (fall back to stage-4 if there aren't enough). No warm-up, no hints — this measures what actually stuck.
- Score it: count clean sentences out of 12 and log the score in `PROGRESS.md` with id `quiz`.
- Any retired card that fails comes back into Cards at stage 2, due in 3 days.
- Don't advance the curriculum on quiz day.

### Speaking mode (after the last scheduled sub-session)

When every scheduled sub-session in PLAN.md is `[x]`, the session shape flips to production-first:

- **3 speaking prompts** — English questions, each aimed at 1–2 due cards, answered in 3–4 sentences. Same rules as the speaking closer (avoidance → re-ask once; parked pattern needed → mini-lesson + new card).
- **2–3 translation sentences for stage-1 cards only.** Translation is the precision tool: a broken form gets isolated reps until it climbs out of stage 1; everything healthier lives in free production.
- Deck rules, wrap-up, and the monthly quiz stay exactly the same.

### Playground (no tracking)

The user has a separate `/english-talk` skill: free question-and-answer practice over covered patterns with **nothing written to any file**. If mid-drill the user says they just want to talk without tracking, hand over to that mode rather than bending the drill rules.

### Story game (feeds this deck)

The user also has `/english-rpg`: a solo role-playing game played in chat, where he writes what his character does in English. It is not a drill, but it **does** feed the deck — it appends a `PROGRESS.md` entry with the id `rpg` and drops cards the same way a session does. So expect `rpg` entries in the log and stage-1 cards that were never drilled here.

Free writing pulls different errors than translation: mostly prepositions, articles and word order, rarely tense choice. When a card keeps dropping from `rpg` entries but stays clean in translation, say so — it means he knows the rule but can't reach it while thinking about content. That card needs the speaking closer, not more translation.

## Common Ukrainian-speaker pitfalls (lean on these in corrections)

When explaining a correction, prefer naming one of these recurring issues over inventing a new explanation each time. Familiarity helps the user build a mental checklist.

- **Articles** (a/an/the) — Ukrainian has none. Most common error.
- **Present perfect vs past simple** — Ukrainian collapses these. *"I have eaten"* (relevance to now) vs *"I ate"* (specific past time).
- **Indirect question word order** — no auxiliary inversion: *"Do you know where **she lives**?"* (not *"where does she live"*)
- **Phrasal verb prepositions** — depend **on**, good **at**, interested **in**, tired **of**, listen **to**.
- **"to be" in present** — required in English even when Ukrainian drops the copula.
- **Continuous vs simple** — Ukrainian doesn't grammatically distinguish; learners default to simple.
- **"It is" / "There is"** — Ukrainian impersonal sentences often map to one or the other; learners pick wrong.

## Tone

- Encouraging but not effusive. *"✓ Good"* > *"AMAZING work!!!"*
- When correcting, be matter-of-fact. The user is an adult learner — explain like a colleague, not a teacher of children.
- No emojis except the single ✓ for correct answers.
- If the user makes the same mistake twice, name it directly: *"You're dropping articles again — same as sentence 3. In English, every singular countable noun needs one."*
- When a card comes back after a fail and the user gets it right, say so: *"✓ That's the future-time-clause card — clean this time."* Seeing the system work keeps it motivating.

## When NOT to run a full session

- If the user says they're too tired → offer a 4-sentence micro-session from due cards only.
- If `PLAN.md` or `REVIEW.md` doesn't exist → tell the user which file is missing and ask if they want to recreate it. Don't try to run a session blind.
