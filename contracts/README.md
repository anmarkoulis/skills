# Factory contracts

What every step skill and every layer variant relies on. Decisions behind them:
[docs/decisions/](../docs/decisions).

## Task folder

One folder per piece of work. Only `intake` creates it, with the resolver script in this folder:

```
bash <this folder>/factory-task path <slug> [<base>]     # prints the absolute path
```

- Default `<repo root>/.factory/<slug>/`. `<base>` is `intake`'s **task folder location** override point.
- When the script creates the base, it writes a `.gitignore` containing `*` there, so the folder never shows in
  `git status`. An existing base is left as it is.
- `<slug>`: lowercase, `[a-z0-9._-]`, from the ticket id and title (`42-fix-login`), else from the request.
- Every other step receives the folder's absolute path from `ship` and never computes it.
- After a worktree is created, `intake` resolves the same slug with `-C <worktree>`, moves the contents there
  and logs the move. From then on the worktree holds the folder.

| File | Written by | Content |
|---|---|---|
| `status.md` | every step | one line per event (below) |
| `context.md` | intake | summary, related items, prior work; mismatch flags at the top |
| `ticket.md`, `raw/` | intake via `tracker` | ticket summary; untouched tool output |
| `decisions.md` | intake, later steps | decided / rejected / confidence with the named missing piece |
| `tier.md` | tier | tier, signals, rules matched, reasoning, re-tiers |
| `combined.md`, `debugging/`, or `spec.md`, `spec-questions.md` | understand, via `debugging` or `spec` | root-cause verdict, or spec plus question ledger |
| `plan.md` | plan | the plan; never committed |
| `impl/` | build | brief, red and green logs, `prod.patch`, `status.md` |
| `verify.md`, `gaps.md`, `verify/` | verify | regression map, numbered runs, what is not proven |
| `pr-body.md` | finalize | PR body |
| `retro.md`, `skill-fixes.md` | retro | lessons; proposed edits, agents and checks |

## status.md

```
<step> done|stopped|changed|loop|skipped <YYYY-MM-DD> <file> [<reason>]
```

Write lines only through the script. It checks the step name, the state, a file without whitespace, a one-line
reason, the reason a `skipped` needs and the `→build` a `loop` starts with; the rest of the rules below are conventions:

```
bash <this folder>/factory-task log <folder> <step> <state> <file> [<reason>]
bash <this folder>/factory-task last <folder>
bash <this folder>/factory-task rounds <folder>
```

- The **last line** decides where a run resumes. Never infer progress from which files exist.
- `<file>` is relative to the task folder, or absolute when it lives elsewhere (a review output).
- `skipped` needs a reason. A loop is `<review|verify> loop <date> <file> →build <reason>`, followed by
  `build done <date> impl/status.md round <N> ← <review|verify>: <reason>`, where N is the number of earlier
  `build done` lines plus 1.
- Facts that are not step events use step `ship`: `ship done <date> status.md layers: acme, shop (from AGENTS.md)`,
  `ship done <date> status.md fallback: <what> → <what>`, `ship done <date> status.md loosened: <rule> because <reason>`.

### Loop cap

A loop never starts build unchecked ([ADR 10](../docs/decisions/0010-loop-cap.md)).

- **Rounds** are the `build done` lines since the last `plan done`: `factory-task rounds <folder>`. A new plan
  starts a fresh count.
- **The cap** is the N of the last `ship done <date> status.md loop cap raised to <N>` since the last
  `plan done`, else `ship`'s **max build rounds**.
- **At the cap.** When a `<review|verify|finalize> loop` is the last line and rounds ≥ cap, `ship` does not run
  build. It logs `ship stopped <date> status.md loop cap <N> reached`.
- **Repeated finding.** Before acting on a loop, `ship` compares its file's findings (`file:line` and reason)
  with the previous loop's file. When a finding that a round claimed to fix is back, it logs
  `ship stopped <date> status.md repeat finding <file:line>`, whatever the count.
- **The stop** shows one line per round: what that round's `build done` reason fixed, and what the next loop
  sent back, with repeats marked. Then it asks one question:
  - **one more round**: log `ship done <date> status.md loop cap raised to <N+1>`, N being the current cap,
    then build. A raise logged after a loop line settles both checks for that loop;
  - **back to plan**: the plan is wrong; re-run `plan` (its `plan done` resets the count);
  - **back to understand**: the problem is misunderstood; re-run `understand`, then `plan`;
  - **stop here**: log `ship stopped <date> status.md loop cap <N>: stopped by user`, then run `retro`.

## Stops

At a stop, put the file in front of the user, then ask one question: **continue / change / stop here**. Before
asking, log `<step> stopped <date> <file> awaiting answer`.

- **Show the content:** print the file in full when it is short, else the sections the question is about. A
  path alone is not showing it.
- **Full paths:** name every file by its absolute path (`/Users/me/repo/.factory/42-fix-login/plan.md`, not
  `plan.md` or `.factory/…`), in the text and in the question, so it is clickable in the terminal.
- **Summary in the question:** put the 3–5 line summary in the question text itself; the question dialog can
  hide what was printed before it.

- **continue**: log `<step> done`, go on.
- **change**: apply the correction, log `<step> changed … <reason>`, re-run the step, stop again. A change at
  verify or review that needs code is a loop to `build` (above).
- **stop here**: log `<step> stopped <date> <file>` and end.

Which stops are active is decided by the tier (`ship`'s stop table). Asks inside a step (which ticket, worktree
or inline, execution method unless this round's plan stop already got it, every tracker write, commit and push)
are not stops and are never skipped.

## Results

Every step and every worker ends with one verdict plus the evidence it rests on:

| Verdict | Means | Next |
|---|---|---|
| `success` | done, with evidence | next step |
| `flawed` | the work is wrong | back to `build` |
| `blocked` | needs a person to decide or unblock | stop and ask |
| `manual` | needs a person to check what the factory cannot | stop and ask |

**Evidence rules** (no layer can loosen them): a pass needs the command and its output; a command cut off by a
timeout has not passed; a failure is not "pre-existing" until the same command on the base shows it; a source
you could not reach is "not checked", never "0" or "none".

## Layers

A repo declares its layers, lowest first, on one line in `AGENTS.md`, else `CLAUDE.md`, at the repo root:

```
factory layers: acme, shop
```

A person adds their own layer without touching the repo ([ADR 11](../docs/decisions/0011-personal-layer.md)):
the first `factory personal layers: <prefix>` line in `CLAUDE.local.md` at the repo root, else in
`~/.claude/CLAUDE.md`. Personal layers always come after the repo's; a prefix the repo already declares is not
added twice.

The lines are read from the files, never from what the harness happened to load. No line means core only. A
variant whose prefix is not declared is never used; a missing variant means the core default applies.

### Resolving layers

Every skill whose **Override points** table has a point resolves its own layers before its first step, inside
`ship`, called by another skill, or run on its own ([ADR 12](../docs/decisions/0012-layers-wherever-a-table-exists.md)):

1. **The list.** Use the `layers:` line the caller handed over (a handed `layers: none` counts). None handed:
   read the two lines above yourself. No line found: say "layers: none" in one line and skip to the skill's first
   step. A skill this session already resolved for the same list reuses that result.
2. **The variants.** For each prefix, lowest first, invoke `<prefix>-<skill>` if it exists, and collect its
   Overrides table and the sections its cells point to. Merge them by the rule below.
3. **Pass it on.** When you call another skill, hand it the `layers:` line; it resolves its own variants. A
   worker never resolves: put the overrides its work depends on in its brief.
4. **Say what applied.** Inside `ship`, its `resolution:` line covers it. Otherwise say it in one line of the
   skill's own output: `layers: <list>; applied: <variants or none>`.

### Merging

For one skill, the Overrides tables of each declared layer's `<prefix>-<skill>`, lowest first, combine as:

| Allowed | Several layers answer |
|---|---|
| `set` | the highest layer's value wins |
| `replace` | the highest layer's mechanics win |
| `extend` | every layer's additions run, after the core's, lowest layer first |

A row left at `default` is no answer: a lower layer's value stands.

### Variant skills

A variant `<prefix>-<skill>` is config, not a wrapper: it never calls the core skill; the core skill reads it.

- **Where:** any skill folder the session loads: the project's `.claude/skills/`, the user's `~/.claude/skills/`,
  or a plugin. Resolution is by name, so a company layer can live once at user level and serve every repo.
- **Description:** says which skill it extends and that it is not for direct use, so it does not trigger on its
  own: `Extends anmarkoulis:verify for the shop repo with … Not for direct use; the core skill applies it.`
- **Body:** the Overrides table, then optional sections below it. A cell may point to a section by its heading
  (`replace: see "Jira mechanics"`), and the section is read as part of the value. A `replace` always needs one:
  a cell cannot hold mechanics.

## Override points

Every core skill ends with an **Override points** table: `point | default | allowed`, where allowed is any of
`set` (a value or command), `extend` (add steps after the core's) and `replace` (swap the mechanics). A point
not in the table is not overridable.

The contracts have no override points of their own: the task folder location is `intake`'s **task folder
location** point.

A variant skill answers with an **Overrides** table, `point | this layer` ([variant skills](#variant-skills)):

```markdown
---
name: shop-verify
description: Extends anmarkoulis:verify for the shop repo with its test commands and staging quirks. Not for direct use; the core skill applies it.
---
| Point | This layer |
|---|---|
| L1 commands | set: `make test`, `make lint` |
| A/B mechanism | replace: see "Base vs fix" |

## Base vs fix
Stop the stack, `git stash` the fix, `make up`, run the case, `git stash pop`.
```

Layers may add and tighten freely. Loosening a rule (removing a stop, skipping a level the tier requires) needs
a reason and is logged as `ship … loosened:`. Evidence rules cannot be loosened.
