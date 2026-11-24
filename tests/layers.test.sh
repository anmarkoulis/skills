#!/usr/bin/env bash
# Fails when a skill with override points does not point to the layer procedure, or when the contract or ship
# still name a fixed helper list (#70). Run: bash tests/layers.test.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
pointer='contracts/README.md#resolving-layers'

# Prints each file whose Override points table has a row other than `none` and that lacks the pointer.
scan() {
  for f in "$@"; do
    awk '
      /^## Override points/ { t = 1; next }
      /^## / { t = 0 }
      t && /^\| / && !/^\| *Point *\|/ && !/^\| *none *\|/ { found = 1 }
      END { exit !found }
    ' "$f" && ! grep -q "$pointer" "$f" && echo "$f"
  done
  return 0
}

printf '# a\n## Override points\n| Point | Default | Allowed |\n|---|---|---|\n| x | y | set |\n' > "$tmp/bad.md"
printf '# b\n## Override points\n| Point | Default | Allowed |\n|---|---|---|\n| none | — | — |\n' > "$tmp/none.md"
cp "$tmp/bad.md" "$tmp/good.md"; echo "see $pointer" >> "$tmp/good.md"
[ "$(scan "$tmp/bad.md")" = "$tmp/bad.md" ] || fail "skill with points and no pointer not flagged"
[ -z "$(scan "$tmp/none.md" "$tmp/good.md")" ] || fail "none table or pointed skill flagged"

cd "$root"
files=$(git ls-files -- 'skills/*SKILL.md')
[ -n "$files" ] || fail "no SKILL.md files found"
# shellcheck disable=SC2086 # paths have no spaces; word splitting is the point
bad=$(scan $files)
[ -z "$bad" ] || fail "override points without a link to $pointer:
$bad"
! grep -n "helper step" contracts/README.md README.md skills/factory/ship/SKILL.md skills/factory/setup/SKILL.md || fail "fixed helper list still named"
# The old order (personal above the repo, local else user) must not come back (#76).
! grep -nE "come after the repo's|else (in )?\`~/\.claude/CLAUDE\.md\`" contracts/README.md README.md skills/factory/ship/SKILL.md \
  skills/factory/setup/SKILL.md || fail "old layer order still stated"
grep -q 'core < user < repo < local' contracts/README.md || fail "contract does not state the layer order"
echo "layers: ok"
