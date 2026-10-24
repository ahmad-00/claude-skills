# Standards and tool versions (last verified: 2026-10-25)

Re-verify anything marked **verify** before relying on it.

## Standards

| Standard | Current | Notes |
|---|---|---|
| OWASP Top 10 | 2025 edition | Categories: A01 Broken Access Control (now includes SSRF), A02 Security Misconfiguration, A03 Software Supply Chain Failures (new), A04 Cryptographic Failures, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures, A10 Mishandling of Exceptional Conditions (new) |
| OWASP ASVS | 5.0.0 (May 2025) | 17 chapters, 3 levels |
| OWASP API Security Top 10 | 2023 | Still current |
| OWASP MASVS / MASTG | MASVS 2.1.0; MASTG 2.0 (2026) | Mobile |
| OWASP WSTG | 4.2 | **verify** for a newer release |
| OWASP Top 10 for LLM Applications | 2025 list widely cited; 2026 edition published Aug 2026 | Prompt injection remains #1; **verify** 2026 numbering before citing |
| CWE Top 25 | 2025 edition (Dec 2025) | #1 XSS, #2 SQLi, #3 CSRF, #4 Missing Authorization |
| CVSS | 4.0 | NVD publishes 3.1 and 4.0 side by side |
| EPSS | v4 (Mar 2025) | 30-day exploitation probability |
| NIST SSDF | SP 800-218 v1.1; v1.2 draft | — |
| SLSA | 1.2 | — |
| SBOM | CycloneDX 1.7; SPDX 3.0.1 | — |

## Tools

| Tool | Version | Notes |
|---|---|---|
| Semgrep CE | 1.182.x | Rulesets `p/django`, `p/nextjs`, `p/kotlin`, `p/swift`, `p/terraform`, `p/secrets`, `p/owasp-top-ten` |
| gitleaks | 8.30.x | Use `gitleaks git` / `gitleaks dir`; `detect`/`protect` are deprecated. Project is in maintenance mode (**verify** successor status) |
| TruffleHog | v3 | `--only-verified` contacts providers: authorization needed |
| osv-scanner | 2.x | `osv-scanner scan` |
| Trivy | 0.76.x | **Caution:** Trivy's release pipeline was compromised in early 2026 (a malicious 0.69.4 build and tampered GitHub Actions). Pin versions, verify checksums, pin actions to SHAs |
| pip-audit | current | — |
| uv audit | preview (June 2026) | `uv audit`; reads `uv.lock` |
| Checkov | current | — |
| tfsec | deprecated | Merged into Trivy (`trivy config`) |
| OWASP ZAP | 2.17.x | `ghcr.io/zaproxy/zaproxy:stable`; automation framework YAML |
| Nuclei | current | Keep templates updated; non-intrusive tags only by default |
| Schemathesis | current | OpenAPI fuzzing |
| MobSF | current | Docker image `opensecurity/mobile-security-framework-mobsf` |
| Prowler | 5.x (**verify**) | GCP posture |
| GitHub Code Security / Secret Protection | GA | Sold separately since April 2025; free on public repos |

## Recent advisories worth knowing (Oct 2026)

- Django 6.1.2 / 6.0.9 / 5.2.18 (Oct 6, 2026) fixed several DoS and request-forgery issues; DRF 3.18.2 (Oct 21, 2026) fixed JSON parser upload-limit bypass and DoS issues.
- Next.js 16.4.1 / 15.5.28 (Oct 14, 2026) fixed a critical RCE in `use cache` with typed arguments, a critical RCE in image optimization with SVG, and a Server Actions DoS. React Server Components RCE (CVE-2025-55182, Dec 2025) requires React ≥ 19.0.1/19.1.2/19.2.1 and a patched `next`.
- Terraform google provider 8.7.0 (Oct 13, 2026) is bug-fix only.

## Old patterns → replacement

| Old | Replace with |
|---|---|
| `gitleaks detect` / `gitleaks protect` | `gitleaks git` / `gitleaks dir` |
| tfsec | `trivy config` |
| CVSS 3.1 only | CVSS 4.0 vector + EPSS + KEV |
| OWASP Top 10 2021 mapping | OWASP Top 10:2025 |
| "Vulnerable and Outdated Components" | A03:2025 Software Supply Chain Failures |
