# 4. Risk tiers and tier policy

Date: 2026-11-21. Status: accepted.

## Context

A one-line typo fix and a schema migration should not get the same stops, review depth or verification. The
depth has to be decided once, visibly, and be changeable by the people who own the repo.

## Decision

- `tier` runs after intake, and again after understand when the work changed shape. It proposes T0 (trivial),
  T1 (standard) or T2 (risky) with one line of reasoning, from these signals: reversibility, sensitive areas
  (from the layers), ambiguity, whether a cheap trustworthy check exists, and size.
- The tier decides which stops run, how deep each step goes and where a person must approve.
- Confirmation default: the user confirms T2; T0 and T1 are announced and the user can interrupt.
- Core stop defaults: T0 none, T1 plan, T2 intake, understand, plan, review, verify and PR.
- Tier policy has three override points: which tiers need confirmation, minimum tiers per path or change type,
  and stops per tier. A layer may add or remove stops; a removal carries a reason logged in `status.md`.
- Who sets tier policy, lowest to highest: the core defaults; the declared layers (the **repo default**,
  committed, normally declared from `AGENTS.md`); **the current run** (the user just asks, for example "treat
  this as T2"; `tier.md` records it as set by the user and `ship` applies it at once).
- Personal preferences are out of scope: the factory doesn't define, store or police them. A user's own
  instructions apply through normal instruction precedence.
- A lasting change ("always confirm the tier here") becomes a proposed edit to the repo's layer files, shown as
  a diff and written only after a yes. A rule never lives only in chat or memory.
- Autonomy follows verification: a step runs without a stop only where a cheap, trustworthy check covers it.
- Retro always asks before applying anything, whatever the tier.

## Consequences

- One file, `tier.md`, explains why a run was shallow or deep.
- Repos tighten their own policy in committed files, where review sees it.
