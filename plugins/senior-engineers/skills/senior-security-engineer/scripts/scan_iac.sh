#!/usr/bin/env bash
# IaC, Dockerfile and Kubernetes manifest checks. Usage: bash scan_iac.sh [repo_root]
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
if have trivy; then run "trivy config" trivy config --format sarif -o "$OUT/trivy-config.sarif" . ; else skip trivy; fi
if have checkov; then run "checkov" checkov -d . -o sarif --output-file-path "$OUT" --quiet --compact; else skip checkov; fi
if have hadolint; then
  for d in $(find . -maxdepth 3 -name "Dockerfile*" -not -path "*/node_modules/*" 2>/dev/null); do
    run "hadolint $d" sh -c "hadolint -f sarif '$d' > '$OUT/hadolint-$(echo "$d" | tr '/.' '__').sarif'"
  done
fi
if have kubescape && find . -maxdepth 3 -name "*.yaml" -path "*k8s*" 2>/dev/null | head -n 1 | grep -q .; then
  run "kubescape" kubescape scan . --format sarif --output "$OUT/kubescape.sarif"
fi
note "done  outputs in $OUT/"
