---
name: qa-tests
description: Use as level L2 of anmarkoulis:verify, or when a change needs the repo's acceptance, end-to-end or QA suite run, or verify needs to know whether such a suite exists and which scenarios cover the touched area. Writes verify/qa.md.
---

# qa-tests

Runs the repo's acceptance or end-to-end suite for the touched area and records what happened. Writes
`verify/qa.md` and raw logs in `verify/qa/` in the task folder; never edits repo files. Contracts and evidence
rules: [../../../contracts/README.md](../../../contracts/README.md). `ft` means
`bash <plugin root>/contracts/factory-task`; the plugin root is three directories above this skill's base
directory.

**Inputs:** the task folder, the touched area (from the regression map in `verify.md`), the suite location if
known. The run is one worker, picked with `anmarkoulis:delegate`, role `qa-runner`; the brief is these inputs plus
this skill's path. A worker given this skill does the steps below itself.

## 1. Find the suite

The **suite location** a layer sets; else look in this order and stop at the first hit: README or CONTRIBUTING
sections on e2e, acceptance, integration or BDD tests; Makefile, package scripts or CI workflow targets named
`e2e`, `acceptance`, `qa` or `bdd`; a `tests/e2e`-style directory or sibling repo the README points to. Note the
command, its config files, and the accounts or services it needs to start.

No suite, a suite that covers nothing in the touched area, or an app that cannot run here: write
`not applicable: <reason>` as the whole of `qa.md` (for example "Makefile has only a unit `test` target; no e2e
target"). Never leave it empty and never report a pass.

## 2. Select scenarios

Search the suite's scenario files for the touched area (feature names, endpoints, page objects). List the
matches. An area with no match is a gap.

## 3. Check prerequisites

Confirm what the suite needs exists here (accounts, fixtures, services, env vars, plus the **prerequisites** a
layer adds) before running. A missing prerequisite is a recorded skip with its reason, not a failure of the
change.

## 4. Run

Run **one** scenario first, with the **required flags**. Only when it starts and passes, or fails for a reason
about the change rather than setup, run the rest of the batch. Save each command's raw output to
`verify/qa/<name>.log`.

## 5. Record `verify/qa.md`

- **Ran:** scenario, command, result, log path.
- **Skipped:** scenario and why.
- **Gaps:** touched behaviour with no scenario.
- **Verdict** (the contract's): `success`, `flawed`, or `success` with `not applicable: <reason>`; a missing
  prerequisite is `blocked`. With the evidence it rests on.

A pass needs the command and its output. Log `ft log <folder> qa-tests done verify/qa.md`; not applicable:
`qa-tests skipped <date> verify/qa.md <reason>`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| suite location | the search order in step 1 | `set` |
| prerequisites | none beyond what the suite's docs name | `extend` |
| required flags | none | `set` |
