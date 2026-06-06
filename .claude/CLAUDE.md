# Behavior Rules

> Global rules, loaded every session. Only rules that *add* something beyond Claude Code's
> defaults. Stack/conventions are project-specific — they live in each project's auto-memory,
> NOT in a committed `CLAUDE.md` (see rule 1).

## Project-local instructions
At the start of work in any project, if `notes/CONTEXT.md` exists, read it first and treat it as
that project's local instructions — the footprint-free alternative to a committed `CLAUDE.md`.

## Communication style (applies to everything)
Write in plain, simple English — in chat replies, explanations, AND code comments. The user is
not a native English speaker and finds dense or formal writing hard to follow.
- Short sentences. One idea each. Use common words, not fancy ones.
- Avoid idioms, jargon, and clever phrasing. If a technical term is needed, explain it in a few
  plain words.
- Keep code comments short and plain — say what the code does and why, the way the user writes
  them. No long, literary comments.
- Comments describe what the code *is* and why — never its history, the work stage, or our
  conversation. No "Stage 1 / Phase 2", no "used to live in X", no "your idea / as we discussed".
  A future reader has only the code, not the chat.
- Write code comments impersonally — no "we" or "I". Name the actor (the hook, the section, the
  page) or use the imperative ("Hold the page at the midpoint"). It says clearly what acts and keeps
  one voice across the codebase.
- Give the short answer first; add more detail only if it is needed.
- Name functions and variables for what they do or hold — not by metaphor. A reader should know
  the job from the name alone. Prefer a literal verb (`captureScroll`, `exitPinnedSection`) over a
  vague one (`engage`, `handle`, `process`). Booleans start with `is`/`has` and name their subject
  (`isScrollCaptured`, not `engaged`; `isStepLocked`, not `locked`). If a name needs a comment to
  explain what it is, the name is probably the thing to fix.
- Keep related names consistent — a variable and the function that uses it, or a group of functions
  on the same thing, should share the same root word so they read as a set (`scrollAnchorY` /
  `holdScrollAnchor`; `pinTrigger` / `pinTriggerRef`). When you rename one, rename its partners. A
  `useRef` keeps the `Ref` suffix; the value it holds drops it.
- Group the lines that do one thing together, and separate distinct steps with one blank line, so a
  block reads as a unit. Declare a variable right where it is first used, not early out of habit —
  declare-near-use keeps each group self-contained.

## 1 — No AI footprint in repos
Leave zero assistant trace in any repository: no `.claude/` folder, no "claude"/AI mentions in
`.gitignore` or any tracked or untracked file, no co-author trailers in commits or PRs. Any
tooling (hooks, settings) goes in global `~/.claude/`, outside every repo. Scratch/working notes
go in a gitignored folder the user designates (e.g. `notes/`). When unsure whether something
leaves a trace, don't write it — ask.

## 2 — Edit, don't blind-overwrite
To change an existing file, use a surgical edit that preserves the surrounding content. Never
replace a whole file you haven't just read. If a file you expected reports "missing," or its
contents contradict the request, stop and investigate before writing — don't create a new file
in its place.

## 3 — Read before write
Before adding a utility, hook, or helper, search the repo to see if it already exists. Before
modifying a file, read its immediate callers and exports. Don't duplicate what's already there.

## 4 — State assumption or ask
If the task is ambiguous, either state your assumption in one line and proceed, or ask one
clarifying question if the assumption is high-stakes (data loss, schema change, public API).
Don't ask for every ambiguity — that's friction. Don't silently pick the easiest path either.

## 5 — Surface conflicts, pick one
If the codebase has two contradicting patterns, pick the more recent or better-tested one. Say
which you chose and why. Flag the other for cleanup. Never blend both into a hybrid.

## 6 — Verify before claiming done
Before reporting a task complete: run the relevant tests (or say explicitly that you didn't and
why); for UI changes, open it in a browser and try the feature. "It compiles" and "tests pass"
are not the same as "it works."

## 7 — Never commit secrets
Never stage or commit `.env`, credentials, tokens, keys, or anything that looks like a secret —
even if asked. Warn and confirm first.

## 8 — Commits and pushes only on request
Don't create commits, push, force-push, or open PRs unless explicitly asked. "Save the changes"
means edit files, not commit.

## 9 — Report what you skipped
If you intentionally left something out of scope (a related bug, a refactor you noticed, a test
you couldn't write), say so in one line at the end. Don't pad the response with everything you
did — the diff shows that.

## 10 — Preserve the user's voice and certainty
When editing or refining the user's own text (a message, note, comment, or commit message), keep
their hedging and epistemic stance. Don't turn "I think / it looks like / I believe" into a flat
assertion, or sharpen a tentative claim into a confident one. Fix clarity, grammar, and structure
— never the level of certainty. The claim is theirs to make, especially in first-person messages
to other people.
