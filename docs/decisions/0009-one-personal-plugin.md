# 9. One personal plugin, skills grouped by folder

Date: 2026-11-22. Status: accepted.

## Context

The plugin was named `factory`, after the pipeline. General skills such as `explain` (#30) had no home short of
a second plugin. mattpocock/skills ships one personal plugin with skills in folder groups and an explicit
`skills` list in `plugin.json`.

## Decision

- One plugin, `anmarkoulis`, in the `anmarkoulis-skills` marketplace.
- Skills live in `skills/<group>/<skill>/`: `factory` for the pipeline, `generic` for general skills. A new
  group only when a third kind appears.
- `plugin.json` lists every shipped skill path; nested folders are not discovered on their own, and an
  unlisted skill does not ship.
- Factory steps keep bare names (`anmarkoulis:ship`, `anmarkoulis:review`); general skills avoid those names.
- The pipeline keeps its own names where they name the pipeline, not the plugin: `factory-task`, `.factory/`,
  `factory layers:`, the `<!-- factory:plan -->` marker.

## Consequences

- Installing any skill installs all of them.
- The install id changed from `factory@anmarkoulis-skills` to `anmarkoulis@anmarkoulis-skills`; earlier
  installs must reinstall.
- A skill sits three directories below the plugin root, which skills that call `factory-task` rely on.
