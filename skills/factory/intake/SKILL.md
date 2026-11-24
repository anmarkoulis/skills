---
name: intake
description: Use as the first step of anmarkoulis:ship, or on its own when starting a bug, feature or improvement, to pin down which ticket it is, gather prior work, flag mismatches between the request and the ticket, set up the workspace and settle scope before any diagnosis or code.
---

# intake

Know what the work is before touching it. Creates the task folder, writes no code, ends at the intake stop.
Contracts (task folder, `status.md`, stops): [../../../contracts/README.md](../../../contracts/README.md). `ft` means
`bash <plugin root>/contracts/factory-task`; the plugin root is three directories above this skill's base
directory.

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

## 1. Which ticket, and where

Ask in one batch, every time, even when the prompt names an id. Never assume an answer or pick for the user:

- Which ticket is this?
- Do you want a new one created?
- Worktree or inline?
- Which base branch? Suggest the default branch from `origin/HEAD`.

Both ticket questions can be yes (a task under an existing bug). Get the title and type first, writing nothing:

- **Existing:** `anmarkoulis:tracker` `title <id>`.
- **Create:** ask the type (bug, feature, task, improvement), then `anmarkoulis:tracker` `create <type>`; it
  returns the new id and url.
- **No tracker, or the user declines:** the user's words are the ticket, no id.

Then set up the workspace (section 5) and create the task folder where it will live:
`ft [-C <worktree>] path <slug> [<task folder location>]`, with the slug from the id and title
(`42-fix-login`), else from the request. With a worktree the folder is born there and never moves in. Reuse it
if it exists. Pass the printed absolute path to every later write, starting with the ticket: `tracker`
`read <id>` (it writes `ticket.md` and `raw/`; also read its comments, parent and siblings), or for a created
one save it to `raw/<id>.json` and its id and url to `decisions.md`, or the user's words as `ticket.md`.

## 2. Prior work

Search the repo for the code and the ticket touched: earlier task folders, notes, `git log` for the paths and the
ticket id, and any **prior-work sources** a layer adds. Record hits with `file:line` or commit sha in
`context.md`. Nothing found: say so in one line. A source you could not search is "not checked".

## 3. Observability, only when the ticket points at it

Only when the ticket cites errors, logs or a monitoring link: pull those once into `raw/` through the
**observability sources** a layer names; without one, ask the user to paste them. Never query live systems
otherwise. An unreachable source is "not checked", never "0".

## 4. Mismatch check

Compare what the user asked for with the ticket: type, symptom, component, scope. Put every difference as a flag
at the top of `context.md` ("request said X; ticket says Y"). The ticket wins for now; ask about each flag in the
scope batch and repeat it at the stop.

## 5. Workspace

- **Merged worktree sweep** (the override point), before anything else here. When `gh` is missing or fails, say the
  sweep was not checked and skip it. From `git worktree list --porcelain`, skip the main checkout (the first entry)
  and the current one. A worktree qualifies only when no PR for its branch is open and its HEAD (`git -C <worktree>
  rev-parse HEAD`) equals the newest PR's head commit (`gh pr list --state all --head <branch> --json
  state,headRefOid`, newest first). Flag the rest (an open PR, commits after the PR, no PR) and those with
  uncommitted changes (`git -C <worktree> status --porcelain`). None qualifies: say so in one line. Otherwise show
  the list and ask one yes for it; the user may drop rows. For each clean row: `ft move <slug> <worktree> <main
  checkout> [<location>]` for every task folder under its `<location>/`, and only when every move succeeded, `git
  worktree remove <worktree>` and `git branch -D <branch>` (squash merges need `-D`; the PR state was checked). A
  failed move keeps that worktree and branch; report it. A flagged row is reported and left.
- If the current branch has a PR (`gh pr list --head <branch> --state all`), report its state. A merged or closed
  PR means the branch is stale: start from the base branch. Commits on it that still matter are cherry-picked onto
  the new branch, never pushed to the stale one.
- **Worktree:** the **workspace command** a layer sets, else `git worktree add <path> -b <branch> <base>`. The
  task folder is then created inside it (section 1).
- **Inline:** check for uncommitted tracked changes first. Tracked changes, or a checkout on another ticket's
  branch: stop and ask; never switch silently. Then create or switch the branch in place.
- Branch name: `<type>/<id>-<slug>` (`fix/42-login-timeout`), or `<type>/<slug>` without an id.

## 6. Scope questions, one batch

Ask until you are about 95% sure what "done" looks like, in a single round: what is in, what is out,
constraints, plus the **extra scope questions** a layer adds. Pick obvious conventional defaults yourself and say
so. Then write `decisions.md`:

- **Decided:** one line each, including worktree or inline, path, branch and base.
- **Rejected:** each alternative and why.
- **Confidence:** a percentage and the named missing piece. A bare percentage is not acceptable.

## Stop

Log `intake stopped <date> decisions.md awaiting answer` and summarise in a few lines: ticket, flags,
workspace, confidence. `ship` decides from the tier whether to wait for an answer here. On "change", edit the
files, log `intake changed`, and stop again.

## Do not

- Skip a question because the answer seems obvious.
- Start diagnosing or designing; that is `understand`.
- Touch live environments unless the ticket calls for it.

## Override points

| Point | Default | Allowed |
|---|---|---|
| task folder location | `.factory` (repo-relative base passed to `ft path`) | `set` |
| workspace command | `git worktree add <path> -b <branch> <base>` | `set` |
| merged worktree sweep | on; PR state and head commit from `gh pr list --state all --head <branch>` | `set` (`off`), `replace` (the PR lookup) |
| branch name | `<type>/<id>-<slug>` | `set` |
| prior-work sources | repo search, earlier task folders, `git log` | `extend` |
| observability sources | none; ask the user to paste | `extend` |
| extra scope questions | none | `extend` |
