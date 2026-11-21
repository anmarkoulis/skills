# skills

Generic agent skills for Claude Code (and OpenCode), published as a plugin marketplace.

> **Status: design phase.** No skills are implemented yet. The design lives in
> [docs/design.md](docs/design.md); open questions are listed at its end.

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
factory (this repo)                 generic steps, contracts, tier engine
  ├─ your personal plugin (me-*)    what your own projects share (tracker, merge policy)
  │    └─ project variants          one repo's specifics (test suites, agents)
  └─ your company plugin (acme-*)   what your company's repos share
       └─ project variants
```

Each layer names its skills `<prefix>-<step>` and says it extends the core step. A repo declares its layers in
its `AGENTS.md`. See [docs/design.md](docs/design.md).

## Dependencies

None required. If [superpowers](https://github.com/obra/superpowers) or
[mattpocock/skills](https://github.com/mattpocock/skills) are installed, steps use them for more depth;
without them, each step follows its own built-in procedure.

## License

MIT
