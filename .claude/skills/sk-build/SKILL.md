---
name: sk-build
description: Extends anmarkoulis:build for the anmarkoulis/skills repo with its test and lint commands and REVIEW.md as extra brief rules. Used by anmarkoulis:ship through the sk layer.
---
| Point | This layer |
|---|---|
| test command | set: `/bin/bash tests/factory-task.test.sh && /bin/bash tests/frontmatter.test.sh` (AGENTS.md, test.yml); a new SKILL.md is scanned only once staged |
| lint command | set: `shellcheck contracts/factory-task tests/*.sh`, else `docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:stable contracts/factory-task tests/*.sh` (AGENTS.md); `claude plugin validate .` when `.claude-plugin/` changed |
| extra brief rules | extend: "Follow `REVIEW.md` at the repo root for every path you touch." |
