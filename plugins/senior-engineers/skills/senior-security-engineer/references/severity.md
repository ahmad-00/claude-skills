# Severity and prioritization

## Method (in order)

1. **CISA KEV**: if the CVE is in the Known Exploited Vulnerabilities catalog, priority is Critical regardless of score. Fix or mitigate now.
2. **CVSS 4.0** base vector for intrinsic technical severity. Record the full vector, e.g. `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N`. If a source only has a 3.1 score, say so.
3. **EPSS** (CVE-based findings only): probability of exploitation in the next 30 days. Use it to order items inside a severity band and to justify fast-tracking a Medium with high EPSS.
4. **Context adjustment**, stated explicitly: internet exposure, authentication required, data sensitivity, blast radius, compensating controls (WAF, network isolation), ease of detection.

Severity bands for the report: Critical (9.0–10.0), High (7.0–8.9), Medium (4.0–6.9), Low (0.1–3.9), Info. For non-CVE findings (logic flaws, missing authz), score the CVSS vector yourself and explain the choices.

## Priority decision (SSVC-style)

| Exploitation | Exposure | Impact | Decision |
|---|---|---|---|
| Active (KEV) or PoC public | Internet-facing | High | **Act now** (hours) |
| PoC public or trivial | Internet-facing | Medium/High | **Attend** (this week) |
| None known | Internal or authenticated | Any | **Track** (next sprint) |
| None known | Internal, low impact | Low | **Track** (backlog) |

## Worked example

Finding: `GET /api/orders/{id}` returns any order; queryset is not filtered by the requesting user.

- CWE-639, OWASP A01:2025 Broken Access Control, ASVS V8 (authorization)
- CVSS 4.0: `AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N` → 7.1 High (any authenticated user, full read of others' orders, no integrity impact)
- EPSS: n/a (not a CVE)
- Context: internet-facing, self-service signup, orders contain addresses and partial card data → keep High; recommend **Attend** (fix this week). Would be Critical if it exposed credentials or allowed writes.

## Don'ts

- Don't rate by tool output alone; scanners don't know exposure or data sensitivity.
- Don't inflate severity to get attention; explain impact instead.
- Don't downgrade a KEV item because "we're small".
