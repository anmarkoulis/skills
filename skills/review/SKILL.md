---
name: review
description: Use as the review step of factory:ship, after build and simplify and before verify, to review the change at the depth the tier sets, agree which findings to fix, and loop the fixes back to build.
---

# review

Thin by design: it picks the reviewer and the depth, and owns the loop. The review itself is done by a review
skill. Writes `review.md` in the task folder. Contracts: [../../contracts/README.md](../../contracts/README.md).

## 1. Depth by tier

| Tier | Review | Independent? |
|---|---|---|
| T0 | local review: this session reads the diff against the base | no |
| T1 | fresh-context review: a subagent that sees only the diff, the ticket and the rules | yes |
| T2 | deep review plus a security review, each in its own fresh context | yes |

Without subagents, a T1 or T2 review runs inline and is recorded as **not independent** in `review.md` and in
`status.md` (`ship … fallback: review inline, not independent`). An agent's approval never counts as a
person's.

## 2. Run it

- **Reviewer:** the **review skill** a layer sets; else Claude Code's built-in `code-review` (and
  `security-review` at T2) when present; else review against this checklist: does it do what `ticket.md` and
  `plan.md` say, are the new tests failing without the change, error handling, security at trust boundaries,
  callers of changed functions, and every line needed.
- **Rules:** the **review rules file** (default `REVIEW.md` at the repo root), read from the base branch
  (`git show <base>:REVIEW.md`), so the change under review cannot edit its own rules.
- Give the reviewer the diff against the base sha from `decisions.md`, `ticket.md`, `plan.md` and the rules.

## 3. Agree and fix

Write `review.md`: reviewer, depth, independent or not, and each finding with severity and `file:line`. Show
the findings with the scope table from [../ship/stops.md](../ship/stops.md); the user keeps or drops each. Dropped
findings go to `decisions.md` with the reason.

- Findings kept that need code: log `review loop <date> review.md →build <findings, in short>`; `ship` sends it
  to build, then review and verify run again.
- No findings kept: log `review stopped <date> review.md awaiting answer` when the tier has a review stop,
  otherwise `review done <date> review.md`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| review skill | built-in `code-review` / `security-review`, else the checklist above | `set` |
| review rules file | `REVIEW.md` at the repo root, read from the base branch | `set` |
| extra reviewers | none | `extend` (for example a domain reviewer agent) |
