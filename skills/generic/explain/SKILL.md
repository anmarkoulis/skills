---
name: explain
description: 'Use when asked to explain code, a flow, a concept, a finding, a bug or a condition ("explain how X works", "walk me through it", "is this real?"), or to write a review finding, PR comment or commit message about one. Every answer is a worked example traced through the real lines.'
---

# explain

Every explanation is a **worked example**: one concrete scenario, with named actors and real values, traced
through the real lines to the outcome. The reader can follow it and check every step against the code.

## 1. Read first

Open every file the answer will cite, and run the code when it's cheap. Each claim rests on a line you read in this
session. A `file:line` you have not opened stays out of the answer.

## 2. Answer first

Open with one or two sentences: what it is and why it exists. For "is this real?", open with **yes** or **no**
and the reason.

## 3. Pick the form

**Story form** for a conversation, a report or a ticket:

1. **Cast and setup**: who and what is involved, with real values (`user u-17, cart total 120.00, coupon SAVE20`).
2. **Steps**: about 6 at most. Each one cites `file:line` and the value that decides it.
3. **The flip**: the step where the outcome is decided, in bold.
4. **Contrast table**: when two paths exist (before and after, base and fix), one row per step that differs.
5. **Consequence**: what the user, data or system ends up with.
6. **Status**: whether you read it or ran it, whether it is introduced or pre-existing, and the cheapest way to confirm it.

Example, for "is it a real bug that SAVE20 gives no discount over 100?":

> Yes: the coupon is applied, then cleared by a cap check that tests the wrong variable.
> Cast: cart total 120.00, coupon SAVE20 (20%).
> 1. `cart/discount.py:31` computes `discount = 24.00`.
> 2. **`cart/discount.py:38` checks `if total > 100: discount = 0`, meant as `discount > 100`, so the discount is cleared.**
> 3. `cart/checkout.py:12` charges `120.00`.
>
> | Step | Base | Fix (`discount > 100`) |
> |---|---|---|
> | line 38 | `discount = 0` | `discount = 24.00` |
> | charged | 120.00 | 96.00 |
>
> Consequence: every cart over 100 pays full price. Status: read, not run. It is pre-existing since the cap was
> added. Cheapest check: one test with total 120.

**One-liner form** for a PR comment or a commit message:

```text
<input with real values> → <file:line and the deciding value> → <wrong result>
total 120.00 + SAVE20 → cart/discount.py:38 `total > 100` zeroes the discount → charged 120.00, expected 96.00
```

## 4. A flow across several files

Draw the path with `anmarkoulis:code-schematic` when it is installed, and keep the story's steps on the same
`file:line` points. Without it, draw a small Mermaid diagram: one node per step, labelled with `file:line`.

## 5. Close with what you did not read

End with one line naming the files, branches or runtime paths the answer did not cover, so the reader knows where
the trace stops.
