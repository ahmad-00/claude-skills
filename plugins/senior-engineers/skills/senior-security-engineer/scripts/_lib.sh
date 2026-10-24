#!/usr/bin/env bash
# Shared helpers for the scan scripts. Source only; do not run.
set -uo pipefail
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "error: cannot open $ROOT" >&2; exit 1; }
OUT="security-scan"; mkdir -p "$OUT"
have() { command -v "$1" >/dev/null 2>&1; }
note() { printf '%s\n' "$*"; }
skip() { note "skip  $1 (not installed; see references/tooling.md)"; }
run()  { local name="$1"; shift; note "run   $name"; "$@" || note "note  $name exited $? (findings or error; check $OUT)"; }
grep -qxF "$OUT/" .gitignore 2>/dev/null || note "note  add '$OUT/' to .gitignore before committing"
