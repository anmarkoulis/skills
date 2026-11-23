---
name: sk-intake
description: Extends anmarkoulis:intake for the anmarkoulis/skills repo with its worktree layout and an ADR scope question. Used by anmarkoulis:ship through the sk layer.
---
| Point | This layer |
|---|---|
| task folder location | default |
| workspace command | set: `git fetch origin && git worktree add ../skills-<id> -b <branch> origin/main` (run from the main checkout) |
| branch name | default |
| prior-work sources | default |
| observability sources | default |
| extra scope questions | extend: "Does this need an ADR in `docs/decisions/`?" |
