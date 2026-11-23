# Contributing

## Where things live

The repo root is the `anmarkoulis` plugin. `skills/factory/` holds the factory pipeline and `skills/generic/`
the general skills; both ship once listed in `.claude-plugin/plugin.json`. `.claude/skills/` holds skills for
working on this repo and does not ship. [contracts/README.md](contracts/README.md) is the single source of
truth for shared rules. The rules for editing a skill are in [AGENTS.md](AGENTS.md).

## Issues first

Open or pick an [issue](https://github.com/anmarkoulis/skills/issues) before a non-trivial PR. A settled
design decision gets an ADR in [docs/decisions/](docs/decisions).

## Branches and commits

- [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`,
  `refactor:`, `test:`, and `ci:` for `.github/workflows/`.
- Subject of 72 characters or fewer, in the imperative mood.
- The branch prefix matches the type (`feat/`, `fix/`, `docs/`, …), followed by a short slug.

## Pull requests

Every PR follows [the PR template](.github/PULL_REQUEST_TEMPLATE.md): its title rules (the title becomes the
squash commit that semantic-release reads), its sections, and its checklist.

## Checks to run locally

CI runs the same checks:

```
bash tests/factory-task.test.sh     # on bash 3.2 (macOS /bin/bash) and bash 5
bash tests/frontmatter.test.sh
bash tests/layers.test.sh
shellcheck contracts/factory-task tests/*.sh
claude plugin validate . --strict   # after touching .claude-plugin/
```

## Trying a skill

A skill is done only once it has been tried in a session started with `claude --plugin-dir .`.

## Releases

Releases are automatic ([#18](https://github.com/anmarkoulis/skills/issues/18)). Never edit `version` in
`.claude-plugin/plugin.json` by hand.
