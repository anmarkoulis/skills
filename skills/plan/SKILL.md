---
name: plan
description: Use as the plan step of factory:ship, once the work is understood, to write plan.md in the task folder (tasks, tests first, verification, agent per task) and post it to the ticket. Not for writing a design or spec; that is understand.
---

# plan

Thin by design: it turns what intake and understand settled into an ordered task list. Writes `plan.md` in the
task folder. The plan is temporary and never committed; decisions live in `decisions.md` and the ticket.
Contracts: [../../contracts/README.md](../../contracts/README.md).

**Inputs:** `ticket.md`, `decisions.md`, `tier.md`, and `combined.md` or `spec.md` if present.

## 1. Write the plan

With `superpowers:writing-plans` when it is installed (save its output as `<task folder>/plan.md`, not where it
would save by default). Otherwise use this shape:

```markdown
# Plan: <ticket title>
Goal: <one sentence>. Base: <base sha>. Branch: <branch>.
## Task 1: <name>
Files: <paths>. Agent: <name, or generic>.
Test first: <the failing test and the command that runs it>.
Change: <what to change, smallest diff>.
Done when: <command> passes.
## Verification
<the commands verify will run, by level>
## Out of scope
<what was decided against, from decisions.md>
```

- One task per independently testable change, in order. Every task names its failing test first.
- **Agent per task:** use the agent routing from `factory:delegate`'s overrides for the files or role;
  else `generic`.
- Recommend an execution method for `build` (inline, subagents, one background agent) from the tier and the
  plan's size, with one line of reasoning.

## 2. Check the assumptions

Every assumption about an external library or API (a function exists, a flag behaves a certain way) is checked
against its docs or the pinned source before the plan is shown. Record each as `checked: <where>` in the task, or
remove the task's dependency on it.

## 3. Post it

Ask before posting. Then `factory:tracker` `post plan comment` with `plan.md` (it updates an existing plan
comment in place). No ticket id, or the **plan destination** is `none`: skip and say so.

## Done

Log `plan stopped <date> plan.md awaiting answer`. `ship` shows the plan stop (with the execution method and the
scope table from [../ship/stops.md](../ship/stops.md)) when the tier has it, otherwise logs `plan done`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| plan destination | the ticket, through `factory:tracker` | `set` (`none` allowed) |
| plan sections | the shape above | `extend` |
