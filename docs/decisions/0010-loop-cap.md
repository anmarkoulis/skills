# 10. Cap the build loop

Date: 2026-11-22. Status: accepted.

## Context

A failed review, verify or finalize loops back to build. Nothing limited the loop. A finding that keeps
coming back used up rounds and nobody saw it. `status.md` already recorded every round, but nothing read it.

## Decision

- `factory-task rounds` counts the `build done` lines since the last `plan done`. A new plan gets a fresh count.
- `ship` has a **max build rounds** override point: T0 2, T1 3, T2 3.
- Before a loop goes to build, `ship` stops at the cap, or earlier when a finding that a round claimed to fix
  comes back. It shows what each round fixed and what came back, then asks: one more round (raises the cap by
  one, logged in `status.md`), back to plan, back to understand, or stop and run retro.
- This stop is active at every tier, because a loop that never ends is a cost at any risk level.
- Repeats are found by `ship` reading the findings, not by the script. Loop reasons are free text, and making
  them machine-readable would change every step that writes one.

## Consequences

- A resumed task folder at the cap stops instead of building again, because the cap and its raises live in
  `status.md`.
- Step skills do not know about the cap. `ship` owns loops ([ADR 1](0001-orchestrator-and-step-skills.md)).
