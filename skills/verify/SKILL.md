---
name: verify
description: Use as the verify step of factory:ship, after review and after every build round, or when asked to "verify", "test this branch" or "what is covered", to prove the change works at the levels the tier requires and to write down what is not proven.
---

# verify

Prove the change works and say what is not proven. Writes `verify.md`, `gaps.md` and logs under `verify/`.
Never reports a pass without the command and its output. Never edits production code: a failure goes back to
build. Contracts and evidence rules: [../../contracts/README.md](../../contracts/README.md).

## 1. Regression map, always first

At the top of `verify.md`, record the tree under test (HEAD sha) and the base sha from `decisions.md`; every diff
and A/B uses those exact shas. Read the diff against the base and list every touched function or flow and its
callers (grep, or a code-graph tool if the repo has one). For every route, URL, request or response field,
permission or file format the diff changes, also list its **outside consumers** (other repos, clients, infra
configs) and check each; a removed or renamed one is a breaking change until each consumer is checked. Every
level below takes its scope from this map.

## 2. Levels

The tier sets the required levels: T0 L1; T1 L1–L2; T2 L1–L3 plus the base-vs-fix A/B and the outside
consumers. Run each required level; skip one only with a written reason, shown at the stop.

- **L1, always:** the **L1 commands** (default: the repo's documented test, lint and build commands) for the
  touched code and every caller in the map. Tests that need an emulator or a container run against it.
- **L2, acceptance suite:** `factory:qa-tests` when installed, else the **L2 command** a layer sets. Neither:
  record `L2 not applicable: no acceptance suite declared` in `gaps.md`.
- **L3, manual:** `factory:manual-test` when installed, else the **L3 procedure** a layer sets, else a script
  the user runs with you, step by step. Required for security, outbound-call and user-facing changes.
- **L4, after deploy:** staging or production retests and monitoring. List them as follow-ups; never run them
  unasked.
- **A/B (T2):** run the new tests on the base without the production change and show they fail, using the **A/B
  mechanism** (default: rule 4 of [../build/brief.md](../build/brief.md)).

## 3. Runs

`verify.md` holds numbered runs. Each run: level, exact command, result (pass, fail, skipped), log path under
`verify/`. After every build round, and after any production line changes, add run N+1 with the same L1 and L3
commands. Narrowing a required rerun makes the step `changed`, not `done`, and names the stale run in
`gaps.md`.

## 4. Gaps

`gaps.md`: what is covered, what is not and why, and what needs approval to check (real third-party accounts,
staging, production data). Add items found but out of scope, one line each.

## Done

- All required levels pass: `verify stopped <date> verify.md awaiting answer` when the tier has a verify stop,
  otherwise `verify done <date> verify.md`.
- A failure: verdict `flawed`, log `verify loop <date> verify.md →build <failing command, in short>`.
- Something only a person can check: verdict `manual`, stop and ask.

## Override points

| Point | Default | Allowed |
|---|---|---|
| L1 commands | the repo's documented test, lint and build commands | `set` |
| L2 command | `factory:qa-tests` if installed, else none | `set` |
| L3 procedure | `factory:manual-test` if installed, else a guided script with the user | `set` |
| outside consumers | none known; grep what the map finds | `extend` |
| A/B mechanism | patch out the production diff, run, re-apply | `replace` |
| environment quirks | none | `extend` |
