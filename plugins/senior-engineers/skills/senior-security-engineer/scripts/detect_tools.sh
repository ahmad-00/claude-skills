#!/usr/bin/env bash
# Read-only: report the project's stack, existing security tooling, and which scanners are installed.
# Usage: bash detect_tools.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }

echo "== stack signals"
for f in pyproject.toml requirements.txt uv.lock poetry.lock package.json pnpm-lock.yaml package-lock.json yarn.lock \
         Package.swift Podfile gradle/libs.versions.toml build.gradle.kts Dockerfile docker-compose.yml compose.yaml \
         versions.tf main.tf cloudbuild.yaml; do
  [ -e "$f" ] && echo "  $f"
done
ls -d *.xcodeproj *.xcworkspace 2>/dev/null | sed 's/^/  /'
find . -maxdepth 3 -name "*.tf" -not -path "*/.terraform/*" 2>/dev/null | head -n 1 | sed 's/^/  terraform: /'
find . -maxdepth 2 -name "AndroidManifest.xml" 2>/dev/null | head -n 1 | sed 's/^/  android: /'

echo "== existing security tooling"
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | xargs -r grep -lE "codeql|semgrep|trivy|gitleaks|snyk|dependency-review|scorecard" | sed 's/^/  ci: /'
[ -f .github/dependabot.yml ] && echo "  dependabot"
[ -f .pre-commit-config.yaml ] && grep -qE "gitleaks|bandit|semgrep|detect-secrets" .pre-commit-config.yaml && echo "  pre-commit hooks with security checks"
[ -f .gitleaks.toml ] && echo "  .gitleaks.toml"
[ -f .semgrep.yml ] || [ -d .semgrep ] && echo "  semgrep config"
[ -f SECURITY.md ] && echo "  SECURITY.md (disclosure policy)"

echo "== scanners installed"
for t in gitleaks trufflehog osv-scanner trivy semgrep bandit pip-audit uv checkov hadolint syft grype \
         nuclei httpx testssl.sh sslyze schemathesis zap.sh kubescape kube-bench prowler gh cosign docker; do
  if command -v "$t" >/dev/null 2>&1; then
    v=$("$t" --version 2>/dev/null | head -n 1 | tr -d '\n' | cut -c1-60)
    printf '  %-14s %s\n' "$t" "${v:-present}"
  else
    printf '  %-14s -\n' "$t"
  fi
done
exit 0
