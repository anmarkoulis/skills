---
name: intake
description: Use as the first step of anmarkoulis:ship, or on its own when starting a bug, feature or improvement, to pin down which ticket it is, gather prior work, flag mismatches between the request and the ticket, set up the workspace and settle scope before any diagnosis or code.
---

# intake

Know what the work is before touching it. Creates the task folder, writes no code, ends at the intake stop.
Contracts (task folder, `status.md`, stops): [../../../contracts/README.md](../../../contracts/README.md). `ft` means
`bash <plugin root>/contracts/factory-task`; the plugin root is three directories above this skill's base
directory.

## 1. Which ticket

Ask both questions, every time, even when the prompt names an id. Never assume either answer:

- Which ticket is this?
- Do you want a new one created?

Both can be yes (a task under an existing bug). Then:

- **Existing:** `anmarkoulis:tracker` `read <id>` (it writes `ticket.md` and `raw/`). Also read its comments, parent
  and siblings.
- **Create:** ask the type (bug, feature, task, improvement), then `anmarkoulis:tracker` `create <type>`.
- **No tracker, or the user declines:** the user's words are the ticket. Save them as `ticket.md`, no id.

As soon as the ticket is known, create the task folder: `ft path <slug> [<task folder location>]`, with the
slug from the id and title (`42-fix-login`), else from the request. Reuse it if it exists. Pass the printed
absolute path to every later write.

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

- If the current branch has a PR (`gh pr list --head <branch> --state all`), report its state. A merged or closed
  PR means the branch is stale: start from the base branch.
- Ask **worktree or inline**. Never pick for the user.
- **Worktree:** the **workspace command** a layer sets, else `git worktree add <path> -b <branch> <base>`. Then
  move the task folder: `ft -C <worktree> path <slug> [<location>]`, move the contents there, remove the old
  folder, and log `intake done <date> decisions.md moved task folder to <new path>`. The worktree holds it from
  then on.
- **Inline:** check for uncommitted tracked changes first. Tracked changes, or a checkout on another ticket's
  branch: stop and ask; never switch silently. Then create or switch the branch in place.
- Branch name: `<type>/<id>-<slug>` (`fix/42-login-timeout`), or `<type>/<slug>` without an id.

## 6. Scope questions, one batch

Ask until you are about 95% sure what "done" looks like, in a single round: base branch (suggest the default
branch from `origin/HEAD`), what is in, what is out, constraints, plus the **extra scope questions** a layer adds.
Pick obvious conventional defaults yourself and say so. Then write `decisions.md`:

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
| branch name | `<type>/<id>-<slug>` | `set` |
| prior-work sources | repo search, earlier task folders, `git log` | `extend` |
| observability sources | none; ask the user to paste | `extend` |
| extra scope questions | none | `extend` |
