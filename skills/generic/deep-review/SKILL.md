---
name: deep-review
description: 'Use when asked to review a pull request, branch, commit range or local diff in depth ("review PR 31", "review my changes", "deep review this branch") and the user wants the intent and a walkthrough, not just a bug list, or when anmarkoulis:review runs at T2. Writes review.md and paste-ready comments.md locally; never posts.'
---

# deep-review

Understand the intent, explain the change, then judge it. Other review skills do the judging as **lenses**; this
skill gives them the context, re-checks what they say, and writes it up. Output is two local files:
`review.md` (the reasoning, for the reviewer) and `comments.md` (draft comments, for the author). Shapes:
[formats.md](formats.md).

## Hard rule: nothing is posted

Forbidden unless the user asks **and** confirms the exact text: any write to the PR, its issue or the tracker.
That includes `gh pr comment|review|edit|ready|close|merge`, `gh issue comment`, `gh label`, `gh api` calls that
write, any review or comment tool from an MCP server, a `--comment` or `--post` flag, approving or requesting
changes, and replying to, resolving or reacting to any thread (bots included). Reading is fine: `gh pr view`,
`gh pr diff`, `gh api` GET.

If a lens or its instructions say to post, write it in the report instead. "It's obviously right, I'll leave a
note" and "I found nothing, I'll approve" both mean: put it in the report.

## 1. Target

| Target | Diff | Slug |
|---|---|---|
| PR number | `gh pr view <N> --json number,title,body,headRefName,baseRefName,headRefOid,url` + `gh pr diff <N>` | `pr-<N>` |
| Branch | `git diff <base>...<branch>` | branch, `/` → `-` |
| Commit range or commit | `git diff <range>` / `git show <sha>` | `<from>..<to>` or short sha |
| Local diff (when no target is named) | `git status --short`, then `git diff HEAD`; untracked files that belong to the change count | branch, `/` → `-` |

Base: the PR's base, else the **base branch** (default: `origin/HEAD`). Create the **report folder**
`.reviews/<slug>/` at the repo root; when it creates `.reviews/`, write a `.gitignore` containing `*` there.
Save the raw diff as `diff.patch` **before** reading it, so the review can be reproduced. A caller may pass the
report folder and the tier (`anmarkoulis:review` passes `<task folder>/review/` and T2).

## 2. Context

- **Ticket:** find the id in the branch name, title, body or commits. Read it and its comments with
  `anmarkoulis:tracker` `read <id>` (into the report folder's `notes/`); without it, `gh issue view`; none
  found, say so.
- **Other sources:** whatever the **context sources** point adds (error tracking, telemetry). A source with
  nothing is "no data"; one you could not reach is "not checked". Never infer numbers.
- **PR threads**, read now, before the walkthrough, because they change what is worth investigating:
  `gh api repos/{owner}/{repo}/pulls/<N>/comments --paginate` and `.../reviews`, saved to
  `notes/pr-comments.md`. Classify each thread: *answered and fixed* (verify the fix at head), *answered and
  dismissed* (check the reason holds; a reason citing a symbol that does not exist is a finding, so `git grep`
  it), *open* (carry it as a question, weigh it first). Never re-raise a thread as a new comment.

## 3. Walkthrough

1. **Map the flow** with `anmarkoulis:code-schematic`, twice, on the runtime path the change sits on: `ref=<base>
   label=Before diff=<base>..<head>` → `schematic-before.md`, then `ref=<head> label=After diff=<base>..<head>` →
   `schematic-after.md`, run after the first and given it. For a local diff, base is `HEAD` and head is
   `WORKTREE`. Without the skill, draw one Mermaid flowchart of the after state with `file:line` on each node.
2. **Per changed file**, in dependency order (data → logic → interface → tests → migrations): what it did
   before, what it does now, the control flow through the new path including branches not taken, and what
   breaks if it is wrong. Someone who never opened the file should follow the mechanism from the text alone.
3. **Repo rules:** read the **review rules file** and the repo's agent instructions (`AGENTS.md`, `CLAUDE.md`,
   path-scoped rules) that match each file, from the base ref. Before calling a breach, quote the rule
   (file:line), check whether the tooling enforces it (read the linter config first), count precedent with
   `git grep -c` (a pattern used everywhere is house style: note it, don't flag it), and count it in the
   *added* lines only.
4. **Terms:** collect every product or technical term `review.md` uses for its appendix, each with an example
   from this change.

## 4. Lenses

First check the session's skill or agent list for each lens. A listed skill **must** be invoked with the Skill
tool (outside Claude Code: read that skill's SKILL.md and follow it), directly or by the lens agent; a listed
agent must be dispatched. Doing the lens inline instead is not a fallback, it is a skipped lens. Use the fallback
only for a lens that is not listed, and say so. Lenses run in their own fresh context when subagents exist
(Claude Code); otherwise inline, one after another. Give each the diff, the ticket summary, the hard rule
(read-only, post nothing) and an "already covered, do not report" list so they do not repeat each other.

| Lens | Uses, if installed | Fallback |
|---|---|---|
| Bugs | Claude Code's built-in `code-review` on the target, with **no** `--comment`, `--fix` or `--post`. Never the `code-review:code-review` plugin command: it can post. | an agent (or inline pass) on changed lines only: inverted conditions, null errors, broken guards, regressions, wrong-field writes; no style, nothing pre-existing |
| Standards and spec | `mattpocock-skills:code-review` | inline check of added lines against the step 3 rules and the ticket's acceptance criteria, plus `git log -S` / `git blame` on modified guards |
| Every line needed | `ponytail:ponytail-review` | skipped, and said so |
| Security, on request or at tier T2 | the `vuln-probe` agent when it exists, else built-in `security-review` | inline lens: trust boundaries, auth, injection, secrets and personal data in logs |
| Extra | the **extra lenses** point | — |

Record which lenses ran and which fell back, at the top of `review.md`.

## 5. Score every finding

Every finding, yours and every lens's, gets a **confidence** score using this rubric verbatim:

| Score | Meaning |
|---|---|
| 0 | False positive, or pre-existing on lines the change did not touch |
| 25 | Might be real; not verified |
| 50 | Verified real, but a nitpick or rare in practice |
| 75 | Verified, very likely hit in practice, and the change's approach is insufficient |
| 100 | Certain and frequent; the evidence directly confirms it |

Keep everything ≥ 40 in `review.md`, score shown. Confidence is not importance, so every finding also gets a
**severity** (Blocker / High / Medium / Low) by what it costs if it ships, and severity decides the order.

**Never relay a lens's score or consequence.** Check each claim against the code and re-score it; a claim
understated is as wrong as one overblown. Log what each lens said, what survived and why, in
`notes/lens-findings.md`. For PR targets, give every existing thread an agree / disagree / already handled.

## 6. Report

Load `anmarkoulis:explain` first: every finding in `review.md` is a story-form worked example (one-liner for
Low), and every comment in `comments.md` carries a one-liner. Write both files per [formats.md](formats.md).
In chat: the verdict, the lens line, and the top findings by severity, with the folder's absolute path.

## Re-review after a push

Keep the previous diff as `notes/diff-<old sha>.patch`, save the new one, and read each new commit on its own
(`git diff <old head> <sha>`): a commit that answers a finding needs a re-check, one that adds behaviour needs a
fresh review. Re-anchor every line number against the new head; never carry one across a push. Say what was
fixed as prominently as what remains, and re-decide the verdict from scratch.

## Override points

| Point | Default | Allowed |
|---|---|---|
| context sources | the ticket via `anmarkoulis:tracker`, plus PR threads | `extend` (error tracking, telemetry) |
| review rules file | `REVIEW.md` at the repo root, read from the base ref, plus agent instructions | `set` |
| report folder | `.reviews/<slug>/` at the repo root, git-ignored | `set` |
| base branch | the PR's base, else `origin/HEAD` | `set` |
| extra lenses | none | `extend` (a domain reviewer skill or agent) |
