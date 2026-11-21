---
name: ship
description: Use when taking a ticket or a described piece of work from start to an open PR and a retro ("ship #42", "fix this bug end to end", "build X the full way"), or when resuming a half-done factory task folder. Not for one-line tweaks the user wants done directly.
---

# ship

The factory's orchestrator. It owns the order of the steps, the stops, the loops and `status.md`, and nothing
else: every step's procedure lives in that step's skill. The shared rules (task folder, `status.md` lines,
stops, verdicts, layers, override points) are in [../../contracts/README.md](../../contracts/README.md). Read it
before the first step. `ft` below means `bash <plugin root>/contracts/factory-task`, by its absolute path; the plugin root
is two directories above this skill's base directory.

## Start

1. **New run or resume?** If the user names a task folder, or `.factory/*/status.md` (or the layer's task
   folder location) holds one whose slug matches the request, resume it (below). Otherwise start at intake.
2. **Layers.** Read the first `factory layers:` line from `AGENTS.md`, else `CLAUDE.md`, at the repo root. No
   line: core only. Once the task folder exists, log
   `ship done <date> status.md layers: <list or none> (from <file>)`.
3. **Resolution table.** For every pipeline step, list which skills were found: the core skill plus each
   declared layer's `<prefix>-<step>` that exists, for example `verify: factory:verify + shop-verify` or
   `tracker: factory:tracker (no layer variant)`. A missing variant means the core default applies. Print the
   table, and once the task folder exists log `ship done <date> status.md resolution: <step>: <skills>; …`.
4. **Accelerators.** Check the available skills for the soft dependencies each step names. Log
   `ship done <date> status.md accelerators: <present ones, or none>`, so a shallower run is visible.

## Running a step

1. **Collect overrides first.** For each declared layer, lowest first, invoke `<prefix>-<step>` if the
   resolution table lists it, and collect its Overrides table. A higher layer's answer for a point replaces a
   lower one's.
2. **Run the core step** with the collected values applied: invoke `factory:<step>` with the Skill tool and give
   it the task folder's absolute path, the tier and the collected overrides. A `set` value replaces the default;
   a `replace` swaps the mechanics of that point only.
3. **Run `extend` additions** after the core's own steps, in layer order.

The step writes its own files and its own `status.md` line; `ship` logs the lines for the stops and for the
steps it owns (`simplify`).

## Pipeline

| # | Step | Call | Writes |
|---|---|---|---|
| 1 | intake | `factory:intake` | task folder, `context.md`, `ticket.md`, `decisions.md` |
| 2 | tier | `factory:tier` | `tier.md` |
| 3 | understand | `factory:understand` (bug → root cause, feature → spec); may re-tier; fallback below | `combined.md` or `spec.md` |
| 4 | plan | `factory:plan` | `plan.md` |
| 5 | build | `factory:build` | `impl/` |
| 6 | simplify | `simplify` plus the case inventory (below); from T1 | `simplify/` |
| 7 | review | `factory:review` | review output |
| 8 | verify | `factory:verify` | `verify.md`, `gaps.md`, `verify/` |
| 9 | finalize | `factory:finalize` | `pr-body.md`, PR url |
| 10 | retro | `factory:retro` | `retro.md`, `skill-fixes.md` |

- A step whose skill is not installed is logged `<step> skipped <date> - <skill> not available` and the run
  continues; the next step works from what exists. Never improvise a missing step's procedure.
- **understand fallback** until `factory:understand` exists: for a bug, `superpowers:systematic-debugging`,
  with its verdict written to `combined.md`; for a feature or improvement, `superpowers:brainstorming`, writing
  `spec.md`. Log `ship done <date> status.md fallback: understand → <skill>`. Only when neither is installed, log
  `understand skipped <date> - not available`.
- **Re-tier** after understand when the root cause or the spec changes the size or risk: run `factory:tier`
  again before plan.
- **Simplify**: before touching anything, list the test cases that cover the changed code
  (`simplify/inventory-before.md`); after, list them again (`inventory-after.md`) and diff them
  (`inventory-diff.md`). A case dropped or weakened is a regression, not a simplification. `simplify` is the
  built-in Claude Code skill; without it, do the same pass inline.
- **Review comes before verify.** A failed review or verify loops to build, and the whole review → verify path
  runs again. **Verify after every build round**, and again if any production line changed after a run.
- **Retro runs even when the work stopped early.**

## Stops

The tier decides which stops are active ([stops.md](stops.md)). At an active stop, follow the stop contract:
print the path, a 3–5 line summary, ask **continue / change / stop here**. At an inactive stop, log
`<step> done` and continue, but still show the summary in one line. Asks inside a step are never skipped.

The tier is not known when intake ends, so run `tier` first and then apply the intake stop for that tier,
showing `decisions.md` and `tier.md` together.

## Resume

Read `ft last <folder>`, key on its step and state, and say which line you resumed from. If the file the line
names is missing, re-run that step instead of showing it.

| Last line | Continue at |
|---|---|
| none | intake |
| `<step> stopped … awaiting answer` | that stop: show the file, ask again |
| `<step> stopped` with any other reason | show the reason, ask, then re-run that step |
| `<step> changed` | re-run that step, then its stop |
| `<review\|verify\|finalize> loop` | build, round N+1 |
| `build done` | simplify (first round) or review (later rounds) |
| `<step> done` or `<step> skipped` | the next step in the pipeline |
| `ship …` | the step after the last non-`ship` line |
| `retro done` | finished; nothing to resume |

Work already committed before intake: after intake, log understand, plan and build as `skipped` with the
commit sha as the reason, then continue at review.

## Context budget

After each stop, if context use is over 40%, say so in one line and suggest the user start a new session that
resumes this task folder at the next step. Repeat after each further 10%.

## Do not

- Put a step's procedure here. Call the step.
- Continue past a "change". Log it, re-run, stop again.
- Restart at intake on resume, or infer progress from which files exist.
- Reuse an earlier ticket's answer as approval for this one.
- Commit `plan.md` or anything in the task folder.

## Override points

| Point | Default | Allowed |
|---|---|---|
| stops per tier | the table in [stops.md](stops.md) | `set`: add or remove stops per tier; a removal carries a reason, logged as `ship … loosened:` |
| task folder search | `.factory/*/status.md` | follows `intake`'s task folder location; not set here |
