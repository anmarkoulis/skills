---
name: tier
description: Use as the second step of factory:ship, and again after understand when the work changed shape, to set the risk tier (T0 trivial, T1 standard, T2 risky) that decides the run's stops and depth. Also when the user says "treat this as T2" or asks why a run is shallow or deep.
---

# tier

Proposes one risk tier with one line of reasoning and writes `tier.md`. The tier decides which stops run
(`ship`'s stops table), how deep each step goes (below) and where a person must approve. Contracts:
[../../contracts/README.md](../../contracts/README.md).

## 1. Read the signals

From `ticket.md`, `context.md`, `decisions.md` (and on a re-tier `combined.md` or `spec.md`):

| Signal | Question |
|---|---|
| reversibility | Two-way door (revert the PR and it is gone) or one-way (data migration, public API, sent email)? |
| sensitive areas | Does it touch a path or change type in the **sensitive areas** a layer lists? |
| ambiguity | Is the cause or the design known, or still open? |
| verification | Does a cheap, trustworthy check cover it (a test that fails without the change)? |
| size | Files and lines likely touched; one component or several? |

## 2. Apply the rules

Start from the signals: T0 when it is two-way, small, unambiguous and covered by a cheap check; T2 when it is
one-way, or touches a sensitive area, or the cause is unknown with no cheap check; T1 otherwise. Then raise it to
any **minimum tier** a layer sets for the paths or change types involved ("anything under `migrations/` is at
least T2"). Rules only raise a tier.

## 3. Write `tier.md`

```markdown
# Tier: T1
Reasoning: two-way change in one module, but the retry path has no test yet.
Signals: reversibility two-way; sensitive none; ambiguity known cause; verification partial; size ~40 lines, 2 files
Rules matched: none
Set by: factory:tier, 2026-11-21
## Re-tiers
```

On a re-tier, add a line under `## Re-tiers` (`2026-11-22 T1 → T2: root cause is in the shared auth client`)
and update the heading.

## 4. Confirm or announce

By the **confirmation** policy (default: confirm T2, announce T0 and T1): to confirm, ask "T2 because
<reason>. Continue at T2?" and wait; to announce, say the tier and reason in one line and continue unless the user
interrupts. Log `tier done <date> tier.md`.

## Per-run asks and lasting changes

- **The current run:** when the user says "treat this as T2", "also stop at verify" or "skip the review stop",
  record it in `tier.md` as `Set by: user, <date>: <what they said>` and tell `ship` to apply it at once.
  Removing a stop is a loosening: `ship` logs it with the user's reason.
- **A lasting change** ("always confirm the tier here", "migrations are T2"): propose the edit to the repo's
  layer file that holds the rule, shown as a diff, and write it only after a yes. Never keep a rule only in chat
  or memory.
- Personal preferences are out of scope: a user's own instructions apply through normal instruction precedence.

## What the tier controls

| Controls | T0 trivial | T1 standard | T2 risky |
|---|---|---|---|
| Stops ([stops.md](../ship/stops.md)) | none | plan | intake, understand, plan, review, verify, PR |
| `debugging` | one diagnosis | one diagnosis | two blind diagnoses, reconciled |
| `spec` | premise check | grill when no spec exists | full grill and question ledger |
| `build` method (recommended) | inline | by plan size | subagents per task, specialist agents |
| `review` | local review | fresh-context review | deep review plus security review |
| `verify` | L1 | L1–L2 | L1–L3, base-vs-fix A/B, outside consumers |
| simplify inventory | skipped | yes | yes |
| `finalize` merge | merge policy | merge policy | a person merges |
| `retro` | only on friction | short | full, with checks proposed |

## Override points

| Point | Default | Allowed |
|---|---|---|
| confirmation | confirm T2; announce T0 and T1 | `set` |
| sensitive areas | none | `extend` |
| minimum tier per path or change type | none | `extend` (raise only) |
