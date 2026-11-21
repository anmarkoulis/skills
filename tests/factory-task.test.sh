#!/usr/bin/env bash
# Self-check for plugins/factory/contracts/factory-task. Run: bash tests/factory-task.test.sh
# SC1010: 'done' here is a status.md state passed as an argument, not the loop keyword.
# shellcheck disable=SC1010
set -euo pipefail
ft="$(cd "$(dirname "$0")/.." && pwd)/plugins/factory/contracts/factory-task"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q
fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { "$@" >/dev/null 2>&1 || fail "expected success: $*"; }
no() { ! "$@" >/dev/null 2>&1 || fail "expected failure: $*"; }

d=$(bash "$ft" -C "$tmp" path fix-login)
[ "$d" = "$(cd "$tmp" && pwd -P)/.factory/fix-login" ] || [ "$d" = "$tmp/.factory/fix-login" ] || fail "path: $d"
[ -f "$d/status.md" ] || fail "status.md not created"
[ "$(cat "$tmp/.factory/.gitignore")" = "*" ] || fail ".gitignore content"
[ -z "$(git -C "$tmp" status --porcelain)" ] || fail "folder shows in git status"
echo keep > "$tmp/.factory/.gitignore"; bash "$ft" -C "$tmp" path fix-login >/dev/null
[ "$(cat "$tmp/.factory/.gitignore")" = "keep" ] || fail ".gitignore overwritten"
ok bash "$ft" -C "$tmp" path other work/tasks
[ -f "$tmp/work/tasks/other/status.md" ] || fail "custom base"
no bash "$ft" -C "$tmp" path "Bad Slug"
no bash "$ft" -C "$tmp" path x ../out
no bash "$ft" -C / path x
no bash "$ft" -C "$tmp" path x /abs
no bash "$ft" -C "$tmp" path x y/..
no bash "$ft" -C "$tmp" path x y/../z
ok bash "$ft" -C "$tmp" path x a..b
mkdir "$tmp/src"; ok bash "$ft" -C "$tmp" path t src
[ ! -e "$tmp/src/.gitignore" ] || fail ".gitignore written into an existing base"

[ -z "$(bash "$ft" last "$d")" ] || fail "last on empty"
ok bash "$ft" log "$d" intake stopped decisions.md awaiting answer
ok bash "$ft" log "$d" review loop /abs/review.md "→build missing null check"
ok bash "$ft" log "$d" build done impl/status.md round 2 ← review: missing null check
no bash "$ft" log "$d" plan skipped plan.md
no bash "$ft" log "$d" plan finished plan.md
no bash "$ft" log "$d" verify loop verify.md flaky
no bash "$ft" log "$d" Plan done plan.md
no bash "$ft" log "$d" plan done plan.md "$(printf 'x\nbuild done 2020-01-01 y')"
no bash "$ft" log "$d" plan done plan.md "$(printf 'x\ry')"
no bash "$ft" log "$d" plan done "$(printf 'a\nb')"
no bash "$ft" log "$d" plan done ""
no bash "$ft" log "$d" plan done "$(printf 'a\tb')"
printf '\n  \n' >> "$d/status.md"
[ "$(bash "$ft" last "$d")" = "build done $(date +%F) impl/status.md round 2 ← review: missing null check" ] || fail "last: $(bash "$ft" last "$d")"
[ "$(grep -c '[^[:space:]]' "$d/status.md")" -eq 3 ] || fail "rejected lines were written"
echo "factory-task: all checks passed"
