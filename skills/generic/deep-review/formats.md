# deep-review formats

The report folder holds:

```
<report folder>/
  review.md            # the reasoning, for the reviewer
  comments.md          # draft comments, for the author; never posted
  diff.patch           # the diff reviewed
  schematic-before.md  # code-schematic at base
  schematic-after.md   # code-schematic at head
  notes/               # ticket, PR threads, context dumps, lens-findings.md
```

## review.md

Exactly these sections, in this order:

````markdown
# <PR #N | branch | range>: <title>
Lenses: bugs <ran | fallback>, standards <…>, every line <… | skipped>, security <… | off>.

## What this change does
2–3 paragraphs of prose for someone who knows the product but not the ticket: the context, the problem today
and what it costs, what changes after merge. No ticket ids or owners here; those go in Context.

## Context
| Source | Finding |
|---|---|
| Ticket <id> | … / none found |
| <each context source> | … / no data / not checked |

## Flow
One line naming the entry point and the highlighted node.
Detail: [schematic-before.md](schematic-before.md) · [schematic-after.md](schematic-after.md).
```mermaid
(the after flowchart, changed nodes marked)
```
| Step | Function | Location | Role in the change |
|---|---|---|---|

### Before vs after
| Topic | Before | After | Note |
|---|---|---|---|

## Walkthrough
### <path>
Before: … After: … Mechanism: … Why it matters: …

## Findings
Rubric: deep-review step 5; ≥ 40 kept.

| # | Score | Severity | Comment | Where | What |
|---|---|---|---|---|---|
(ordered by score; `Comment` is the comments.md entry, or `— (<why not>)`)

1. **<severity>, confidence <n>** `file:line`: <what is wrong>. <evidence>. <fix>.
   *Example:* <explain story; one-liner for Low; read or executed>
(or "None.")

### Deliberately not raised
<looks like a defect but is house style, unenforced or pre-existing, with the count or config that shows it>

## Existing threads        (PR targets only)
| Thread | Assessment |

## Verdict
Approve / Approve with nits / Request changes, and the 1–3 things that decide it.

## Appendix: terms
**<term>**: what it is. *Here:* a real value, row or request from this change.
````

## comments.md

Paste-ready for the PR page, read one at a time by an author who knows the code. Compact is the point.

| Piece | Budget |
|---|---|
| inline comment | ≤ 6 prose lines, most 2–4 |
| blocking comment | ≤ 11 lines |
| summary body | ≤ 12 lines |
| header | ≤ 6 lines |
| inline comments | ≤ 12; past that the bar was too low, demote to review.md |

Order by severity band, then by cost to the author; the score only breaks ties.

```markdown
# Draft review comments: <target>

**NOT POSTED.** <N> inline + 1 summary. Verified at head `<sha>`. All anchor to added lines.
Not promoted: F<n> (<why>) · … Skipped: <fixed later> · <settled with the author> · <pre-existing>

---

## Summary (Approve | Approve with nits | Request changes)

> <what is good, naming what was verified>
>
> <the one or two things that decide the verdict>

---

## <n>. [F<k> · <severity> · <score>] `path:line`

> <the problem, 1–2 sentences, in the author's terms>
>
> <one-liner: input → file:line and the deciding value → wrong result>
>
> ```suggestion
> <the complete replacement for the anchored lines>
> ```
```

Rules:

- **Anchor to added lines only.** If the problem is on a context line, anchor to the nearest added line and
  name where it really is. A fix in a file the change does not touch gets a fenced block labelled with that
  path, said to be outside the diff.
- **Problem first, then the proof, then the fix.** Every comment ends with the fix: a `suggestion` block that
  replaces exactly the anchored lines (complete, indented, no ellipses), else a fenced replacement, else one
  concrete sentence. A comment with no fix is an observation and stays in review.md.
- **Colleague, not linter:** first person, no severity words in the quoted text (the `##` tag carries them),
  one point per comment, no meta-narration, ask where it is a judgement call.
- **Bidirectional mapping:** every comment names its finding in the `##` line; every finding names its comment
  or why it has none.
