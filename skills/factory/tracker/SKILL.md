---
name: tracker
description: Use when a factory step needs the issue tracker, to read a ticket with its comments and relations, create a bug, feature, task or improvement, or post a spec or a plan comment. Default implementation is GitHub Issues with a paste fallback.
---

# tracker

The tracker interface. Other steps call these operations by name; the names and output files are fixed. A
layer may `replace` the mechanics (for another tracker) but not the names or outputs. Every write needs the
user's explicit yes, every time; `read` never writes. The caller passes the task folder and logs its own
`status.md` line.

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

## `read <id>`

Writes `ticket.md` and `raw/`.

1. No id or url given: ask for one. Never guess.
2. GitHub remote: `gh issue view <id> --comments --json title,state,body,comments,labels,assignees,url`, saved
   as `raw/issue.json`. Find the parent and siblings from the body (task lists, "Part of #N") and read each into
   `raw/`.
3. Not GitHub, or `gh` fails: ask the user to paste the ticket and its comments; save as `raw/pasted.md`.
4. Write `ticket.md` as a summary: title, state, type or labels, assignee, a description summary, the parent or
   "no parent", related items, and a pointer to `raw/`. Security-sensitive detail stays in `raw/` and out of any
   tracker write. Only `read` of the task's own ticket writes `ticket.md`.

## `title <id>`

Prints the ticket's title and type and writes nothing, for a caller that needs them before the task folder
exists (`intake` names the slug and branch from them). GitHub: `gh issue view <id> --json title,labels`, the
type from the labels. Otherwise ask the user.

## `create <bug|feature|task|improvement> [parent <id>]`

1. Ask for the title and description; for a bug also the reproduction and expected behaviour. Show the draft
   and wait for a yes.
2. GitHub: `gh issue create`, with the matching label when the repo has one (the **type labels** override), and
   `Part of #<parent>` in the body when there is a parent. Otherwise print the draft for the user to file and
   ask for the new id.
3. Save the new item to `raw/<id>.json` (or `.md`) and record its id and url in `decisions.md`; with no task
   folder yet (`intake`), return them and the caller saves them once it exists. Never overwrite `ticket.md`.

## `post spec <file>`

Show the text, wait for a yes, then `gh issue comment <id> --body-file <file>`. Not GitHub: give the user the
text to paste.

## `post plan comment <file>`

As `post spec`, but **updated in place**: the comment starts with the line `<!-- factory:plan -->`. If the
ticket already has a comment starting with it, edit that one
(`gh api -X PATCH repos/{owner}/{repo}/issues/comments/<comment id> -F body=@<file>`). Never post a second plan
comment.

## Rules

- Never put credentials, personal data or customer details in a created issue or comment.
- A layer that replaces the mechanics keeps the operation names, the output files and the yes before each
  write.

## Override points

| Point | Default | Allowed |
|---|---|---|
| mechanics of every operation | GitHub Issues through `gh`, paste fallback | `replace` |
| type labels | the repo's label with the type's name, if it exists | `set` |
