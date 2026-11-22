---
name: setup
description: Use once per repo, before the first anmarkoulis:ship run or when its layers change ("set up the factory here", "add a layer", "scaffold variant skills"), to declare the repo's layers in AGENTS.md, scaffold the <prefix>-<step> variant skills with every override point and its default, pre-fill detected test and lint commands, and report which accelerators are installed.
---

# setup

Declares a repo's layers and scaffolds their variant skills. Writes the `factory layers:` line and
`.claude/skills/<prefix>-<step>/SKILL.md` files (Claude Code's project skill folder; another harness: its own); nothing else, and nothing without a yes. Layers, variants and
the Overrides table: [../../../contracts/README.md](../../../contracts/README.md). The core skills are this skill's
siblings, one directory up.

## 1. Layers

Ask for the layers, lowest first (for example a company prefix, then the project's). Show the
`factory layers: <list>` line as a diff against the repo root's `AGENTS.md` (an existing line is updated in
place; no `AGENTS.md`: create it with just that line, unless `CLAUDE.md` already holds the line), and write it
after a yes.

## 2. Variants

For each layer, ask which steps it varies. For each chosen step:

1. Read the core skill's **Override points** table.
2. Show, then after a yes write, `.claude/skills/<prefix>-<step>/SKILL.md` (a shared company layer may live in
   its own repo instead; ask where):

   ```markdown
   ---
   name: <prefix>-<step>
   description: Extends anmarkoulis:<step> for <repo or company> with <what this layer changes>.
   ---
   | Point | This layer |
   |---|---|
   | <every point from the core table> | default |
   ```

3. A core skill whose table says none gets no variant; say so.

**Never overwrite an existing variant.** When one exists, show which points it lacks and offer to add those rows.

## 3. Detect commands

Look for the test, lint and build commands in the README, `AGENTS.md`, `Makefile`, package scripts and CI
workflows. Pre-fill the matching rows of the `build` variant (**test command**, **lint command**) and the
`verify` variant (**L1 commands**) with `set: <command>`, citing where each came from. Nothing found: leave
`default` and say so.

## 4. Accelerators

List the available skills and report which soft dependencies are present and what each adds. The core skills
name each one where they use it (`grep -rn "superpowers:\|mattpocock-skills:" <core skills>`). One thing the grep does not show: two blind
diagnoses at T2 in `debugging` need both.

Each step works without them ([ADR 6](../../../docs/decisions/0006-soft-dependencies.md)). Name the missing ones
and what the run loses; never install anything.

## Done

Print what was written (paths), what was left at `default`, and the accelerators found.

## Override points

None. `setup` writes the layers that configure every other step, so a layer configuring its own setup would be
circular.

| Point | Default | Allowed |
|---|---|---|
| none | — | — |
