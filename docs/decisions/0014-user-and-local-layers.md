# 14. User layers below the repo's, local layers above

Date: 2026-11-24. Status: accepted. Supersedes the ordering in [ADR 11](0011-personal-layer.md).

## Context

[ADR 11](0011-personal-layer.md) put every personal layer above the repo's, read from `CLAUDE.local.md`, else
`~/.claude/CLAUDE.md`. A layer in `~/.claude/CLAUDE.md` applies to every repo, and in practice it holds a person's
defaults (tracker, branch names, merge policy, models), not overrides of a team. Above the repo, those defaults beat
every repo's choices: a user layer with Linear mechanics forced Linear branch names and tracker calls onto this
repo's GitHub issues (#76), and a repo had no way to say "not here". An `extend` could not be switched off at all.

## Decision

- The file a `factory personal layers:` line comes from decides its level. `~/.claude/CLAUDE.md` is the **user**
  level, below the repo's layers; `CLAUDE.local.md` at the repo root is the **local** level, above them. Both apply.
- Order, lowest first: core < user < repo < local, as git config orders system < global < local. A prefix already
  declared at a lower level is not added again.
- A higher layer may answer an `extend` point with `set: none`, dropping every lower layer's additions for that
  point.
- `ship` logs each prefix with its level: `layers: am (user) < sk (repo) (from ~/.claude/CLAUDE.md; AGENTS.md)`.
- Rejected: a second keyword (`factory user layers:`) for the lower slot, since the file already says which it
  is; declaring the user prefix in the repo's `factory layers:` line to push it down, which relies on the "not
  added twice" rule and puts a personal prefix in a shared file; only making a user layer's rows conditional,
  which leaves repos without an off switch.

## Consequences

- A repo beats a user's defaults by answering the point itself; a `default` row still lets the user's value stand.
  This repo states its branch name in `sk-intake` and its GitHub mechanics in `sk-tracker` for that reason.
- Overriding a team's rules for yourself now needs `CLAUDE.local.md` in that repo; a user-level layer can no longer
  do it for every repo at once.
- A prefix in both `~/.claude/CLAUDE.md` and `CLAUDE.local.md` stays at the user level, below the repo. To put it
  above the repo, declare it only in `CLAUDE.local.md`.
- Two people running the same task folder can still get different runs; the `layers:` line shows each level.
- `~/.claude/CLAUDE.md` is a Claude Code path. Another harness has no user level until one is added; the local
  level still works.
