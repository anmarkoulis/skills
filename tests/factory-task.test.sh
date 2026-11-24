#!/usr/bin/env bash
# Self-check for contracts/factory-task. Run: bash tests/factory-task.test.sh
# SC1010: 'done' here is a status.md state passed as an argument, not the loop keyword.
# shellcheck disable=SC1010
set -euo pipefail
ft="$(cd "$(dirname "$0")/.." && pwd)/contracts/factory-task"
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
no bash "$ft" log "$d" plan done 2026-11-22
printf '\n  \n' >> "$d/status.md"
[ "$(bash "$ft" last "$d")" = "build done $(date +%F) impl/status.md round 2 ← review: missing null check" ] || fail "last: $(bash "$ft" last "$d")"
[ "$(grep -c '[^[:space:]]' "$d/status.md")" -eq 3 ] || fail "rejected lines were written"
r=$(bash "$ft" -C "$tmp" path rounds)
[ "$(bash "$ft" rounds "$r")" = 0 ] || fail "rounds on empty"
ok bash "$ft" log "$r" build done impl/status.md
ok bash "$ft" log "$r" build done impl/status.md round 2 ← review: x
[ "$(bash "$ft" rounds "$r")" = 2 ] || fail "rounds: $(bash "$ft" rounds "$r")"
ok bash "$ft" log "$r" plan done plan.md
[ "$(bash "$ft" rounds "$r")" = 0 ] || fail "rounds not reset by plan done"
ok bash "$ft" log "$r" build done impl/status.md round 3 ← verify: y
ok bash "$ft" log "$r" verify loop verify.md "→build y"
ok bash "$ft" log "$r" ship stopped status.md loop cap 1 reached
ok bash "$ft" log "$r" ship stopped status.md repeat finding a.sh:3
[ "$(bash "$ft" rounds "$r")" = 1 ] || fail "rounds after reset: $(bash "$ft" rounds "$r")"
no bash "$ft" rounds "$tmp/nowhere"
# move: the only way a task folder leaves a worktree (#67)
a="$tmp/ma"; b="$tmp/mb"; mkdir -p "$a" "$b"; git -C "$a" init -q; git -C "$b" init -q
m=$(bash "$ft" -C "$a" path s); mkdir "$m/raw"; echo x > "$m/raw/f"
ok bash "$ft" log "$m" plan done plan.md
ok bash "$ft" move s "$a" "$b"
[ -f "$b/.factory/s/raw/f" ] || fail "move: nested file not carried"
[ ! -e "$a/.factory/s" ] || fail "move: source left behind"
[ "$(bash "$ft" last "$b/.factory/s")" = "plan done $(date +%F) plan.md" ] || fail "move: last line"
[ "$(cat "$b/.factory/.gitignore")" = "*" ] || fail "move: new base not self-ignoring"
[ ! -e "$b/.factory/status.md" ] || fail "move: flattened into the base"
tm=$(bash "$ft" -C "$a" path t); ok bash "$ft" log "$tm" plan done plan.md
ok bash "$ft" move t "$a/" "$b/"
[ -f "$b/.factory/t/status.md" ] && [ ! -e "$b/.factory/status.md" ] || fail "move: trailing slash flattened"
bash "$ft" -C "$a" path s >/dev/null
no bash "$ft" move s "$a" "$b"
[ -f "$a/.factory/s/status.md" ] || fail "move: source touched when target exists"
no bash "$ft" move nope "$a" "$b"
mkdir "$a/.factory/bare"; no bash "$ft" move bare "$a" "$b"
[ -d "$a/.factory/bare" ] && [ ! -e "$b/.factory/bare" ] || fail "move: folder without status.md moved"
e=$(bash "$ft" -C "$a" path empty); printf '\n \n' > "$e/status.md"; no bash "$ft" move empty "$a" "$b"
[ -f "$a/.factory/empty/status.md" ] && [ ! -e "$b/.factory/empty" ] || fail "move: empty status.md moved"
um=$(bash "$ft" -C "$a" path u work/tasks); ok bash "$ft" log "$um" plan done plan.md
ok bash "$ft" move u "$a" "$b" work/tasks
[ -f "$b/work/tasks/u/status.md" ] || fail "move: custom base"
no bash "$ft" move "Bad" "$a" "$b"
# x/../out resolves inside both roots, so only the '..' check refuses it.
v=$(bash "$ft" -C "$a" path v out); ok bash "$ft" log "$v" plan done plan.md; mkdir "$a/x"
no bash "$ft" move v "$a" "$b" x/../out
[ -f "$a/out/v/status.md" ] && [ ! -e "$b/out" ] || fail "move: '..' base not refused"
no bash "$ft" move s "$a" "$tmp/nowhere"
echo "factory-task: all checks passed"
