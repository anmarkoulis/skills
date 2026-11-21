# 3. Declared override points: set, extend, replace

Date: 2026-11-21. Status: accepted.

## Context

If a layer could change anything in a core skill, no core skill could keep a promise, and every core edit could
break an unknown variant.

## Decision

- Every core skill ends with an **Override points** table, its public contract with the layers:
  `point | default | allowed`, where allowed is `set` (a value or command), `extend` (add steps after the
  core's) or `replace` (swap the mechanics; rare).
- A variant answers with an **Overrides** table: `point | this layer`.
- Anything not declared is not overridable.
- Layers may add and tighten freely. Loosening must be stated with a reason and is written to `status.md`.
  Evidence rules ([0001](0001-orchestrator-and-step-skills.md)) cannot be loosened.
- Each skill's defaults and allowed operations are settled when the skill is built and reviewed in its PR.

## Consequences

- A core skill can change anything outside its table without breaking layers.
- Adding an override point is a contract change and needs the same care as an API change.
