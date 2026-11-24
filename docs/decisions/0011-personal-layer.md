# 11. A personal layer declared outside the repo

Date: 2026-11-23. Status: accepted; the ordering is superseded by [ADR 14](0014-user-and-local-layers.md).

## Context

Layers were read only from the repo's `AGENTS.md` or `CLAUDE.md` ([ADR 2](0002-layers-and-prefixed-variants.md)),
both checked in. A person who wants their own rules on top of the team's (ask before a PR, where retros go,
which model runs a role) had to either change a shared file or put personal rules in a team layer.

## Decision

- Besides the repo's `factory layers:` line, `ship` reads the first `factory personal layers: <prefix>` line from
  `CLAUDE.local.md` at the repo root, else from `~/.claude/CLAUDE.md`. `CLAUDE.local.md` scopes it to one repo;
  `~/.claude/CLAUDE.md` to every repo of that user.
- Personal layers always come after the repo's, so they are the highest: their `set` wins, their `extend` runs
  last. A prefix the repo already declares is not added twice.
- The `layers:` line in `status.md` names the source of each part:
  `layers: acme, shop, me (from AGENTS.md; me from ~/.claude/CLAUDE.md)`.
- A personal layer follows the same rules as any other: it may add and tighten, and loosening is logged with a
  reason.

## Consequences

- A personal layer changes nothing for teammates and needs no repo change.
- Two people running the same task folder can get different runs. The `layers:` and `resolution:` lines in
  `status.md` show which layers each run used.
- Every skill with override points reads these lines when run on its own too
  ([ADR 12](0012-layers-wherever-a-table-exists.md)).
- `~/.claude/CLAUDE.md` is a Claude Code path. Another harness has no user-level source until one is added;
  the repo's `CLAUDE.local.md` still works.
