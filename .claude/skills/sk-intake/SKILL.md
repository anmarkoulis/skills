---
name: sk-intake
description: Extends anmarkoulis:intake for the anmarkoulis/skills repo with its worktree layout, branch name and an ADR scope question. Not for direct use; the core skill applies it through the sk layer.
---
| Point | This layer |
|---|---|
| task folder location | default |
| workspace command | set: `git fetch origin && git worktree add ../skills-<id> -b <branch> origin/main` (run from the main checkout) |
| merged worktree sweep | default |
| branch name | set: `<type>/<id>-<slug>` (the core default, stated so a user layer cannot override it here; GitHub issue ids) |
| prior-work sources | default |
| observability sources | default |
| extra scope questions | extend: "Does this need an ADR in `docs/decisions/`?" |
