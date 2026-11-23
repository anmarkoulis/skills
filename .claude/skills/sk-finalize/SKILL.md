---
name: sk-finalize
description: Extends anmarkoulis:finalize for the anmarkoulis/skills repo with its post-merge cleanup. Not for direct use; the core skill applies it through the sk layer.
---
| Point | This layer |
|---|---|
| git workflow | default |
| merge policy | default |
| ticket states | default |
| cleanup commands | set: after the merge, move the task folder to the main checkout's `.factory/` (`git worktree list` first line) so retro can read it, then `git worktree remove <worktree>` and `git branch -D <branch>` (squash merges need `-D`) |
