# Working on this repo

The repo root is the `anmarkoulis` plugin root: `.claude-plugin/` holds both `plugin.json` and the one-plugin
`marketplace.json`. Skills are grouped by folder: the factory pipeline in `skills/factory/<skill>/`, general
skills in `skills/generic/<skill>/` ([ADR 9](docs/decisions/0009-one-personal-plugin.md)). A skill ships only
once its path is in the `skills` list in `plugin.json`. General skills do not reuse a factory step's name.
Plugin agents go in `agents/` at the root. Skills for working on this repo itself go in `.claude/skills/`, which does not ship.

## Editing a skill

- [contracts/README.md](contracts/README.md) is the single source of truth for the task folder, `status.md`,
  stops, verdicts, layers and override points. Change a shared rule there, and only there.
- A step's procedure lives in that step's skill. `ship` holds order, stops, loops and `status.md`, nothing else.
- Every core skill ends with its **Override points** table, with settled defaults
  ([ADR 3](docs/decisions/0003-override-points.md)).
- Optional libraries (superpowers, mattpocock-skills) are accelerators: each step works without them
  ([ADR 6](docs/decisions/0006-soft-dependencies.md)).
- Name any Claude Code-only feature a skill uses, with its inline fallback
  ([ADR 8](docs/decisions/0008-claude-code-first.md)).
- A settled design decision gets an ADR in `docs/decisions/`; open work is a GitHub issue linked from the
  spec, #1.

## Checking a change

- Scripts run on bash 3.2 (macOS `/bin/bash`) as well as bash 5: `bash tests/factory-task.test.sh`, and
  `shellcheck` on `contracts/factory-task` and `tests/*.sh`. CI runs both.
- `claude plugin validate .` after touching `.claude-plugin/`.
- A skill is done only once it has been tried in a session started with `claude --plugin-dir .`.
