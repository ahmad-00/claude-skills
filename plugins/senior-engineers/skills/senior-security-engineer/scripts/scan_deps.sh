#!/usr/bin/env bash
# Dependency (SCA) scan against public advisory databases. Usage: bash scan_deps.sh [repo_root]
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
if have osv-scanner; then run "osv-scanner" osv-scanner scan --format sarif --output "$OUT/osv.sarif" . ; else skip osv-scanner; fi
if have trivy; then run "trivy fs" trivy fs --scanners vuln,secret --format sarif -o "$OUT/trivy-fs.sarif" . ; else skip trivy; fi
if [ -f uv.lock ] && have uv; then run "uv audit" sh -c "uv audit > '$OUT/uv-audit.txt' 2>&1"; fi
if [ -f requirements.txt ] && have pip-audit; then run "pip-audit" pip-audit -r requirements.txt -f sarif -o "$OUT/pip-audit.sarif"; fi
if [ -f pnpm-lock.yaml ] && have pnpm; then run "pnpm audit" sh -c "pnpm audit --json > '$OUT/pnpm-audit.json'"
elif [ -f package-lock.json ] && have npm; then run "npm audit" sh -c "npm audit --json > '$OUT/npm-audit.json'"; fi
if have syft; then run "syft sbom" syft dir:. -o cyclonedx-json="$OUT/sbom.cdx.json" -q
  if have grype; then run "grype" grype "sbom:$OUT/sbom.cdx.json" -o sarif --file "$OUT/grype.sarif" -q; fi
fi
note "done  outputs in $OUT/"
