---
name: retro
description: Use as the last step of anmarkoulis:ship, also when the work stopped early, or when asked for a retro or post-mortem on a task folder, to record lessons and propose skill edits, agents and checks. Applies only what the user approves.
---

# retro

Turns a task folder into `retro.md` and `skill-fixes.md`, and into edits only with approval. It never edits a
skill, agent or check on its own. Contracts: [../../../contracts/README.md](../../../contracts/README.md).

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

Depth by tier: T0 only when something caused friction (otherwise log `retro skipped <date> - T0, no friction`);
T1 short; T2 full, with checks proposed.

## 1. Read the folder

The folder is the source, not chat: chat may be compacted or gone. A fact only in chat goes into `retro.md`
marked unverified. Also read the repo's own checks once (lint, type and test scripts, pre-commit config, CI
workflows), so a check that exists but is unwired or broken is the finding, not a new check.

## 2. Write `retro.md`

About one page, fixed sections in this order; every line actionable or reusable:

- `# Retro: <ticket> (<start date> to <end date>)`
- `## What worked`: specific enough to repeat (the technique, the command, the numbers).
- `## What didn't`: each item with its cost (rework, wrong turn, near miss), including agent claims that turned
  out wrong and what caught them.
- `## Friction`: each entry starts with one type: `navigation`, `check` (an automated check could have caught
  it), `standard` (a review rule is missing or wrong; name the reviewer's file it belongs in, such as
  `REVIEW.md`), `steering` (an instruction file line is wrong or a no-op), `tool-cost`, `information` (a needed
  fact was not reachable), `skill` (a skill was wrong or stale).
  Name the skill or tool, what it said and what actually worked.
- `## Promote`: what should become a skill edit, an agent or a check, each `proposed`, `applied <date>` or
  `declined`.

## 3. Write `skill-fixes.md`

Three tables; write "none" under an empty one:

- **Skill edits:** `# | file (absolute path) | exact edit (old → new, or line to add and where) | why (incident,
  with the task-folder file that shows it)`. Only skills that were wrong. Check the file first; drop rows already
  fixed.
- **Proposed agents:** `# | name | tools | model | brief`, only where a specialist could have done part of the
  work and none exists.
- **Checks:** `# | kind (lint rule, pre-commit hook, settings hook, CI job, test) | where | what it fails on |
  why`. A mechanical mistake (a fixed pattern, a banned call, a wrong directory) gets a check, not a written
  rule. A settings hook is a Claude Code hook in `.claude/settings.json`; in another harness, use a pre-commit
  hook or a CI job instead.

## 4. Ask once, apply only what is chosen

First print every row in full: id, the file by its absolute path, the exact edit and why. Then one
multi-select question whose options each carry the row's id and its edit in short, nothing pre-selected,
and a last option **Apply nothing** ([stop contract](../../../contracts/README.md#stops)). Rows that do not fit
beside it (the question tool takes at most 4 options) go in further questions of the same shape. No rows: skip it. Then, for the selected rows only:

- Back up each file to `<task folder>/backup/<path>` before editing. Edit skills with
  `superpowers:writing-skills` when installed, else directly.
- Create agents and checks exactly as the row says. Run each new check once to show it fails on the incident
  and passes on the fixed state.
- Approved rules land in the **rule destination** (default: the file the row names, inside this repo).
- Mark each row `applied <date>` or `declined`, and update `Promote`. Unselected rows stay `proposed`; never
  apply them later without asking again.

Do not commit, push or change anything outside the task folder and the approved files.

## Done

Log `retro done <date> retro.md`, or `retro stopped <date> skill-fixes.md awaiting approval` when the user
stopped before answering.

## Override points

| Point | Default | Allowed |
|---|---|---|
| rule destination | the file each row names, inside the repo | `set` |
| friction types | the seven above | `extend` |
