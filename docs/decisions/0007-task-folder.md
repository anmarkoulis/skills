# 7. Task folder at `.factory/` with a self-ignoring `.gitignore`

Date: 2026-11-21. Status: accepted.

## Context

Steps need a place for per-task state that is out of `git status`, survives sessions, and that every skill finds
the same way. Claude Code denies agent writes under `.git/`, and editing a repo's tracked `.gitignore` for every
user is intrusive.

## Decision

- One folder per piece of work, default `.factory/<slug>/` in the working tree, following the pattern of
  superpowers' `sdd-workspace`.
- `.factory/` holds its own `.gitignore` containing `*`, so the folder ignores itself without touching any
  tracked file.
- One script resolves the location, so no two skills can disagree about it. The location is an override point
  of `intake`.
- If a worktree is created, the folder moves into it.
- Progress is logged in `status.md`, one line per event:
  `<step> done|stopped|changed|loop|skipped <YYYY-MM-DD> <file> [<reason>]`.

## Consequences

- No repo needs a `.gitignore` change to use the factory.
- Plans and other task files are never committed by accident.
