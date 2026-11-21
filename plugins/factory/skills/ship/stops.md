# Stops per tier

Core defaults. A layer may add or remove stops per tier (`ship`'s **stops per tier** override point); a removal
carries a reason, logged as `ship … loosened:`. The user can also ask for one in the current run ("also stop at
verify"); `ship` applies it at once and `tier.md` records it.

| Stop | After | File shown | T0 | T1 | T2 | "change" means |
|---|---|---|---|---|---|---|
| intake | intake | `decisions.md` | – | – | on | edit files, `intake changed`, re-run intake |
| understand | understand | `combined.md` or `spec.md` | – | – | on | `understand changed`, re-run understand |
| plan | plan | `plan.md` (with the execution method) | – | on | on | revise, `plan changed`, stop again |
| review | review | the review output | – | – | on | loop to build, then review and verify again |
| verify | verify | `verify.md` and `gaps.md` | – | – | on | loop to build, then review and verify again |
| PR | finalize | `pr-body.md` and the PR url | – | – | on | edit body or commits, `finalize changed`, stop again |

Retro always asks before applying anything, at every tier. Tier confirmation itself belongs to `tier`.

## Scope table (plan and review stops)

Before asking, show one row per proposed change; the user keeps or drops each row.

| Change | Required by | Smallest diff that closes it | User-visible effect | Optional hardening (priced in lines) | Keep/drop |
|---|---|---|---|---|---|

Lead with the smallest change that closes the finding. Hardening is listed and priced, never included by
default. Dropped rows go into `decisions.md` with the reason.
