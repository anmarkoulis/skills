---
name: delegate
description: Use when a factory step hands work to a worker (build's implementers and reviewers, review's reviewer, debugging's diagnosers, verify's QA and manual runs) to pick who runs it (specialist agent, generic worker or inline), give it the same brief and result-file contract at every level, and log every fallback. Use as the worker picker of anmarkoulis:ship's steps.
---

# delegate

A worker does the work; the caller keeps the conclusion. The worker's raw output stays in a file, out of the
caller's context. Contracts (task folder, `status.md`, verdicts): [../../../contracts/README.md](../../../contracts/README.md).
`ft` means `bash <plugin root>/contracts/factory-task`; the plugin root is three directories above this skill's
base directory. Decision: [ADR 5](../../../docs/decisions/0005-agents-and-worker-levels.md).

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

**Inputs from the caller:** the role (`implementer`, `reviewer`, `diagnoser`, `qa-runner`, `manual-tester`),
the brief, the result file path inside the caller's task folder, and the plan task's agent if it names one.

## 1. Pick the level

Three ways to run the same work:

| Level | Runs it | Available |
|---|---|---|
| 1 | a named specialist agent: narrow tools, its own model | where the agent exists and its tools resolve |
| 2 | a generic worker, given the brief plus the procedure the specialist carried | where subagents exist |
| 3 | this session, inline, under the same contract | everywhere |

The **model per role** a layer sets is passed with the dispatch at levels 1 and 2; inline, it does not apply
(say so in one line). Selection, most specific first: the agent the plan task names, then the **agent routing** for the role or the
touched paths, then a generic worker, then inline. Subagents are a Claude Code feature (the Agent tool); without
them, run inline.

Default routing, from this plugin's `agents/` (level 1 when they resolve):

| Role | Agent |
|---|---|
| implementer | none: generic worker |
| reviewer | `anmarkoulis:task-reviewer` |
| diagnoser | `anmarkoulis:bug-diagnoser` |
| qa-runner | `anmarkoulis:qa-runner` |
| manual-tester | `anmarkoulis:manual-tester` |

A specialist is an accelerator, never a requirement. Drop to the next level when either happens:

1. The agent is not in the available agent types (deleted, renamed, or a repo without it).
2. The dispatch is refused because its tools do not resolve (for example an agent whose `tools:` names MCP tools
   while the session defers them).

Dropping to level 2 means adding the procedure the specialist carried to the brief; a brief that names only the
tools fails the same way. Log every fallback: `ft log <folder> ship done status.md fallback: <role> <from> → <to>`.
Never tell the caller the work cannot be done because an agent is missing.

## 2. Offer the choice; do not block

When the work is large enough that its raw output would crowd the session, say so in one line and offer a worker
or inline. With no one to answer, or no subagents, run inline and say so in one line. A step that waits for an
answer nobody can give is broken.

## 3. The brief

The caller's brief, plus:

1. The task in one or two sentences.
2. The exact values: ids, paths, shas, the task folder, and the layer overrides the work depends on. A worker
   has none of the caller's context.
3. Where to write: the result file path in the caller's task folder.
4. What to return (below).
5. Its tool budget: the narrowest set that does the job. A worker that only reads needs no `Edit`.

## 4. The result

The worker writes the result file, then returns four lines at most:

```
<path to the result file>
<verdict: success | flawed | blocked | manual>: <one line of what it found>
<concerns, at most two lines>
```

- **The file is always written**, however small the answer. "Nothing found" is a finding and gets a file, with
  the command that produced it.
- **Unless the path cannot be written** (sandbox, read-only checkout, denied `Write`). Then the first line says
  the path was unwritable and why, and the report follows inline with the command behind every claim. Never route
  around a denial.
- The verdict is one of the contract's four, with its evidence.

## 5. Check what came back

The contract fixes the shape of a wrong answer, not its completeness. A well-formed file can silently omit a
result. Where completeness matters, cross-check the file against something known before dispatching: a count, a
list of ids, an item known to be there. Well-formed is not verified.

## Override points

| Point | Default | Allowed |
|---|---|---|
| agent routing | the default routing above | `set` (role or path → agent; roles: implementer, reviewer, diagnoser, qa-runner, manual-tester) |
| model per role | the agent's own model; a generic worker inherits the session's | `set` (role → model) |
