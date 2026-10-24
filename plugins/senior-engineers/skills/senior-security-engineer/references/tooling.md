# Security tooling by layer

## Contents
- Supply-chain caution for the scanners themselves
- Secrets
- Dependencies (SCA)
- SAST
- Containers, IaC, cloud posture
- Dynamic testing (authorized targets only)
- Mobile
- Supply chain and build integrity
- AI/LLM features

Pinned versions live in `versions.md`. Prefer SARIF output so results merge into one view.

## Supply-chain caution for the scanners themselves

Security tools are targets. Pin tool versions, install from official release channels, verify checksums or signatures, and pin GitHub Actions to commit SHAs. If a tool's release pipeline has been compromised recently (see `versions.md`), stay on a known-good version until the vendor publishes a verified build.

## Secrets

```bash
# git history + working tree
gitleaks git -s . --report-format sarif --report-path security-scan/gitleaks-git.sarif
gitleaks dir -s . --report-format sarif --report-path security-scan/gitleaks-dir.sarif
# optional: verify whether leaked credentials are live (needs authorization: it contacts providers)
trufflehog git file://. --only-verified --json > security-scan/trufflehog.json
```

Treat any verified-live secret as Critical: it needs rotation first, then removal from history.

## Dependencies (SCA)

```bash
osv-scanner scan --format sarif -o security-scan/osv.sarif .      # all lockfiles
trivy fs --scanners vuln,secret --format sarif -o security-scan/trivy-fs.sarif .
# ecosystem-native, where present
pip-audit -r requirements.txt -f sarif -o security-scan/pip-audit.sarif
uv audit                                   # uv projects (preview feature; non-zero exit on findings)
npm audit --json > security-scan/npm-audit.json   # or: pnpm audit --json
./gradlew dependencyCheckAnalyze           # if the project has the OWASP plugin configured
```

Produce an SBOM when the report will be shared with others: `syft dir:. -o cyclonedx-json > security-scan/sbom.cdx.json`, then `grype sbom:security-scan/sbom.cdx.json -o sarif`.

## SAST

```bash
semgrep scan --config p/secrets --config p/owasp-top-ten \
  --config p/python --config p/django \            # Python/Django
  --config p/javascript --config p/typescript --config p/react --config p/nextjs \
  --config p/kotlin --config p/swift --config p/terraform \
  --sarif -o security-scan/semgrep.sarif
bandit -r . -f sarif -o security-scan/bandit.sarif        # Python
npx eslint --plugin security .                            # JS/TS, if eslint-plugin-security is installed
./gradlew lint                                            # Android: exported components, cleartext, WebView
```

Only include rulesets for languages actually present (the scan script does this). Read each hit before reporting it.

## Containers, IaC, cloud posture

```bash
trivy config --format sarif -o security-scan/trivy-config.sarif .   # Terraform, Dockerfile, K8s, Helm
checkov -d . -o sarif --output-file-path security-scan/               # alternative/second opinion
hadolint Dockerfile -f sarif > security-scan/hadolint.sarif
trivy image --format sarif -o security-scan/trivy-image.sarif <image:tag>
kube-bench                       # CIS benchmark on a cluster node (authorized)
kubescape scan --format sarif    # cluster/manifests
prowler gcp                      # GCP posture (needs read-only credentials and authorization)
gcloud scc findings list ORG_ID --filter="state=\"ACTIVE\""   # Security Command Center findings
```

Flags to look for first: public storage (`allUsers`), service-account keys, basic IAM roles, `0.0.0.0/0` ingress, privileged containers, `latest` tags, missing resource limits.

## Dynamic testing (authorized targets only)

Order: recon → baseline → manual. Log every request.

```bash
testssl.sh --quiet --jsonfile security-scan/tls.json https://target.example      # TLS config
httpx -u https://target.example -title -tech-detect -status-code -json             # fingerprint
docker run --rm -v "$PWD/security-scan:/zap/wrk" ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t https://target.example -J zap-baseline.json                  # passive baseline
nuclei -u https://target.example -tags misconfig,exposure -severity medium,high,critical \
  -rate-limit 20 -json-export security-scan/nuclei.json                           # non-intrusive templates only
schemathesis run https://target.example/openapi.json --checks all --max-examples 50  # API contract fuzzing
```

Manual tests that scanners miss: IDOR with two test accounts, role escalation, token reuse after logout, missing rate limits on login/OTP/reset, business-logic tampering, race conditions on single-use actions. `sqlmap`, `ffuf` and ZAP active scan are intrusive: use them only with an explicit go-ahead and against staging.

## Mobile

```bash
docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf   # upload APK/IPA, export JSON
apkanalyzer manifest print app.apk        # exported components, permissions, cleartext flag
jadx -d out app.apk                       # decompile for secrets, WebView settings, pinning
```

Map findings to OWASP MASVS 2.1 categories and MASTG v2 tests. Dynamic instrumentation (Frida/objection) only on devices and apps the user owns.

## Supply chain and build integrity

- Lockfiles committed and used in CI; `npm ci` / `uv sync --frozen` / `pip install --require-hashes`.
- GitHub Actions pinned to SHAs; `actions/dependency-review-action` on PRs; OpenSSF Scorecard for repo posture.
- Artifact provenance: `gh attestation verify <artifact> --owner <org>`; `cosign verify` for images.
- Registry signatures: `npm audit signatures`.

## AI/LLM features

If the project calls an LLM: test for prompt injection via untrusted content, excessive agency (tools the model can call), sensitive data in prompts/logs, and output handling (rendered HTML, executed code). Tools: `promptfoo redteam` (plugins mapped to the OWASP LLM Top 10) and `garak`. Map to the OWASP Top 10 for LLM Applications.
