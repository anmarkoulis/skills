<!--
Title: `main` is squash-only, so the PR title is the commit semantic-release reads. Conventional Commits, 72
characters or fewer, imperative mood. `fix:` patch, `feat:` minor, `!` or a `BREAKING CHANGE:` footer major;
`docs:`, `chore:`, `ci:`, `test:`, `refactor:` no release. Use `ci:` for `.github/workflows/`.
-->

## Summary

<!-- What changed and why, in a few lines. When the change is prose, a short diff block of the rule changes. -->

## Ticket

<!-- `Closes #<id>`, or `Part of #<id>` when the issue stays open. -->

## Evidence

<!-- How it was verified, before and after: the commands and what they showed (verify levels and run numbers
when the factory ran it). -->

## Gaps

<!-- What is not proven and why (from gaps.md), or "none". -->

## Checklist

<!-- Tick each item, or strike it out with a reason: ~~item~~ not applicable: <reason>. -->

- [ ] `bash tests/factory-task.test.sh` on bash 3.2 (`/bin/bash`) and bash 5
- [ ] `bash tests/frontmatter.test.sh`
- [ ] `bash tests/layers.test.sh`
- [ ] `shellcheck contracts/factory-task tests/*.sh` (or the docker command in `AGENTS.md`)
- [ ] `claude plugin validate . --strict` (when `.claude-plugin/` changed)
- [ ] A changed skill was tried in a session started with `claude --plugin-dir <worktree or .>`
- [ ] A changed skill's eval cases pass, and a new skill has a trigger case (`claude plugin eval`, see `AGENTS.md`)
- [ ] A new skill is in `plugin.json`'s `skills` list; a general skill does not reuse a factory step's name
- [ ] A shared rule changed only in `contracts/README.md`
- [ ] Every changed core skill still ends with its Override points table
- [ ] A Claude Code-only feature is named, with its inline fallback (ADR 8)
- [ ] A settled design decision has an ADR in `docs/decisions/`
- [ ] `version` in `.claude-plugin/plugin.json` not edited by hand (semantic-release owns it)
- [ ] No company, product, tracker or private repo names in a generic skill
