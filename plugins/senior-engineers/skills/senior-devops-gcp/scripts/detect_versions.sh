#!/usr/bin/env bash
# Read-only: report Terraform/OpenTofu, provider and CI versions. Never runs apply or mutating gcloud commands.
# Usage: bash detect_versions.sh [repo_root]
set -uo pipefail
root="${1:-.}"
cd "$root" 2>/dev/null || { echo "error: cannot open $root" >&2; exit 1; }

command -v terraform >/dev/null 2>&1 && terraform version 2>/dev/null | head -n 1
command -v tofu >/dev/null 2>&1 && tofu version 2>/dev/null | head -n 1
for f in .terraform-version .opentofu-version .tool-versions; do [ -f "$f" ] && echo "$f: $(tr '\n' ' ' < "$f")"; done

echo "== required_version / providers"
grep -rnE "required_version|source *= *\"hashicorp/google(-beta)?\"|version *= *\"[~><= 0-9.,]+\"" --include=*.tf . 2>/dev/null | grep -v "/.terraform/" | head -n 40
echo "== lock files (resolved provider versions)"
find . -name .terraform.lock.hcl -not -path "*/.terraform/*" 2>/dev/null | while read -r l; do
  echo "-- $l"; grep -A1 -E 'provider "registry\.(terraform|opentofu)\.io/hashicorp/google(-beta)?"' "$l" | grep -E "provider|version"; done
echo "== backends"
grep -rn -A3 'backend "' --include=*.tf . 2>/dev/null | grep -v "/.terraform/" | grep -E "backend|bucket|prefix" | head -n 20

echo "== provider 8 risk scan"
grep -rnE "google_(iap_brand|iap_client|notebooks_|ml_engine_model|vertex_ai_schedule|beyondcorp_app_)" --include=*.tf . 2>/dev/null | grep -v "/.terraform/" | sed 's/^/REMOVED IN 8.x: /'
grep -rlE "resource \"google_compute_(backend_service|global_forwarding_rule)\"" --include=*.tf . 2>/dev/null | grep -v "/.terraform/" | while read -r f; do
  grep -q "load_balancing_scheme" "$f" || echo "DEFAULT CHANGE: $f has LB resources without explicit load_balancing_scheme"
done

echo "== CI"
grep -rnE "google-github-actions/(auth|setup-gcloud|deploy-cloudrun)@[^ ]+" .github/workflows 2>/dev/null | sed 's/^/gha: /'
grep -rn "credentials_json" .github/workflows 2>/dev/null | sed 's/^/WARNING key-based auth: /'
[ -f cloudbuild.yaml ] && echo "cloud build: cloudbuild.yaml"
[ -f clouddeploy.yaml ] && echo "cloud deploy: clouddeploy.yaml"
grep -rlE '"type": *"service_account"' --include=*.json . 2>/dev/null | grep -v node_modules | head -n 5 | sed 's/^/WARNING possible SA key file: /'
exit 0
