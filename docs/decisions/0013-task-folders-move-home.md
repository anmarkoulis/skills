# 13. Task folders move home through one checked command

Date: 2026-11-24. Status: accepted. Amends [ADR 7](0007-task-folder.md): the folder is born in the worktree.

## Context

The task folder is gitignored ([ADR 7](0007-task-folder.md)), so `git worktree remove` deletes it without a
warning. Only this repo's `sk-finalize` said to move it home first, and nothing checked the move. On 2026-11-23,
`cp -R <worktree>/.factory/<slug>/ .factory/` copied the contents of five folders flat (BSD `cp` and a trailing
slash), same-named files overwrote each other, and the worktree removal then deleted the originals.

Cleanup was also offered at the wrong time. `finalize` offered it after the merge, but a person merges after
`ship` ends, so no step was running then. Worktrees of merged PRs piled up (#67).

## Decision

- `factory-task move <slug> <from root> <to root> [<base>]` is the only way a task folder leaves a worktree. It
  builds the paths from the roots, so a trailing slash cannot flatten anything. It refuses a missing source, a
  source without `status.md` or with an empty one, and an existing target, and checks that `status.md`'s last
  line arrived.
- The main checkout's task folder location is the folder's home after the merge. Folders stay there as the
  record that retros and prior-work searches read.
- `intake` creates the worktree before the task folder, so the folder is born in the worktree and never moves
  in. To name the slug and branch first, it asks `tracker` for the ticket's `title`, which writes nothing.
- `intake` starts its workspace step with a sweep: worktrees with no open PR, whose HEAD is the newest PR's head
  commit, are offered for cleanup in one batch. Each clean one gets `move`, then `git worktree remove`, then `git
  branch -D`. A failed move keeps the worktree, and one with uncommitted changes is reported and left. The sweep is
  an override point (`merged worktree sweep`): a layer can turn it off or replace the PR lookup.
- `finalize`'s default cleanup runs the same three commands after a yes, when the merge happens during the run.
- Branches are deleted with `-D`, because squash-merged branches fail `-d`. The PR state is checked first.

## Consequences

- A cleanup that loses a folder now fails loudly before anything is removed.
- `sk-finalize` drops its own cleanup and uses the core default.
- A layer for another tracker must also implement `tracker title`.
