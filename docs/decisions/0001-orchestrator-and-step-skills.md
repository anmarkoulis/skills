# 1. One orchestrator, step skills, state on disk

Date: 2026-11-21. Status: accepted.

## Context

A ticket-to-PR run spans many steps and often more than one session. Chat history gets compacted or lost, and
after compaction only the first few thousand tokens of each loaded skill come back. A single skill holding the
whole procedure loses its place; a run nobody can audit cannot be trusted.

## Decision

- The factory is one orchestrator, `ship`, plus step skills that each do one job.
- `ship` holds no procedure. It owns the order of steps, the stops, the loops and `status.md`. Each step's
  procedure lives in that step's skill.
- Every step reads and writes named files in a task folder ([0007](0007-task-folder.md)). Chat is never the
  source of truth. The last line of `status.md` decides where a run resumes; progress is never inferred from
  which files exist.
- Evidence or it did not happen: a pass needs the command and its output, a command cut off by a timeout has
  not passed, and a failure is not "pre-existing" until the same command on the base shows it. No layer can
  loosen these rules.
- `plan` and `review` are thin core skills.

## Consequences

- `ship` stays short enough to survive compaction; the state survives in files.
- A run can stop, resume in a new session, and be audited afterwards.
- Every step needs a written contract: which files it reads, which it writes, and the verdict it ends with.
