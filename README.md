# skills

Generic agent skills for Claude Code (OpenCode and Codex planned), packaged as one plugin with its own marketplace.

> **Status: v0.1 in progress.** All v0.1 skills of the factory are written and not yet
> tried on real tickets. Settled decisions are recorded as ADRs in
> [docs/decisions/](docs/decisions); the v0.1 spec and the work on each skill are tracked in
> [GitHub Issues](https://github.com/anmarkoulis/skills/issues).

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

## Install

```
/plugin marketplace add anmarkoulis/skills
/plugin install anmarkoulis@anmarkoulis-skills
```

Skills are invoked as `/anmarkoulis:<skill>`, for example `/anmarkoulis:ship #42`. Installed the earlier
`factory@anmarkoulis-skills`? Uninstall it and install `anmarkoulis@anmarkoulis-skills`; the old id no longer
receives updates.

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
[ADR 2](docs/decisions/0002-layers-and-prefixed-variants.md).

## Dependencies

None required. If [superpowers](https://github.com/obra/superpowers) or
[mattpocock/skills](https://github.com/mattpocock/skills) are installed, steps use them for more depth;
without them, each step follows its own built-in procedure.

## License

MIT
