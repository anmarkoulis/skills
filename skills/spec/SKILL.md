---
name: spec
description: Use as the feature branch of factory:understand, or when a feature, improvement or a bug's missing behaviour must become a written spec with every open question answered before planning, to check the premise, grill, keep a question ledger, write spec.md, get approval and post it.
---

# spec

Turns a request into `spec.md` with every open question answered. Interactive: it runs inline in this session.
Writes `spec.md` and `spec-questions.md` in the task folder. Contracts: [../../contracts/README.md](../../contracts/README.md).
`ft` means `bash <plugin root>/contracts/factory-task`; the plugin root is two directories above this skill's
base directory.

**Inputs:** `ticket.md`, `context.md`, `decisions.md`, the tier; for a bug's missing behaviour also
`combined.md`. Without a ticket, the user's request stands in for `ticket.md`.

## 1. Depth by tier

| Tier | Runs |
|---|---|
| T0 | premise check, then `spec.md` from the request as stated (no grill, no ledger) |
| T1 | premise check; grill and ledger only when no spec exists on the ticket |
| T2 | premise check, full grill and question ledger |

An existing spec (on the ticket or linked from it) is the input: check it against the code and the ledger
rather than starting over.

## 2. Premise check

Read the code the request touches. If it already does what is asked, write that as the first row of
`spec-questions.md` and ask the user before going on.

## 3. Grill

With `mattpocock-skills:grilling` when installed, grounded in the ticket and the code. Otherwise, built in: ask
one question at a time, each with your recommended answer and why, until every decision the spec needs is made.
Facts come from the code and the ticket; only decisions go to the user.

Every question asked or still open is a row in `spec-questions.md`:

| question | answer | who answered |
|---|---|---|

`who answered` is the user, a person named on the ticket, or `code` when the code settled it. An open row has
an empty answer.

## 4. Write

With `superpowers:brainstorming` when installed, fed the grill's result; skip its commit step and save to
`<task folder>/spec.md`, not its default location. Otherwise use this shape:

```markdown
# Spec: <title>
Problem: <who hits what, today>.
Goal: <one sentence>.
Behaviour: <numbered rules, each testable>.
Out of scope: <what was decided against>.
Acceptance: <the checks that prove it, one per rule>.
Open questions: none (see spec-questions.md).
```

The spec stays in the task folder, uncommitted.

## 5. Ledger check

Re-read `spec-questions.md`. While a row has no answer, the spec is not done: list the open rows, get answers,
or an owner with `deferred` as the answer (the user approves each), then update the ledger and the spec.

## 6. Approve and post

Show `spec.md` and ask for approval once every row is answered. On a change, update the spec, log
`ft log <folder> spec changed spec.md <reason>` and go back to step 5. Once approved, `factory:tracker`
`post spec spec.md` and record where it went in `decisions.md`. Log `spec done <date> spec.md`.

The user abandons it or cannot answer a blocking row: log `spec stopped <date> spec-questions.md <reason>`; the
open rows stay in the file.

## Override points

None beyond `factory:tracker`'s: where the spec is posted is the tracker's **mechanics of every operation**.

| Point | Default | Allowed |
|---|---|---|
| none | — | — |
