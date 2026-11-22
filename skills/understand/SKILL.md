---
name: understand
description: Use as the understand step of factory:ship, after intake and tier and before plan, so the work is understood before any code is written: a bug gets a root cause through factory:debugging, a feature or improvement gets a spec through factory:spec. Routes by ticket type.
---

# understand

Routes by ticket type and writes nothing of its own beyond `decisions.md` lines: `debugging` writes
`combined.md`, `spec` writes `spec.md` and `spec-questions.md`. No code edits. Contracts:
[../../contracts/README.md](../../contracts/README.md). `ft` means `bash <plugin root>/contracts/factory-task`;
the plugin root is two directories above this skill's base directory.

**Inputs:** the task folder (`ticket.md`, `context.md`, `decisions.md`), the tier. Load the **domain skills**
before routing.

## 1. Route by type

Take the type from `ticket.md`. Absent or unclear: ask the user (bug, feature or improvement). No answer: log
`understand stopped <date> ticket.md type unknown` and end.

## 2. Bug

1. **Root cause.** If `combined.md` exists, read it and do not re-run. Otherwise invoke `factory:debugging` with
   the task folder and the tier; intake's `ticket.md` and `raw/` are its inputs.
2. **Show the verdict:** root cause, fix shape and size, confidence, open questions. On a correction, re-run
   `factory:debugging` with it as an extra input (overwriting `combined.md`), log
   `ft log <folder> understand changed combined.md <reason>`, and show the new verdict.
3. **No root cause:** show the open questions and ask how to go on. Never create a fix task on an unverified
   cause.
4. **Fix task** (the **fix-task creation** point). `factory:tracker` `create task parent <bug id>`, with title
   `Fix: <root cause, short>` and a body holding the root cause, fix shape and size from `combined.md` (for a
   security-sensitive bug, no exploit detail). The tracker asks before creating. Record the new id in
   `decisions.md`; declined: note it there and go on.
5. **Branch rename** (the **branch-rename hook**): when a fix task was created, run the hook a layer sets, else
   ask whether to rename the branch to the new id.
6. **Missing behaviour.** If `combined.md` shows the cause is behaviour never built rather than a defect, ask
   whether to spec it. Yes: run `factory:spec` with the bug's `ticket.md` and `combined.md` as input.

## 3. Feature or improvement

Invoke `factory:spec` with the task folder and the tier.

## 4. Re-tier

If the root cause or the spec changed the size or risk the tier assumed, say so and ask `ship` to run
`factory:tier` again before plan.

## Done

Log `understand stopped <date> <combined.md|spec.md> awaiting answer` when the tier has an understand stop,
otherwise `understand done <date> <combined.md|spec.md>`. When `debugging` or `spec`
stopped: log `understand stopped <date> <its file> <reason>`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| fix-task creation | on: create a task under the bug | `set` (`off`) |
| branch-rename hook | ask the user | `set` |
| domain skills to load | none | `extend` |
