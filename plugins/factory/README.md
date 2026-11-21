# factory

A ticket-to-PR pipeline built as one orchestrator plus step skills. Decisions: [../../docs/decisions/](../../docs/decisions).

v0.1 vertical slice: `ship`, `intake`, `tier`, `plan`, `build`, `review`, `verify`, `finalize`, `retro`
and `tracker` are written; the rest are planned. Shared rules: [contracts/](contracts).

```
/plugin install factory@anmarkoulis-skills
```

Skills:

| Skill | Role |
|---|---|
| `ship` | Orchestrator: order, stops per tier, `status.md`, resume, loops |
| `tier` | Risk tier T0/T1/T2 after intake; re-tier after understand |
| `intake` | Which ticket, prior work, mismatch flags, workspace, scope questions |
| `understand` | Routes by type: bug → `debugging`, feature or improvement → `spec` |
| `debugging` | Root cause: one diagnosis, or two blind ones reconciled at T2 |
| `spec` | Grill, question ledger, write, approve, post |
| `plan` | Writes `plan.md` in the task folder and posts it through `tracker` |
| `build` | Execution method, fixed implementer brief, lead re-verification |
| `review` | Code review at the tier's depth, fixes, re-verify |
| `verify` | Regression map, levels L1–L4, numbered runs, gaps |
| `qa-tests` | L2: the repo's acceptance or e2e suite |
| `manual-test` | L3: drive the running app, one script per flow |
| `finalize` | Commit, push, PR, ticket update, CI loop, merge policy, cleanup |
| `retro` | Lessons, proposed skill edits, agents and checks; applies only what you approve |
| `tracker` | Tracker interface; default implementation is GitHub Issues |
| `delegate` | Worker levels: specialist agent, generic worker, inline |
| `setup` | Declares a repo's layers and scaffolds variant skills |
