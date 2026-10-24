# Changelog

## 1.1.0 (2026-10-25)

- New skill `senior-security-engineer`: findings-only security reviews and authorized pentests (authorization gate, local scans with SARIF merge, review checklists, CVSS 4.0 + EPSS + KEV triage, report template, handoff rules).
- New `security-audit` subagent that runs the security skill without edit tools.
- Engineer skills: section on receiving a security handoff; refreshed version facts (Django/DRF and Next.js security releases of October 2026, google provider 8.7.0).
- Plugin version lives only in `marketplace.json` and `plugin.json`; removed `metadata.version` from skills; validator enforces it.
- Removed `scripts/install.sh`; the plugin marketplace is the single install path.

## 1.0.0 (2026-10-24)

- Five generic, project-agnostic skills: senior-django-backend, senior-nextjs-frontend, senior-ios-swiftui, senior-android-kotlin, senior-devops-gcp.
- Each skill: Step 0 version detection script, one-default-per-decision tables, validate → fix → repeat workflows, review mode with severities, versions.md with last-verified dates.
- Repo works as a Claude Code plugin marketplace (`eng-skills`) and via `scripts/install.sh` symlinks.
