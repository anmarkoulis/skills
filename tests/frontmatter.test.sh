#!/usr/bin/env bash
# Fails when a SKILL.md or agent frontmatter value is unquoted and has a space or tab before "#": YAML reads
# the rest of the line as a comment and silently cuts the value off (#36). Run: bash tests/frontmatter.test.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }

# Prints file:line for each `key: value` line in the leading --- block whose value is plain (not quoted, not a
# block scalar) and contains a space or tab before "#".
scan() {
  awk -v sq="'" '
    { sub(/\r$/, "") }
    FNR == 1 { fm = ($0 == "---"); next }
    fm && $0 == "---" { fm = 0; next }
    fm && match($0, /^[A-Za-z0-9_-]+:[ \t]+/) {
      v = substr($0, RLENGTH + 1); c = substr(v, 1, 1)
      if (c != "\"" && c != sq && c != "|" && c != ">" && v ~ /[ \t]#/) print FILENAME ":" FNR
    }
  ' "$@"
}

printf -- '---\nname: a\ndescription: run "ship #42" now\n---\nbody # ok\n' > "$tmp/bad.md"
printf -- "---\nname: b\ndescription: 'run \"ship #42\" now'\n---\nbody # ok\n" > "$tmp/good.md"
[ "$(scan "$tmp/bad.md")" = "$tmp/bad.md:3" ] || fail "unquoted ' #' not flagged"
[ -z "$(scan "$tmp/good.md")" ] || fail "quoted value flagged"
printf -- '---\ndescription: run\t#42 now\n---\n' > "$tmp/tab.md"
[ "$(scan "$tmp/tab.md")" = "$tmp/tab.md:2" ] || fail "unquoted tab-# not flagged"
printf -- '---\r\ndescription: run #42 now\r\n---\r\n' > "$tmp/crlf.md"
[ "$(scan "$tmp/crlf.md")" = "$tmp/crlf.md:2" ] || fail "CRLF frontmatter not scanned"

cd "$root"
files=$(git ls-files -- '*SKILL.md' 'agents/*.md')
[ -n "$files" ] || fail "no SKILL.md or agent files found"
# shellcheck disable=SC2086 # paths have no spaces; word splitting is the point
bad=$(scan $files)
[ -z "$bad" ] || fail "unquoted frontmatter value contains ' #' (quote it):
$bad"
echo "frontmatter: ok"
