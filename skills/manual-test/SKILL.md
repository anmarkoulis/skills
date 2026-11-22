---
name: manual-test
description: Use as level L3 of factory:verify, or when a user-facing, security or outbound-call change needs hands-on proof in the running app, or verify needs to know whether a manual pass is possible and which cases it covers. Drives the app one script per flow and writes verify/manual.md.
---

# manual-test

Drives the running app through the cases the change must satisfy and records what was seen. Writes
`verify/manual.md`, plus one script per flow and one screenshot per case in `verify/manual/`, in the task folder;
never edits repo files. Contracts and evidence rules: [../../contracts/README.md](../../contracts/README.md).
`ft` means `bash <plugin root>/contracts/factory-task`; the plugin root is two directories above this skill's
base directory.

**Inputs:** the task folder (`plan.md`, `spec.md` if present, the regression map in `verify.md`). The run is one
worker, picked with `factory:delegate`, role `manual-tester`; the brief is the case list (step 1), how to reach
the app (step 2), the task folder and this skill's path. A worker given this skill does the steps below itself.

## 1. Cases

From the plan, the spec and the regression map, one row per case: id | what to do | expected. Include the
failing path the change fixes, the happy path, and one neighbouring flow from the map that shares code. Show the
list to the user unless it was given.

## 2. Reach the app

- **How:** the **how to reach the app** a layer sets; else start it as the README, Makefile or compose file
  says; else ask for a URL.
- **Login:** the **login** a layer sets; else a local or test account; else ask.
- **API only** (no UI): the evidence is request and response transcripts (`curl`) saved in `verify/manual/`, not
  screenshots.
- **Real accounts:** real external accounts or services (third-party providers, mail, production-like tenants)
  only with the user's yes for that action, after naming the account and the undo. In the browser, block
  requests to non-local hosts and log them.

No runnable app, no UI or API for the touched code, or no way to log in: write `not applicable: <reason>` as the
whole of `manual.md` (for example "library with no service"). Never leave it empty and never report a pass.

## 3. Run

- **Browser:** a Playwright script run with `npx playwright` when Node is available, or the Claude in Chrome
  extension when connected (Claude Code only). Neither: write the steps as a guided script the user runs, and
  record what they report. That needs the user, so it runs inline; a worker stops there and
  returns `manual` with the script in `verify/manual/`.
- One script per flow in `verify/manual/<flow>.*`, so a re-verify reruns it unchanged.
- Run one case first; only when it works, or fails for a reason about the change rather than setup, run the
  rest.
- One screenshot per case, named by case id. Watch dialogs and console errors: proof of an injected script is a
  dialog or an element, not a 200.
- Note every state you changed, and undo it.

## 4. Record `verify/manual.md`

Table **case | expected | seen | screenshot**, with timings or status codes where they matter. Then: cases not
run and why, state changed and restored, gaps (a touched flow with no case), and the verdict (the contract's: `success`, `flawed`,
`success` with `not applicable: <reason>`, or `manual` when a person must look) with its evidence. A pass needs the screenshot or transcript and the observation behind it.

Log `ft log <folder> manual-test done verify/manual.md`; not applicable:
`manual-test skipped <date> verify/manual.md <reason>`.

## Override points

| Point | Default | Allowed |
|---|---|---|
| how to reach the app | README, Makefile or compose file, else ask for a URL | `set` |
| login | a local or test account, else ask | `set` |
| real-account rules | ask before each action on a real account | `extend` (tighten only) |
