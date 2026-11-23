---
name: sk-verify
description: Extends anmarkoulis:verify for the anmarkoulis/skills repo with its L1 commands, a headless plugin run as L3, and its shell quirks. Not for direct use; the core skill applies it through the sk layer.
---
| Point | This layer |
|---|---|
| L1 commands | set: `/bin/bash tests/factory-task.test.sh`; bash 5 (CI; locally `docker run --rm -v "$PWD:$PWD" -v <main checkout>/.git:<main checkout>/.git -w "$PWD" bash:5 sh -c 'apk add -q git && git config --global --add safe.directory "*" && bash tests/factory-task.test.sh'`, the second mount only in a worktree); `/bin/bash tests/frontmatter.test.sh` and `/bin/bash tests/layers.test.sh` (after `git add`); shellcheck on `contracts/factory-task tests/*.sh` (docker fallback in AGENTS.md); `claude plugin validate .` |
| L2 command | set: none; this repo has no acceptance suite |
| L3 procedure | set: `claude plugin eval <worktree> --model haiku --runs 1 --ablation none --no-publish --trust-plugin --threshold 0 --scaffold --case '<skill>-*'` for each changed skill, in the two passes `AGENTS.md` gives (behaviour cases add `--allow-tools Bash Write`, #56); for a flow no case covers, from a directory outside the worktree (writes inside a loaded plugin folder are refused, #34 run), `claude --plugin-dir <worktree> -p "<prompt that should use the skill>" --output-format stream-json --verbose --allowedTools "Bash Read Write Glob Grep" > <task folder>/verify/run<N>.jsonl`, then grep `"name":"Skill"` for the expected skill and read its output (#30, #32) |
| outside consumers | default |
| A/B mechanism | default |
| environment quirks | extend: rtk rewrites shell commands, so a headless allowlist needs both forms (#34); zsh does not word-split `FT="bash …"`, use a function `ft() { bash <path> "$@"; }` (#30); run git as `git -C <worktree>`, since the commit hook reads the session's checkout (#18) |
