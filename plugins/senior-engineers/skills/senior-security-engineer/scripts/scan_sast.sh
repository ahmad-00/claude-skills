#!/usr/bin/env bash
# Static analysis with rulesets chosen from the languages present. Usage: bash scan_sast.sh [repo_root]
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
cfg=(--config p/secrets --config p/owasp-top-ten)
has_ext() { find . -type f -name "*.$1" -not -path "*/node_modules/*" -not -path "*/.venv/*" -not -path "*/build/*" 2>/dev/null | head -n 1 | grep -q .; }
has_ext py && cfg+=(--config p/python) && { grep -rqs "django" pyproject.toml requirements*.txt 2>/dev/null && cfg+=(--config p/django); }
{ has_ext ts || has_ext tsx || has_ext js || has_ext jsx; } && cfg+=(--config p/javascript --config p/typescript)
{ has_ext tsx || has_ext jsx; } && cfg+=(--config p/react)
[ -f next.config.js ] || [ -f next.config.ts ] || [ -f next.config.mjs ] && cfg+=(--config p/nextjs)
has_ext kt && cfg+=(--config p/kotlin)
has_ext swift && cfg+=(--config p/swift)
has_ext tf && cfg+=(--config p/terraform)
if have semgrep; then run "semgrep (${#cfg[@]} args)" semgrep scan "${cfg[@]}" --sarif -o "$OUT/semgrep.sarif" --quiet; else skip semgrep; fi
if has_ext py && have bandit; then run "bandit" bandit -r . -q -f sarif -o "$OUT/bandit.sarif" -x ./.venv,./node_modules; fi
if [ -f build.gradle.kts ] || [ -f build.gradle ]; then note "hint  run ./gradlew lint for Android security checks (exported components, cleartext, WebView)"; fi
note "done  outputs in $OUT/"
