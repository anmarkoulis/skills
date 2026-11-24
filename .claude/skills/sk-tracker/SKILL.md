---
name: sk-tracker
description: Extends anmarkoulis:tracker for the anmarkoulis/skills repo with GitHub Issues and its labels, over any user layer's tracker. Not for direct use; the core skill applies it through the sk layer.
---
| Point | This layer |
|---|---|
| mechanics of every operation | replace: see "GitHub" |
| type labels | set: bug → `bug`; feature, task, improvement → `enhancement` |

## GitHub

The core default mechanics of `anmarkoulis:tracker`, unchanged: GitHub Issues through `gh` for every operation, with
the paste fallback. Stated here so a user layer's tracker (Linear, Jira) does not apply in this repo
([ADR 14](../../../docs/decisions/0014-user-and-local-layers.md)). There is no `set state`: an issue's state follows
its PR (`Closes #<id>`).
