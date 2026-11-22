# 5. Agents and worker levels

Date: 2026-11-21. Status: accepted.

## Context

Specialist agents make steps faster and cheaper, but they are not always present, their tools may fail to
resolve, and some harnesses have no subagents at all. A step must not depend on any of that to be correct.

## Decision

- `delegate` defines one contract and three ways to run it: (1) a named specialist agent a layer names, or the plugin's
  own agent for the role, and that resolves; (2) a generic worker with the step's brief plus the procedure the specialist would have carried;
  (3) the current session, inline.
- The contract is identical at every level: the same inputs and a result file in the same shape. Every fallback
  is logged in `status.md`. A named agent that cannot be found falls back to the next level (lost speed or
  cost, not correctness).
- Selection, most specific first: the agent a plan task names, then the agent a layer maps to the role, then a
  generic worker, then inline.
- The agent definition carries who (tools, model, domain rules); the step's brief carries what (goal, scope,
  stopping condition, result file). The agent's model stands unless the tier needs a stronger one.
- Agent routing is declared in the project's `-delegate` Overrides (amended 2026-11-21: was `-build`); `plan`
  writes the chosen agent onto each task.
- A review run inline is the author reviewing their own work and is recorded as "not independent".
- Every worker ends with one verdict: `success`, `flawed`, `blocked` or `manual`, plus its evidence.

## Consequences

- Specialist agents are accelerators, never requirements.
- Workers must write results to files, so the lead can re-verify them.
