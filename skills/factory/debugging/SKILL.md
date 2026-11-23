---
name: debugging
description: 'Use before investigating any bug report ("debug", "diagnose", "find the root cause", "why does X come out wrong"), and as the bug branch of anmarkoulis:understand. Load it first, then read the code; it finds the root cause with one diagnosis, or two blind ones reconciled, in combined.md. Diagnosis only; it never fixes.'
---

# debugging

Finds the root cause and writes `combined.md` in the task folder. Diagnosis only: no edits to tracked files, no
branches, no commits, no tracker writes. Contracts (task folder, `status.md`, verdicts, evidence rules):
[../../../contracts/README.md](../../../contracts/README.md). `ft` means `bash <plugin root>/contracts/factory-task`;
the plugin root is three directories above this skill's base directory.

**Layers:** resolve them first ([resolving layers](../../../contracts/README.md#resolving-layers)).

**Inputs:** the task folder (with `ticket.md` and `raw/` from intake), the tier, and any correction the user
gave. Run on its own, start with `anmarkoulis:intake` so the task folder exists.

## 1. Depth by tier

| Tier | Diagnoses |
|---|---|
| T0, T1 | one: the first installed of `mattpocock-skills:diagnosing-bugs`, `superpowers:systematic-debugging`, built-in |
| T2 | two, blind to each other, then reconciled |

**Methods.** Two blind diagnoses use `mattpocock-skills:diagnosing-bugs` for one and
`superpowers:systematic-debugging` for the other. With only one of them installed, it runs one diagnosis and
the built-in procedure (section 3) the other. With neither, the built-in procedure runs both. Either way, log
`ft log <folder> ship done status.md fallback: built-in diagnosis`.

## 2. Collect once

Every diagnosis reads the same inputs on disk: `ticket.md`, `raw/` and any attachments. Nobody re-fetches the
ticket. Pull what the **telemetry sources** give (read-only) into `debugging/telemetry/`; a source that could
not be reached is "not checked", never "0".

## 3. Diagnose

Each diagnosis is one worker, picked with `anmarkoulis:delegate`, role `diagnoser`, and writes
`debugging/<method>/findings.md` (`<method>` is `mattpocock`, `superpowers` or `built-in`; two built-in diagnoses use `built-in-a` and
`built-in-b`). For two
diagnoses, dispatch both in one message so they run in parallel.

Brief, every slot filled:

```
Diagnose <bug ref> in <repo>. First invoke <method skill> with the Skill tool and follow it
(built-in: reproduce it, list hypotheses, trace the failing path to file:line, verify the cause
by a check that would fail if you were wrong).
Mode: diagnosis only. No edits to tracked files, no branch switches, no commits, no tracker
writes. Scratch scripts and repro tests only in <task folder>/debugging/<method>/. Never start,
stop or tear down shared services. Never write tokens, credentials or personal data.
Bug: <title, environment, steps, expected, actual, error text>.
Claimed cause: <the ticket's or the user's>, a hypothesis to verify, never a fact.
Inputs on disk (read first): <task folder>/ticket.md, <task folder>/raw/, <telemetry files>.
Code: <repo path>. Production is <production ref>; confirm every cited line with
git show <ref>:<path>.
Write <task folder>/debugging/<method>/findings.md: root cause (file:line on <ref>), the exact
input or config that triggers it, evidence (each claim with the command that produced it),
still reproduces today?, proposed fix (shape, size S/M/L), what you could not verify,
confidence and what could still be wrong, adjacent problems (reported, not fixed).
```

To keep two diagnoses blind: give both the claimed cause as a hypothesis, give them separate folders, and never
pass one's findings to the other. Tell the user what is running and where it lands, then wait for both; never
predict results while they run. Run inline, the two are not blind: say so in `combined.md` and log
`ft log <folder> ship done status.md fallback: diagnoses inline, not blind`.

## 4. Reconcile (two diagnoses)

Read both `findings.md` and compare claim by claim:

| Claim | A | B | Agree? | Checked by me |
|---|---|---|---|---|
| Root cause (file:line) | | | | |
| Still reproduces | | | | |
| Affected inputs or environments | | | | |
| Fix shape and size | | | | |

- **Agree:** accept, and spot-check one piece of evidence (open the file:line or rerun one command).
- **Disagree, or only one covered it:** check it yourself at the ref and record which was right and why.
- **Neither checked it:** keep it as an open question, never a finding.

Never average a disagreement ("between M and L"): check it. With one diagnosis, spot-check its root cause the
same way.

## 5. Write `combined.md`

- **Verdict:** root cause (file:line), still live or not, fix shape and size, whether behaviour is missing
  rather than broken.
- The comparison table (two diagnoses) or the spot-check (one).
- Confidence, and the specific thing that could still be wrong.
- Open questions and who can answer them.
- Links to each `findings.md`.

Log `ft log <folder> debugging done combined.md`. No root cause found: log
`debugging stopped <date> combined.md no root cause`, with the open questions in `combined.md`; `understand`
asks the user how to go on.

## Mistakes to avoid

- Passing the claimed cause on as fact: every diagnosis then confirms it.
- Letting two diagnoses share a folder or see each other's output.
- Reporting before every diagnosis is back.

## Override points

| Point | Default | Allowed |
|---|---|---|
| telemetry sources | none; ask the user to paste logs or errors | `extend` |
| production ref | `origin/HEAD` | `set` |
