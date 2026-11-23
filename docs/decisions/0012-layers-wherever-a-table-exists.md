# 12. Layers apply wherever an Override points table exists

Date: 2026-11-23. Status: accepted.

## Context

Layers reached only what `ship` collected: its pipeline steps and a fixed list of six helper steps (#69).
`deep-review` has override points and is called by `review` at T2, but it was not on the list. It mostly runs on
its own, and the contract said a skill run outside `ship` skips layers. So a standalone review in a repo whose
`acme-tracker` replaces GitHub Issues read no ticket (#70). Any step run by hand had the same gap.

## Decision

- Every skill whose Override points table has a point resolves its own layers before its first step, by one
  procedure in [contracts "Resolving layers"](../../contracts/README.md#resolving-layers). Each such skill carries
  one line pointing to it, not a copy.
- `ship` stops collecting overrides. It hands each step the `layers:` line and keeps the resolution table, so a
  missing variant stays visible.
- A worker never resolves; its dispatcher does and puts the overrides in the brief.
- `tests/layers.test.sh` fails when a skill with points lacks the pointer, or a fixed helper list comes back.

## Consequences

- A new skill with override points gets its layers without a contract change, once it carries the pointer
  (CI checks it).
- One mechanism instead of two: nested calls (verify → qa-tests → delegate) and standalone runs work the same.
- Each skill reads its own variants, so a run invokes each variant when its skill starts, not all up front.
- Supersedes #69's "a step run outside `ship` skips layers" and its fixed helper list.
