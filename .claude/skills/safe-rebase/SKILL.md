---
name: safe-rebase
description: Safely rebase the current feature branch onto another branch (typically develop or main) without losing files. Handles conflict resolution, verifies feature-only files survive, and creates a backup. Triggers when user says "rebase onto develop", "merge develop via rebase", "rebase my branch", or similar.
---

# Safe rebase skill

The user wants to rebase their current feature branch onto another branch (usually `develop` or `main`) without losing any files that exist only in the feature branch.

## Key risk to understand

During a rebase, files that exist only in the feature branch can be **silently deleted** if a conflict is auto-resolved in favor of the target branch. The skill must guard against this.

## Terminology warning — "ours" and "theirs" are flipped in rebase

| Label | Points to |
|-------|-----------|
| `ours` | the branch being rebased **onto** (e.g. `develop`) |
| `theirs` | the feature branch commits being replayed |

This is the **opposite** of a merge. Always keep this in mind when resolving conflicts.

## Step 1 — Assess the situation

Run these in parallel:

```bash
git status
git log --oneline <target>..HEAD | head -20        # commits on feature not in target
git log --oneline HEAD..<target> | head -20        # commits on target not in feature
git diff --name-status <target>...HEAD | grep "^A" # files added only in feature branch
```

Check that:
- Working tree is clean (`git status`). If not, stash or commit first.
- Local target branch is up to date with its remote (`git log --oneline origin/<target>..<target>`)

Report findings to the user before proceeding:
- How many commits will be replayed
- Which files exist only in the feature branch (these are at risk)

## Step 2 — Create a backup branch

Always create a backup before touching anything:

```bash
git branch backup/<current-branch>-before-rebase-<YYYYMMDD>
```

Use today's date. Tell the user the backup name.

## Step 3 — Run the rebase

```bash
git rebase <target>
```

If it exits with an error, a conflict was hit. Go to Step 4.
If it completes cleanly, go to Step 5.

## Step 4 — Resolve conflicts

For each conflict:

1. Read the conflicted file and understand what each side changed.
2. **Never discard either side blindly.** The goal is to keep both sets of changes.
3. Edit the file to merge both sides correctly — remove all `<<<<<<<`, `=======`, `>>>>>>>` markers.
4. Stage the file: `git add <file>`
5. Continue: `git rebase --continue`

Repeat until the rebase completes.

If a conflict involves `src/index.ts` or any barrel export file: both sides almost certainly added new exports — keep all of them.

If you are ever unsure which version to keep, show the user the conflict and ask.

## Step 5 — Verify feature-only files survived

After the rebase completes, check every file that was identified in Step 1 as feature-only:

```bash
for f in <file1> <file2> ...; do
  [ -f "$f" ] && echo "OK  $f" || echo "MISSING  $f"
done
```

If any file is **MISSING**:
1. Restore it from the backup branch: `git checkout backup/<name> -- <file>`
2. Commit the restored file: `git add <file> && git commit -m "restore <file> lost during rebase"`
3. Tell the user exactly what happened and what was restored.

## Step 6 — Final check

```bash
git log --oneline -<N+3>   # N = number of feature commits
```

Confirm all feature commits are present on top of the target branch commits.

Report to the user:
- Rebase succeeded / what conflicts were resolved
- All feature-only files are present
- Backup branch name (remind them they can delete it with `git branch -d <backup>`)
- How to force-push if needed: `git push --force-with-lease origin <branch>`

## What NOT to do

- Never run `git rebase -X ours` — during rebase "ours" = the target branch, so this silently drops all feature branch changes.
- Never skip a commit (`git rebase --skip`) without showing the user what would be lost.
- Never abort (`git rebase --abort`) without telling the user first.
- Never leave conflict markers in committed files.
