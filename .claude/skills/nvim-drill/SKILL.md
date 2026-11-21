---
name: nvim-drill
description: Run a short practice session for nvim (LazyVim) keys and commands. Claude gives one task at a time, Alex does it in his own nvim, Claude checks the result. Triggers when Alex types /nvim-drill, says "nvim drill", "nvim practice", "vim practice", or wants to continue the nvim drill.
---

# nvim drill

Alex practices nvim (LazyVim) keys. He does every task himself, in his own nvim.
Claude gives tasks and checks the result.

Files:
- Progress: `/home/alex/Documents/notes/tech/nvim/drill.md`. Two lists: "I know" and "To learn (most useful first)".
- Practice folder: `~/nvim-practice`. All tasks happen there. Never use the notes repo.
- nvim config: `~/dotfiles/nvim`. Read it when you are not sure what a key does.

## Start

1. Read `drill.md`.
2. Look at `~/nvim-practice` with `find ~/nvim-practice | sort`.
3. If the folder is missing, create it yourself: a small TypeScript project with a `tsconfig.json`
   and 3–4 `.ts` files that import each other. Then `gd`, `gr` and `<leader>cr` have something to work on.
4. Give the first task. No long intro.

## Tasks

- One task at a time. 2–4 small steps per task.
- A session is about 6 tasks.
- Take new keys from the top of "To learn".
- Mix in keys from "I know" too. About half of each task is review.
- Use the files in the practice folder. Build on what he did before.

### No hints

This is the most important rule. The task says WHAT to do, never HOW.
- Never name the key or the command in the task.
  Bad: "Press `gd` on `formatDate`."
  Good: "Jump to the place where `formatDate` is written."
- Never tell him which keys come next. Don't list "To learn" items in chat.
- Give a hint only when he asks for one.

## Checking

- Edits: check the file with `cat` or `git diff` after he saves.
- Moves and searches leave no trace in files. Ask what he sees: the file name, the line, or the text.
- Never do the task for him. Never change files in the practice folder after the setup.
- Correct: "✓", plus one short line if needed.
- Wrong: say what happened, give the right key, and one line why.
- He doesn't know it: give the key. He tries it. Then go on.

## Wrap-up

When the session ends (about 6 tasks, or he says stop), edit `drill.md`:
- Did a "To learn" key right with no hint → move it to "I know".
- Got it wrong or needed help → keep it in "To learn".
- He says he uses a key often → move it to "I know".
- New key came up that is not on the list → add it to "To learn" at the right place.

Then tell him in one or two lines what moved. Don't commit. He commits himself.

## Style

- Plain, short English. Alex is not a native speaker.
- No emojis except ✓.
- If he wants to stop, stop. Do the wrap-up.
