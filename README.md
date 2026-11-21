# skills

Generic agent skills for Claude Code (OpenCode and Codex planned), published as a plugin marketplace.

> **Status: design phase.** No skills are implemented yet. Settled decisions are recorded as ADRs in
> [docs/decisions/](docs/decisions); the v0.1 spec and the work on each skill are tracked in
> [GitHub Issues](https://github.com/anmarkoulis/skills/issues).

## Plugins

| Plugin | What it is |
|---|---|
| [`factory`](plugins/factory) | A ticket-to-PR pipeline. A thin orchestrator chains step skills (intake, tier, understand, plan, build, review, verify, finalize, retro), scales its stops by a risk tier, keeps resumable state on disk, and lets a company and a project extend each step through declared override points. |

## Install

```
/plugin marketplace add anmarkoulis/skills
/plugin install factory@anmarkoulis-skills
```

## How it is meant to be used

The plugin is generic: nothing in it knows about your tracker, your test commands or your deploy rules.
You add those in layers you own:

```
factory (this repo)        generic steps, contracts, tier engine
  └─ company (optional)    what a company's repos share (acme-*)
       └─ project          one repo's specifics: test suites, agents (myproj-*)
```

A repo declares zero or more layers, lowest first, in its `AGENTS.md`. Each layer names its skills
`<prefix>-<step>` and says it extends the core step. See
[ADR 2](docs/decisions/0002-layers-and-prefixed-variants.md).

## Dependencies

None required. If [superpowers](https://github.com/obra/superpowers) or
[mattpocock/skills](https://github.com/mattpocock/skills) are installed, steps use them for more depth;
without them, each step follows its own built-in procedure.

## License

MIT
