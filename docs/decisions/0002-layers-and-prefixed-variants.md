# 2. Layers and prefixed variants, no shadowing

Date: 2026-11-21. Status: accepted.

## Context

The core must know nothing about a particular tracker, test suite, deploy process or codebase. Those specifics
belong to whoever owns the repo. Claude Code resolves same-name skills personal before project, and other
harnesses resolve them the other way round, so overriding a skill by reusing its name behaves differently per
tool.

## Decision

- A repo declares zero or more layers, lowest first, in its `AGENTS.md` (or `CLAUDE.md`):
  `factory layers: <prefix>, <prefix>`.
- The factory does not rely on the harness loading `AGENTS.md`. `ship`, and any step that needs the layers,
  reads the declaration itself: the first `factory layers:` line in `AGENTS.md`, then `CLAUDE.md`, at the repo
  root. It logs which file the line came from in `status.md`. No line means core only. A person's own layer is
  declared outside the repo ([ADR 11](0011-personal-layer.md)).
- A layer's skills are named `<prefix>-<step>` and say in their description which skill they extend.
- For step `<step>` the factory loads the core skill, then each declared layer's `<prefix>-<step>` in order, if
  it exists. A variant whose prefix the repo does not declare is never used. Each skill loads its own variants
  ([ADR 12](0012-layers-wherever-a-table-exists.md)).
- Same-name shadowing is never used.
- Typical setups: a personal project declares just its own project layer (core → project). A company repo may
  declare a company layer and then the project layer (core → company → project). The company layer is an
  example, not a requirement.
- A missing variant means the core default applies for that step. At the start of every run `ship` prints and
  logs a resolution table, one line per step with the skills it found, so a missing variant is visible.
- Adoption: while a project still has its own end-to-end skill, its project layer decides whether a request
  goes to that skill or to `anmarkoulis:ship`. Both work side by side until the old one is retired.

## Consequences

- Resolution is the same in every harness, because names never collide.
- Layers are explicit per repo; installing a plugin alone changes nothing.
- No layer is built in: the factory ships no personal or company layer.
