# 8. Claude Code first

Date: 2026-11-21. Status: accepted.

## Context

Supporting several harnesses before the contracts have shipped real tickets would multiply work on contracts
that are still changing.

## Decision

- Harness-neutral is a design rule, not a support claim: steps avoid hard dependencies on harness-only
  features and degrade to inline.
- v0.1 is built and tested on Claude Code only. OpenCode and Codex come later, once the contracts have shipped real tickets.
- Where a skill uses a harness feature (a structured question, dispatching or monitoring a subagent), it names
  the feature, so a later per-harness note can map it. Without the feature the step degrades to inline or to a
  plain question.

## Consequences

- Skills may rely on Claude Code behaviour in v0.1, but name it rather than hide it.
- Multi-harness packaging is deferred.
