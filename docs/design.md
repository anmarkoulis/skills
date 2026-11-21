# Factory design

Status: **draft**. Decisions marked *(open)* are not settled; see [Open questions](#open-questions).

## 1. What the factory is

A pipeline that takes a piece of work from a ticket (or a plain request) to a pull request and a retro. It is
built as one **orchestrator** that only makes decisions and a set of **step skills** that each do one job. The
steps write their results to files, so a run can stop, be resumed in a new session, and be audited afterwards.

It is generic: it knows nothing about a particular tracker, test suite, deploy process or codebase. Everything
specific comes from layers that a person, a company or a project adds on top (section 4).

## 2. Principles

1. **The orchestrator holds no procedure.** `ship` owns the order of steps, the stops, the loops and
   `status.md`. Each step's procedure lives in that step's skill.
2. **State lives on disk.** Every step reads and writes named files in a task folder. Chat is not a source of
   truth: it can be compacted or lost. After compaction only the first few thousand tokens of each loaded skill
   come back, so the orchestrator stays short and the state stays in files.
3. **Evidence or it did not happen.** A pass needs the command and its output. A command cut off by a timeout has
   not passed. A failure is not "pre-existing" until the same command on the base shows it. No layer can loosen
   these rules.
4. **The tier decides the depth.** One risk tier, set after intake, decides which stops run, how deep each step
   goes and where a person must approve (section 6).
5. **Generic core, declared overrides.** A layer may change only what a core skill declares as an override
   point (section 5). Anything not declared is not overridable.
6. **Soft dependencies.** Every step works on its own. Other skill libraries, when installed, add depth
   (section 8).
7. **Harness-neutral.** Claude Code is the reference harness. Every step that dispatches a subagent also works
   inline, so the factory runs where subagents do not exist.
8. **No leaks.** No company, project or personal specifics in this repository. A CI check enforces it
   *(planned)*.

## 3. Steps

```
intake → tier → understand → plan → build → review → verify → finalize → retro
                    ↑ re-tier          ↑_______ loop on a failed review or verify
```

| Step | Skill | Does | Writes |
|---|---|---|---|
| 1 | `intake` | Asks which ticket (and whether to create one), searches prior work, flags mismatches between the request and the ticket, sets up the workspace, asks one batch of scope questions | `context.md`, `ticket.md`, `raw/`, `decisions.md` |
| 2 | `tier` | Sets the risk tier from the signals and the layers' rules, with one line of reasoning | `tier.md` |
| 3 | `understand` | Routes by type: bug → `debugging`, feature or improvement → `spec`. May re-tier | `combined.md` or `spec.md` |
| 4 | `plan` | Writes the plan, verifies library assumptions, posts it to the ticket (updated in place) | `plan.md` |
| 5 | `build` | Asks the execution method, sends the fixed implementer brief, re-verifies the implementer's claims | `impl/` |
| 6 | `review` | Runs the code review at the tier's depth, fixes what is agreed | review output |
| 7 | `verify` | Regression map, levels L1–L4, numbered runs, gaps; calls `qa-tests` and `manual-test` | `verify.md`, `gaps.md`, `verify/` |
| 8 | `finalize` | Commit, push, PR, ticket update, CI loop, merge policy, cleanup | `pr-body.md`, PR url |
| 9 | `retro` | Lessons; proposes skill edits, agents and checks; applies only what is approved | `retro.md`, `skill-fixes.md` |

Supporting skills: `debugging`, `spec`, `qa-tests`, `manual-test`, `tracker`, `delegate`, `setup`.

Rules between steps:

- **Review comes before verify.** A failed review or a failed verify goes back to `build`, and the whole
  review → verify path runs again. `build` records the round: `build done … round N ← review|verify: <reason>`.
- **Verify after every build round**, and again if any production line changed after a run.
- **Simplify** (inside `ship`, before review, from T1): list the test cases that cover the touched code before
  and after; a case dropped or weakened is a regression.
- **Re-tier after understand** when the root cause or the spec changes the size or risk of the work.

## 4. Layers

```
factory                core: generic steps, contracts, tier engine        (this repo)
  └─ organisation      what a person's or a company's repos share         (a plugin the owner installs)
       └─ project      one repo's specifics                                (skills in the repo)
personal preferences   commit style, attribution, paths                     (the user's CLAUDE.md)
```

- **Organisation layer.** A plugin with skills named `<org>-<step>`: for example a person's own plugin
  (`me-tracker` for Linear, `me-finalize` for merge-when-green) or a company's (`acme-tracker` for its tracker,
  release tooling). Installed at user level on the machine where it applies.
- **Project layer.** Skills in the repo, named `<project>-<step>`, for one repo's test suites, environments,
  agents and domain knowledge.
- **Personal preferences** stay in the user's instruction file. They apply through instruction precedence
  (user instructions beat skills) and need no plugin.

A repo declares its layers, lowest first, in its `AGENTS.md` (or `CLAUDE.md`):

```
factory layers: me, my-project
```

Resolution for step `<step>`: the factory loads the core skill, then each declared layer's `<prefix>-<step>` in
order, if it exists. Each variant says in its description which skill it extends ("Extends `me-verify` with …"). A
variant in a repo that does not declare its prefix is never used.

Same-name shadowing is never used. Claude Code resolves skill names personal before project, and OpenCode
resolves them the other way round, so two skills with one name behave differently per tool. Distinct prefixes
avoid the question.

**Missing pieces.** A variant that a declared layer needs but cannot find stops the run (lost behaviour). A
named agent that cannot be found falls back to the next worker level and is logged (lost speed or cost, not
correctness; section 7).

## 5. Override points

Every core skill ends with an **Override points** table. It is the step's public contract with the layers.

| Point | Default | Allowed |
|---|---|---|
| name of the point | what the core does when no layer answers | `set` (a value or command), `extend` (add steps after the core's), `replace` (swap the mechanics; rare) |

A variant answers with an **Overrides** table: `point | this layer`. Layers may add and tighten freely. Loosening
(for example skipping a level the tier requires) must be stated with a reason and is written to `status.md`.
Evidence rules (principle 3) cannot be loosened.

First cut of each step's override points *(open: defaults and allowed operations to be settled per skill)*:

| Skill | Override points |
|---|---|
| `ship` | stop defaults per tier (tighten only) |
| `tier` | sensitive areas; minimum tier per path or change type |
| `intake` | task folder location; workspace command; extra scope questions; observability sources |
| `understand` | fix-task creation under a bug; branch-rename hook; domain skills to load |
| `debugging` | diagnoser agent; telemetry sources; production ref |
| `spec` | none beyond `tracker` |
| `plan` | where the plan is posted (through `tracker`) |
| `build` | extra brief rules; implementer and reviewer agents; test and lint commands |
| `review` | review skill; review rules file (for example `REVIEW.md`) |
| `verify` | L1 commands; consumers outside the repo; A/B mechanism; environment quirks |
| `qa-tests` | suite location; prerequisites; required flags |
| `manual-test` | how to reach the app; login; real-account rules |
| `finalize` | git workflow; merge policy; ticket states; cleanup commands |
| `retro` | where approved rules land |
| `tracker` | the mechanics of every operation (`replace` allowed) |

## 6. Tiers

`tier` runs after intake and again after understand when the work changed shape. It proposes a tier with one
line of reasoning. Default: the user confirms T2; T0 and T1 are announced and the user can interrupt.

**Tier policy** has three override points: which tiers need confirmation, minimum tiers for paths or change
types, and stops per tier (a layer may add or remove stops; a removal carries a logged reason). Evidence rules
are not part of it and cannot be changed.

Who sets it, lowest to highest:

1. the core defaults (this document);
2. the organisation and project layers: the **repo default**, committed with the repo;
3. the **user's own override**, which applies to that user only and is never committed to the repo;
4. **the current run**: the user just asks ("treat this as T2", "also stop at verify"); `tier.md` records it as
   set by the user and `ship` applies it at once.

Asking for a lasting change ("always confirm the tier here") makes the factory propose the edit to the right
file, the repo default or the user's own override, shown as a diff and written only after a yes. A rule never
lives only in chat or memory. *(open: where the user's own override lives, and its bounds; open question 1.)*

**Signals (core):** reversibility (one-way or two-way door); sensitive areas (from the layers); ambiguity (known
cause or design vs not); verification available (does a cheap, trustworthy check exist?); size.

**Rules (layers):** sensitive areas and minimum tiers, for example "anything under migrations is at least T2",
"security, outbound-call and user-facing changes are at least T1".

| Controls | T0 trivial | T1 standard | T2 risky |
|---|---|---|---|
| Stops (core default; layers only add) | none | plan (plan and execution method) | intake, understand, plan, review, verify, PR |
| `debugging` | one diagnosis | one diagnosis | two blind diagnoses, reconciled |
| `spec` | premise check | grill when no spec exists | full grill and question ledger |
| `build` method (recommended) | inline | by plan size | subagents per task, specialist agents |
| `review` | local review | fresh-context review | deep review plus security review |
| `verify` | L1 | L1–L2 | L1–L3, base-vs-fix A/B, outside consumers |
| Simplify inventory | skipped | yes | yes |
| `finalize` merge | layer policy | layer policy | a person merges |
| `retro` | only on friction | short | full, with checks proposed |

The core ships the loosest acceptable stops because stop overrides only tighten: a layer adds stops, it never
removes one. Retro always asks before applying anything, whatever the tier.

Autonomy follows verification: a step can run without a stop only where a cheap, trustworthy check covers it.

## 7. Agents and worker levels

`delegate` defines one contract and three ways to run it:

| Level | Runs it | When |
|---|---|---|
| 1 | a named specialist agent (narrow tools, its own model) | a layer names one and it resolves |
| 2 | a generic worker with the step's brief, plus the procedure the specialist would have carried | level 1 missing, or its tools fail to resolve |
| 3 | the current session, inline, following the same contract | no subagents in this harness, or the user asks |

The contract is identical at every level: the same inputs, and a result file in the same shape. Specialist
agents are accelerators, never requirements. Every fallback is logged in `status.md`.

Selection, most specific first: the agent a plan task names → the agent a layer maps to the role → a generic
worker → inline. The agent definition carries *who* (tools, model, domain rules); the step's brief carries
*what* (goal, scope, stopping condition, result file). Model: the agent definition's model stands unless the
tier needs a stronger one.

Review run inline is the author reviewing their own work; it is recorded as "not independent".

## 8. Soft dependencies

| Step | Uses when installed | Built-in fallback |
|---|---|---|
| `spec` | a grilling skill; `superpowers:brainstorming` | grill and write following its own steps |
| `debugging` | `superpowers:systematic-debugging`, `mattpocock-skills:diagnosing-bugs` (two blind diagnoses) | one diagnosis following its own steps; recorded as single-method |
| `plan` | `superpowers:writing-plans` | its own plan format |
| `build` | `superpowers:executing-plans`, `superpowers:subagent-driven-development` | inline with the fixed brief |
| `finalize` | a PR-body skill | its own PR body |
| `retro` | `superpowers:writing-skills` for applying approved skill edits | direct edit with a backup |

`ship` checks at start which of these are present and records it, so a shallower run is visible.

## 9. Contracts

### Task folder

One folder per piece of work, at the location `intake` resolves (an override point). Default:
`.factory/<slug>/` in the working tree, following superpowers' `.superpowers/sdd/` pattern: `.factory/` holds a
self-ignoring `.gitignore` (`*`), so the folder stays out of `git status` without touching any tracked file. It
is not under `.git/`, because Claude Code denies agent writes there. One script resolves the location, so no two
skills can disagree about it. If a worktree is created, the folder moves into it.

| File | Written by | Content |
|---|---|---|
| `status.md` | every step | one line per event (below) |
| `context.md` | intake | summary, related items, prior work; mismatch flags at the top |
| `ticket.md`, `raw/` | intake via `tracker` | ticket summary; untouched tool output |
| `decisions.md` | intake, later steps | decided / rejected / confidence with the named missing piece |
| `tier.md` | tier | tier, signals, rules matched, reasoning, re-tiers |
| `combined.md` or `spec.md`, `spec-questions.md` | understand | root-cause verdict, or spec plus question ledger |
| `plan.md` | plan | the plan; never committed |
| `impl/` | build | brief, red and green logs, `prod.patch`, `status.md` |
| `verify.md`, `gaps.md`, `verify/` | verify | regression map, numbered runs, what is not proven |
| `pr-body.md` | finalize | PR body |
| `retro.md`, `skill-fixes.md` | retro | lessons; proposed edits, agents and checks |

### status.md

```
<step> done|stopped|changed|loop|skipped <YYYY-MM-DD> <file> [<reason>]
```

- The last line decides where a run resumes; progress is never inferred from which files exist.
- `skipped` needs a reason. A loop is `<review|verify> loop <date> <file> →build <reason>`, followed by
  `build done <date> impl/status.md round N ← <step>: <reason>`.
- Fallbacks and loosened rules are logged as their own lines.

### Stops

At a stop `ship` prints the file's absolute path, a 3–5 line summary and one question: **continue / change /
stop here**. "change" re-runs the step (or loops to `build` when it means a code change). The tier decides which
stops are active (section 6).

### Results

Every step and every worker ends with one verdict: `success`, `flawed` (goes back to build), `blocked` (needs a
person) or `manual` (needs a person to check something the factory cannot), plus the evidence it rests on.

## 10. Tracker

`tracker` is an interface with fixed operation names and output files: `read <id>`, `create <type>`,
`post spec`, `post plan comment` (updated in place, never a second one). The core implementation is GitHub
Issues, with a paste fallback. A layer replaces the mechanics for Linear, Jira, Azure DevOps or anything else.
Every write needs the user's yes.

## 11. Harnesses

v0.1 targets Claude Code only. OpenCode and Codex come later, once the contracts have shipped real tickets.
Where the factory uses a harness feature (asking a
structured question, dispatching or monitoring a subagent), the skill names the feature, and a short note per
harness maps it. Without a feature the step degrades to inline or to a plain question.

## 12. Prior art

- [superpowers](https://github.com/obra/superpowers): process skills, prompt templates per role, multi-harness packaging, "user instructions beat skills".
- [mattpocock/skills](https://github.com/mattpocock/skills): chained skills, a setup skill that writes per-repo config, hard vs soft dependencies, retro as the last link.
- [Spec Kit](https://github.com/github/spec-kit): phases plus formal composition (replace, prepend, append, wrap).
- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) and [bmad-loop](https://github.com/bmad-code-org/bmad-loop): tracks scaled by size and risk; a control loop outside the model.
- [GSD Core](https://github.com/open-gsd/gsd-core), [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).
- Anthropic's posts on how the Claude Code team reviews and verifies code: risk tiers decided by the change, "an agent's approval never counts as a person's", review rules read from the base branch.
- Addy Osmani on autonomy levels and software factories: autonomy follows verification.

## Adoption

A repo moves to the factory at its own pace. While a project still has its own end-to-end skill (for example a
`ship-issue`), its project layer decides which orchestrator a request goes to, the old one or `factory:ship`,
and both work side by side until the old one is retired.

## Decisions

| # | Decision | Date |
|---|---|---|
| 1 | Tier confirmation default: confirm T2, announce T0 and T1 | 2026-11-21 |
| 2 | Core stop defaults are the minimum (T0 none, T1 plan, T2 six stops); layers only add stops | 2026-11-21 |
| 3 | Task folder default `.factory/<slug>/` with a self-ignoring `.gitignore`, resolved by one script | 2026-11-21 |
| 4 | v0.1 is Claude Code only; OpenCode and Codex later | 2026-11-21 |
| 5 | Existing end-to-end skills keep working; the project layer routes to old or new | 2026-11-21 |
| 6 | Tier policy: repo default from the layers, a per-user override on top, per-run asks on top of that; lasting changes go to a file after a yes | 2026-11-21 |
| 7 | Tier policy override points: confirmation, minimum tiers, stops per tier (add or remove, removal logged) | 2026-11-21 |
| 8 | `plan` and `review` are thin core skills | 2026-11-21 |
| 9 | Agent routing is declared in the project's `-build` Overrides; `plan` writes the chosen agent onto each task | 2026-11-21 |
| 10 | The author's personal layer lives in its own private repo, prefix `ant` | 2026-11-21 |
| 11 | A user's own override lives in the repo's `CLAUDE.local.md` (one repo) or the user-level instruction file (all repos); the repo-specific one wins | 2026-11-21 |
| 12 | A user override may add confirmations and stops and raise tiers freely; going below the repo's minimum tier or dropping a required stop works for one run only, on request, logged | 2026-11-21 |
| 13 | Build a vertical slice first: contracts, `ship`, `intake`, `tier`, `plan`, `build`, `review`, `verify`, `finalize`, `retro`, `tracker`; then `understand`, `spec`, `debugging`, `qa-tests`, `manual-test`, `delegate`, `setup` | 2026-11-21 |
| 14 | Each skill's override-point defaults are settled when the skill is built, reviewed in its PR | 2026-11-21 |

## Open questions

1. Whether the repo needs a leak check, and when (see principle 8).
