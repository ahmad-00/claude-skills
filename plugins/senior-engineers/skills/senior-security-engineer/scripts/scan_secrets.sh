#!/usr/bin/env bash
# Local-only secret scan of git history and the working tree. Usage: bash scan_secrets.sh [repo_root]
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
if have gitleaks; then
  run "gitleaks git" gitleaks git -s . --no-banner --exit-code 0 --report-format sarif --report-path "$OUT/gitleaks-git.sarif"
  run "gitleaks dir" gitleaks dir -s . --no-banner --exit-code 0 --report-format sarif --report-path "$OUT/gitleaks-dir.sarif"
else skip gitleaks; fi
if have trufflehog; then
  # No --only-verified here: verification contacts providers and needs authorization (Step 0).
  run "trufflehog" sh -c "trufflehog git file://. --no-verification --json > '$OUT/trufflehog.json'"
else skip trufflehog; fi
note "done  outputs in $OUT/"
