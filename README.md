# skills

Generic agent skills for Claude Code (OpenCode and Codex planned), packaged as one plugin with its own marketplace.

> **Status: v0.1 done.** All v0.1 skills of the factory are written and have run real tickets.

## factory

This repo is the `anmarkoulis` plugin. Its skills are grouped by folder under `skills/`; the first group,
`skills/factory/`, is the factory: a ticket-to-PR pipeline. A thin orchestrator chains step skills (intake,
tier, understand, plan, build, review, verify, finalize, retro), scales its stops by a risk tier, keeps
resumable state on disk, and lets a company and a project extend each step through declared override points.
Shared rules: [contracts/](contracts).

v0.1: all the skills below are written.

| Skill | Role |
|---|---|
| `ship` | Orchestrator: order, stops per tier, `status.md`, resume, loops |
| `tier` | Risk tier T0/T1/T2 after intake; re-tier after understand |
| `intake` | Which ticket, prior work, mismatch flags, workspace, scope questions |
| `understand` | Routes by type: bug → `debugging`, feature or improvement → `spec` |
| `debugging` | Root cause: one diagnosis, or two blind ones reconciled at T2 |
| `spec` | Grill, question ledger, write, approve, post |
| `plan` | Writes `plan.md` in the task folder and posts it through `tracker` |
| `build` | Execution method, fixed implementer brief, lead re-verification |
| `review` | Code review at the tier's depth, fixes, re-verify |
| `verify` | Regression map, levels L1–L4, numbered runs, gaps |
| `qa-tests` | L2: the repo's acceptance or e2e suite |
| `manual-test` | L3: drive the running app, one script per flow |
| `finalize` | Commit, push, PR, ticket update, CI loop, merge policy, cleanup |
| `retro` | Lessons, proposed skill edits, agents and checks; applies only what you approve |
| `tracker` | Tracker interface; default implementation is GitHub Issues |
| `delegate` | Worker levels: specialist agent, generic worker, inline |
| `setup` | Declares a repo's layers and scaffolds variant skills |

Agents (optional helpers in [agents/](agents), picked by `delegate`): `task-reviewer`, `bug-diagnoser`,
`qa-runner`, `manual-tester`. Without them, steps run the same brief on a generic worker or inline.

## General skills

Usable on their own, outside the factory (`skills/generic/`).

| Skill | Role |
|---|---|
| `explain` | Every explanation is a worked example traced through the real lines |
| `code-schematic` | One code path at one git ref: a Mermaid flow plus layered pseudo-code |
| `deep-review` | Intent, walkthrough and findings for a PR or diff, using installed review skills as lenses; writes local files, never posts |

## Install

From a Claude Code session:

```
/plugin marketplace add anmarkoulis/skills
/plugin install anmarkoulis@anmarkoulis-skills
```

Or from a shell:

```
claude plugin marketplace add anmarkoulis/skills
claude plugin install anmarkoulis@anmarkoulis-skills
```

Restart Claude Code, then run `/plugin` to check that `anmarkoulis` is installed and enabled. Skills are
invoked as `/anmarkoulis:<skill>`, for example `/anmarkoulis:ship #42`, and also trigger from their
descriptions.

To update, refresh the marketplace and update the plugin, then restart:

```
claude plugin marketplace update anmarkoulis-skills
claude plugin update anmarkoulis@anmarkoulis-skills
```

To try a local checkout without installing, start Claude Code with `claude --plugin-dir /path/to/skills`.

Installed the earlier `factory@anmarkoulis-skills`? Uninstall it and install `anmarkoulis@anmarkoulis-skills`;
the old id no longer receives updates.

## How it is meant to be used

The plugin is generic: nothing in it knows about your tracker, your test commands or your deploy rules.
You add those in layers you own:

```
factory (skills/factory/)  generic steps, contracts, tier engine
  └─ company (optional)    what a company's repos share (acme-*)
       └─ project          one repo's specifics: test suites, agents (myproj-*)
```

A repo declares zero or more layers, lowest first, in its `AGENTS.md`. Each layer names its skills
`<prefix>-<step>` and says it extends the core step. See
[ADR 2](docs/decisions/0002-layers-and-prefixed-variants.md). `/anmarkoulis:setup` writes the line and
scaffolds the variants. The rules are in [contracts/README.md](contracts/README.md#layers); in short:

- **Personal layer.** `factory personal layers: me` adds your own layer without touching the repo: in
  `~/.claude/CLAUDE.md` as defaults for every repo, below the repo's layers; in `CLAUDE.local.md` for this repo
  only, above them. Order: core < user < repo < local
  ([ADR 14](docs/decisions/0014-user-and-local-layers.md)).
- **Where variants live.** Any skill folder the session loads: the repo's `.claude/skills/`, your
  `~/.claude/skills/`, or a plugin. A company layer can live once at user level.
- **What a variant holds.** An Overrides table answering the core step's Override points, and sections below it
  that a cell points to. A `replace` always needs such a section. Its description ends with
  "Not for direct use; the core skill applies it." so it does not trigger on its own.
- **Several layers.** `set` and `replace`: the highest layer wins. `extend`: every layer's additions run, lowest
  first.
- **Every skill with override points applies its own layers**, in `ship`, when another skill calls it, and run
  on its own ([ADR 12](docs/decisions/0012-layers-wherever-a-table-exists.md)): an `acme-tracker` that replaces
  the mechanics with another tracker is what intake, plan, finalize and a standalone `deep-review` use.

### Moving from your own end-to-end skill

1. Run `/anmarkoulis:setup`: declare the layers and scaffold one variant per step you change, every row at
   `default`.
2. Go through the old skill one rule at a time. A rule that answers an Override point becomes that row (`set` a
   value, `extend` an addition, `replace` with a section below the table). Put team facts in the repo or company
   layer and your own habits in the personal layer.
3. A rule that fits no point is either already a core default (drop it), belongs in `AGENTS.md` or `CLAUDE.md`,
   or is a missing point: open an issue here rather than forking the step.
4. Run one small ticket with `/anmarkoulis:ship` and check the resolution table lists every variant you wrote.
5. Retire the old skill once a run went through. Until then the two work side by side (ADR 2, adoption).

## Dependencies

None required. If [superpowers](https://github.com/obra/superpowers) or
[mattpocock/skills](https://github.com/mattpocock/skills) are installed, steps use them for more depth;
without them, each step follows its own built-in procedure.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Contributors are listed in [CONTRIBUTORS.md](CONTRIBUTORS.md).

## License

MIT
