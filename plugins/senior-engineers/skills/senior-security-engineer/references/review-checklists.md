# Manual review checklists

## Contents
- Authorization and access control
- Authentication and sessions
- Input handling and injection
- Secrets and configuration
- Cryptography
- Logging, errors, monitoring
- Supply chain and CI
- Per-stack top findings

Each item: what to look for → where to look → CWE. Report with evidence (file:line or request).

## Authorization and access control (A01:2025)

- Object-level checks on every read/write by ID (IDOR) → handlers, querysets, repository methods → CWE-639/CWE-862
- Function-level checks on admin/management endpoints and background jobs → routers, decorators, middleware → CWE-285
- Multi-tenant scoping on every query; never trust tenant ID from the client → data layer → CWE-863
- Mass assignment: writable fields limited to what the user may set → serializers, DTOs → CWE-915
- SSRF: outbound requests with user-controlled URLs; metadata endpoints reachable → HTTP clients, webhooks, image fetchers → CWE-918

## Authentication and sessions (A07:2025)

- Password hashing: Argon2id/bcrypt/scrypt/PBKDF2 with current parameters → auth config → CWE-916
- Brute-force limits on login, OTP, reset, and enumeration-safe error messages → auth endpoints → CWE-307
- Session: secure, HttpOnly, SameSite cookies; rotation at login; server-side invalidation at logout → session config → CWE-384
- Tokens: short-lived access tokens, rotated refresh tokens, audience/issuer checks, no `alg=none` → JWT code → CWE-347
- OAuth/OIDC: `state` and PKCE, exact redirect URI match → OAuth client → CWE-352/CWE-601
- MFA bypass paths (recovery codes, remember-device) → account flows → CWE-287

## Input handling and injection (A05:2025)

- SQL/NoSQL/ORM raw queries with string formatting → data layer → CWE-89/CWE-943
- OS command and template injection → subprocess, template engines → CWE-78/CWE-1336
- Path traversal in file reads, uploads, downloads → file handlers → CWE-22
- Deserialization of untrusted data (pickle, Java/Kotlin serialization, YAML load) → parsers → CWE-502
- File upload: type/size validation, storage outside web root, no execution → upload handlers → CWE-434
- XSS: unsafe HTML sinks, `dangerouslySetInnerHTML`, `|safe`, WebView JS bridges → templates, components → CWE-79
- CSRF on state-changing requests with cookie auth → forms, actions, webhooks → CWE-352

## Secrets and configuration (A02:2025, A04:2025)

- Secrets in code, images, logs, client bundles, mobile binaries → grep, scanners, build output → CWE-798
- Debug mode, verbose errors, default credentials in deployed config → settings, env → CWE-489/CWE-1188
- CORS allow-lists, CSP, HSTS, security headers → middleware/proxy config → CWE-942/CWE-1021
- Cloud: public buckets, SA keys, over-broad IAM, open firewall, missing encryption at rest → IaC → CWE-284/CWE-732
- Admin interfaces exposed to the internet without SSO/IP restriction → ingress config → CWE-306

## Cryptography (A04:2025)

- Weak/legacy algorithms (MD5/SHA1 for integrity, ECB, RC4, static IVs) → crypto helpers → CWE-327/CWE-329
- Insecure randomness for tokens (`random` instead of `secrets`/CSPRNG) → token generation → CWE-338
- Key management: keys in repo, no rotation, same key across environments → config → CWE-321
- TLS: disabled verification, pinned certificates without rotation plan → HTTP clients, mobile → CWE-295

## Logging, errors, monitoring (A09:2025, A10:2025)

- Sensitive data in logs (tokens, passwords, PII) → logging config, log calls → CWE-532
- Stack traces or internal details returned to users → error handlers → CWE-209
- Exceptions swallowed in security paths (auth, payment) leading to fail-open → try/except blocks → CWE-636
- No alerting on auth failures, privilege changes, admin actions → monitoring config → CWE-778

## Supply chain and CI (A03:2025, A08:2025)

- Unpinned dependencies, no lockfile in CI, install scripts from untrusted packages → manifests, CI → CWE-1357
- GitHub Actions on mutable tags; `pull_request_target` with checkout of PR code; secrets exposed to forks → workflows → CWE-829
- Container base images on `latest`; no image signing or provenance → Dockerfiles, deploy → CWE-494
- Long-lived CI credentials instead of OIDC/WIF → CI config → CWE-798

## Per-stack top findings (what to look for first)

| Stack | Look for first |
|---|---|
| Django/DRF | unscoped `get_queryset()` / IDOR; `DEBUG`, missing `SECURE_*`/CSP; raw SQL with formatting; CSRF-exempt views; outdated Django/DRF with known CVEs |
| Next.js | Server Actions without auth/ownership checks; auth only in `proxy.ts`/middleware; secrets in client bundles; outdated `next` below a patched floor; `dangerouslySetInnerHTML` |
| iOS | tokens outside Keychain; ATS exceptions; disabled TLS validation; secrets in the binary or plist; missing privacy manifest |
| Android | exported components without permissions; `usesCleartextTraffic`; WebView with JS bridges or file access; secrets in `BuildConfig`/resources; debuggable release builds |
| GCP/Terraform | SA JSON keys; `allUsers` bindings; basic roles (owner/editor); public IPs on databases; missing `deletion_protection`; secrets in state; WIF providers without attribute conditions |
