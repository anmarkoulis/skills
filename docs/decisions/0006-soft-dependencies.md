# 6. Soft dependencies on other skill libraries

Date: 2026-11-21. Status: accepted.

## Context

Libraries such as superpowers and mattpocock/skills already do parts of the work well (brainstorming,
debugging, plan writing, plan execution). Requiring them would make the factory fail on machines without them.

## Decision

- Every step has a built-in procedure and works on its own.
- When a known library skill is installed, the step uses it for more depth (for example
  `superpowers:writing-plans` in `plan`, two blind diagnoses with `superpowers:systematic-debugging` and
  `mattpocock-skills:diagnosing-bugs` in `debugging`).
- `ship` checks at start which of these are present and records it, so a shallower run is visible.

## Consequences

- The factory installs with no required dependencies.
- Each step must keep its built-in procedure good enough to stand alone, and record when it ran without the
  accelerator (for example "single-method diagnosis").
