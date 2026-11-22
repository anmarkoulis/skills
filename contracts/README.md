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
```

- The **last line** decides where a run resumes. Never infer progress from which files exist.
- `<file>` is relative to the task folder, or absolute when it lives elsewhere (a review output).
- `skipped` needs a reason. A loop is `<review|verify> loop <date> <file> →build <reason>`, followed by
  `build done <date> impl/status.md round <N> ← <review|verify>: <reason>`, where N is the number of earlier
  `build done` lines plus 1.
- Facts that are not step events use step `ship`: `ship done <date> status.md layers: acme, shop (from AGENTS.md)`,
  `ship done <date> status.md fallback: <what> → <what>`, `ship done <date> status.md loosened: <rule> because <reason>`.

## Stops

At a stop, print the file's absolute path, a 3–5 line summary and one question: **continue / change / stop
here**. Before asking, log `<step> stopped <date> <file> awaiting answer`.

- **continue**: log `<step> done`, go on.
- **change**: apply the correction, log `<step> changed … <reason>`, re-run the step, stop again. A change at
  verify or review that needs code is a loop to `build` (above).
- **stop here**: log `<step> stopped <date> <file>` and end.

Which stops are active is decided by the tier (`ship`'s stop table). Asks inside a step (which ticket, worktree
or inline, execution method, every tracker write, commit and push) are not stops and are never skipped.

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

`ship` reads the line itself (it does not rely on the harness loading either file) and logs where it came from.
No line means core only. For step `<step>`, `ship` first collects the Overrides table of each declared layer's
`<prefix>-<step>` skill, lowest first, then runs the core skill `factory:<step>` with those values, then runs
the `extend` additions. A variant whose prefix is not declared is never
used. A missing variant means the core default applies; `ship` logs a resolution table at the start of every
run (`ship done <date> status.md resolution: …`) so it is visible.

## Override points

Every core skill ends with an **Override points** table: `point | default | allowed`, where allowed is any of
`set` (a value or command), `extend` (add steps after the core's) and `replace` (swap the mechanics). A point
not in the table is not overridable.

The contracts have no override points of their own: the task folder location is `intake`'s **task folder
location** point.

A variant skill answers with an **Overrides** table, `point | this layer`, and says in its description which
skill it extends:

```markdown
---
name: shop-verify
description: Extends factory:verify for the shop repo with its test commands and staging quirks.
---
| Point | This layer |
|---|---|
| L1 commands | set: `make test`, `make lint` |
```

Layers may add and tighten freely. Loosening a rule (removing a stop, skipping a level the tier requires) needs
a reason and is logged as `ship … loosened:`. Evidence rules cannot be loosened.
