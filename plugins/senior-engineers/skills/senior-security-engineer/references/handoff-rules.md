# Handoff rules

The security skill reports; the owner fixes. For code in a stack covered by a sibling skill, invoke that skill (Skill tool) with the finding block and let it implement, test and run its own validate loop. Then re-test the finding.

## Finding → owner

| Finding type | Owner skill | What to include in the handoff |
|---|---|---|
| Django/DRF authz, injection, settings, CSRF/CSP, dependency bumps | `senior-django-backend` | finding block + affected view/serializer/model + test expectation |
| Next.js Server Action authz, middleware-only auth, client-bundle secrets, RSC/next version floors, XSS sinks | `senior-nextjs-frontend` | finding block + route/action + required version |
| iOS Keychain/ATS/TLS/pinning, secrets in binary, privacy manifest | `senior-ios-swiftui` | finding block + file + MASVS control |
| Android exported components, cleartext, WebView, secrets in BuildConfig, debuggable builds | `senior-android-kotlin` | finding block + manifest/component + MASVS control |
| GCP IAM, SA keys, public buckets, firewall, Terraform provider/security defaults, CI credentials | `senior-devops-gcp` | finding block + resource address + expected HCL |
| Anything else (other languages, vendor products, process gaps) | owning team (ticket) | ticket-ready block below |

## Ticket-ready block (for owners without a skill)

```
Title: [SEC-003] IDOR on GET /api/orders/{id}
Severity: High · CWE-639 · OWASP A01:2025
Repro: as a non-admin user, request another user's order id → 200
Fix (acceptance criteria): requests for orders the user doesn't own return 404; regression test added
Deadline: <per severity policy>   Reporter: security review <date>
```

## After handoff

- Ask the owner skill to report what changed (files, tests) and run its validate loop.
- Re-test the exact repro. Only then mark the finding Fixed (verified).
- If the owner proposes "risk accepted", record who accepted it and a review date.
