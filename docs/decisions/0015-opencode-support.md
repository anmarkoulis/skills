# 15. OpenCode support

Date: 2026-11-24. Status: accepted. Amends [ADR 8](0008-claude-code-first.md).

## Context

[ADR 8](0008-claude-code-first.md) kept the skills on Claude Code until the contracts had shipped real tickets,
and made every Claude Code-only feature a named one with an inline fallback. The contracts have since shipped
eleven tickets. OpenCode 1.19.3 reads `SKILL.md` folders from configured paths, finds nested ones, reads
`.claude/skills/` and `~/.claude/skills/`, and has a `skill`, a `question` and a `task` tool. Its `skill` tool
prints the skill's base directory the way Claude Code does.

## Decision

- OpenCode is supported from the same source tree: a clone of this repo plus `skills.paths` pointing at its
  `skills/` folder in `opencode.json`. No fork, no second copy of any skill.
- No OpenCode plugin package (a root `package.json` and a JS config hook, as superpowers ships). A clone and one
  config line do the same job without code to maintain; it can be added later if a no-clone install is wanted.
- Each harness gets one note in `docs/harnesses/` mapping the Claude Code features the skills name to that
  harness's equivalent or to the inline fallback. The skills keep naming Claude Code features as ADR 8 says.
- Codex stays deferred.

## Consequences

- Install and triggering are checked on OpenCode 1.19.3 (`opencode debug skill`, a headless `opencode run`). A full
  `ship` run inside OpenCode is not yet proven.
- The plugin agents in `agents/` do not load in OpenCode; `delegate` falls back to a generic worker or inline.
- A same-named skill elsewhere in OpenCode's paths can shadow one of ours without a warning.
