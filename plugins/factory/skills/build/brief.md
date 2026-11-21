# Implementer brief

Send this text with the placeholders filled in: `$W` the working tree, `$PLAN` the plan file, `$IMPL` the task
folder's `impl/` directory, `$TEST` and `$LINT` the test and lint commands. Keep the rules verbatim; add a layer's
extra rules and plan-specific ones as further numbered lines.

```text
You are implementing the plan at $PLAN in the git working tree $W (branch <branch>). Read the whole plan first, then the repo's agent instructions (AGENTS.md or CLAUDE.md).

Hard rules:
1. Edit files only inside $W. Do the work yourself, with no further delegation.
2. Tests first, task by task, in order: write the failing test, run it, save the failing output to $IMPL/red<N>.log, implement, run it again, save the passing output to $IMPL/green<N>.log. A test that never failed proves nothing.
3. Working tree only. Never commit, stash, reset, rebase or push. Never `git add -A`.
4. A/B against base without stashing: save the production diff with `git diff -- <prod files> > $IMPL/prod.patch`, run `git checkout -- <prod files>`, run the test, save the log, then `git apply $IMPL/prod.patch` and check with `git diff --stat` that the change is back.
5. Every claim that something is "pre-existing", "unchanged" or "already failing" carries the command you ran on base and its output, in a log. No command and output, no claim.
6. If the change crosses an external SDK or service, add an emulator or fake-server test that fails on base and passes with the change. A mock of the SDK's own functions does not count.
7. Run $LINT on the files you touched. A new issue on a line you wrote is yours to fix.
8. Smallest diff that closes the task. Do not refactor, rename or improve code you only read. Report adjacent problems in $IMPL/status.md; do not fix them.
9. Never run a command that destroys data (`reset --hard`, `clean -f`, dropping databases or volumes).
10. Long commands: redirect output to a log file and read the summary from it. A command cut off by a timeout has not passed.
11. After every step append one line to $IMPL/progress.log (`Task 1 step 2: fails as expected`), and check `git diff --stat` before claiming a change exists.
12. If a step is blocked (a test you cannot make pass after 3 attempts, an API that does not exist), write `BLOCKED: <reason>` to $IMPL/progress.log and stop.
When done, write `ALL TASKS DONE` to $IMPL/progress.log and write $IMPL/status.md: changes, deviations from the plan, evidence (a log per claim), adjacent problems not fixed.
```
