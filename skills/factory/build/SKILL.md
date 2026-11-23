---
name: build
description: Use as the build step of anmarkoulis:ship, or on a loop back from review or verify, to implement plan.md in the working tree with tests first, and to re-verify the implementer's claims. Output is evidence (red and green logs), not a commit.
---

# build

Implements `plan.md`. Writes `impl/` in the task folder and never commits, pushes or opens a PR. Contracts:
[../../../contracts/README.md](../../../contracts/README.md).

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

**Inputs:** `plan.md`, the working tree path and branch from `decisions.md`, `tier.md`, and on a loop the
loop line's reason. Read the whole plan before asking anything.

## 1. Ask the execution method, every time

One question; never reuse an earlier ticket's or round's answer. If this round's
plan stop already got the method, use that answer and say so. On a loop round, offer one more option: the same
method for the remaining rounds of this run; when chosen, record it in `impl/status.md` and do not ask again in
this run. Mark one option recommended with a one-line
reason (the tier's recommendation, then the plan's size):

| Method | Runs as | Accelerator, when installed |
|---|---|---|
| Inline | this session follows the brief itself | `superpowers:executing-plans` |
| Subagents | one implementer per task, plus a reviewer per task at T2 | `superpowers:subagent-driven-development` |
| One background agent | a single agent runs the whole plan | — |

Pick each worker (roles `implementer` and `reviewer`) with `anmarkoulis:delegate`, which logs every fallback.
If the user wants plan changes instead, send them back to `plan`.

## 2. Send every method the same brief

[brief.md](brief.md) is the fixed implementer brief. Fill in the paths, add the **extra brief rules** a layer
declares and any plan-specific rules as further numbered lines, and never drop one. Write the filled-in brief to
`impl/brief.md` before dispatching. Building inline, follow it yourself.

For a background worker, wait for its notification; never poll its output file. A `BLOCKED` line goes to the
user with its reason first. A worker that ends without `ALL TASKS DONE` or `BLOCKED` stopped early: check the
working tree, then relaunch with a rule saying what is already done.

## 3. Verify the implementer yourself

Never trust "PASS", "pre-existing" or "unchanged":

1. Re-run the new tests and the touched suites with the **test command**; save output to `impl/lead-<n>.log`.
2. Check `git diff --stat` and `git status --short` match what the report claims.
3. Re-check every "pre-existing" claim: the base command and its output must be in a log; otherwise run the
   base A/B yourself.
4. Run the **lint command** on the touched files. A new issue on a line we wrote is ours.
5. Run the **extra lead checks** a layer adds, each with its output saved to `impl/`.

The result is a verdict: `success`, `flawed` (re-dispatch with the failing evidence) or `blocked`.

## 4. Write the outputs

- `impl/red<N>.log`, `impl/green<N>.log`, base-run logs, `impl/prod.patch`.
- `impl/status.md`: changes (one line per file), deviations from the plan, evidence (a log per claim), adjacent
  problems found and not fixed.
- Log `build done <date> impl/status.md`; on a loop,
  `build done <date> impl/status.md round <N> ← <review|verify>: <reason>`. Blocked:
  `build stopped <date> impl/status.md <reason>`. Build has no stop of its own.

## Override points

| Point | Default | Allowed |
|---|---|---|
| test command | the repo's documented test command (README, `AGENTS.md`, `Makefile`, package scripts); ask if none | `set` |
| lint command | the repo's documented linter; none if there is none | `set` |
| extra brief rules | none | `extend` |
| extra lead checks | none: the four checks in step 3 | `extend` |
