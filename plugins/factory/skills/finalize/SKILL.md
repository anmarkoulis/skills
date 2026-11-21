---
name: finalize
description: Use as the finalize step of factory:ship, after verify passes, to commit, push, open the PR, update the ticket, follow CI to green and apply the merge policy, each with the user's yes.
---

# finalize

Turns a verified working tree into a PR. Writes `pr-body.md` and records the PR url. Every commit, push, PR,
ticket write and merge needs the user's yes, every time. Contracts: [../../contracts/README.md](../../contracts/README.md).

## 1. Check before asking

- `verify.md`'s last run passed and no production line changed after it. Otherwise go back to verify.
- `git status --short` shows only the files `impl/status.md` lists; nothing from the task folder.

## 2. Commit and push

Ask first. Then, with the **git workflow** (default: plain git and `gh`):

- Stage the changed files by name, never `git add -A`. Follow the repo's commit conventions
  (`CONTRIBUTING.md`, `AGENTS.md`, recent history); the user's own instructions win.
- Push the branch from `decisions.md`. Never push to the default branch.

## 3. PR

Write `pr-body.md`: what changed and why, the ticket link (GitHub: `Closes #<id>` only if the user wants the
issue closed on merge, else `Part of #<id>`), how it was verified (levels and run numbers from `verify.md`),
and the open gaps from `gaps.md`. With a PR-body skill installed (for example `mattpocock-skills:pr`), use it
for the text. Show it, ask, then `gh pr create --body-file pr-body.md`. Record the url in `decisions.md`.

Compare the ticket with the final diff. If the scope changed, propose a ticket update through `factory:tracker`
and post only after a yes. Move the ticket to the **ticket state** for "in review" when a layer defines one.

## 4. CI

Watch the checks (`gh pr checks <n> --watch`). A failure caused by the change goes back to build as
`finalize loop <date> pr-body.md →build <failing check>` (then review and verify run again). A failure that is
not ours needs the same evidence rule as a pre-existing test failure: the same check failing on the base.

## 5. Merge and cleanup

The **merge policy** decides: default, a person merges, at every tier; at T2 a person always merges, whatever
the policy says. Run the **cleanup commands** (default: none; offer to delete the merged branch and worktree)
only after a yes.

## Done

Log `finalize stopped <date> pr-body.md awaiting answer` when the tier has a PR stop, otherwise
`finalize done <date> pr-body.md <PR url>`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| git workflow | plain git and `gh`, branch from `decisions.md` | `replace` |
| merge policy | a person merges (T2 always) | `set` (T0 and T1 only) |
| ticket states | none | `set` |
| cleanup commands | none; offer branch and worktree removal | `set` |
