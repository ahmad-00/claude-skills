# Authorization and rules of engagement

## Contents
- When authorization is required
- Authorization checklist
- Rules-of-engagement template
- Hard limits
- Disclosure

## When authorization is required

| Activity | Needs explicit authorization? |
|---|---|
| Reading code, configs, lockfiles, IaC the user provides | No |
| Running local scanners on the repo (secrets, SAST, dependency, IaC) | No |
| Querying public advisory databases (OSV, NVD, EPSS, KEV) | No |
| Any request to a running host, API or app (recon, scanning, fuzzing, auth tests) | **Yes** |
| Credential verification against live services (e.g. TruffleHog verify) | **Yes** |
| Mobile dynamic instrumentation (Frida/objection) on a device | **Yes** (device and app owned by user) |
| Social engineering, physical, or third-party systems | Out of scope for this skill |

## Authorization checklist (confirm in the conversation)

1. Authorizing party and their authority (owner, CTO, security lead, or published VDP/bug-bounty scope URL).
2. In-scope assets: domains, IP ranges, repos, apps, accounts, cloud projects. Everything not listed is out of scope.
3. Environment: staging/test preferred. Production needs explicit approval and read-only, rate-limited probes.
4. Time window and rate limits.
5. Test accounts to use (never real customer accounts).
6. Stop conditions and a contact for emergencies.
7. Data handling: evidence stored where, redaction rules, retention.

## Rules-of-engagement template (paste into the report)

```
Authorized by: <name, role>            Date: <date>
Scope: <assets>                        Out of scope: <assets>
Environment: <staging|prod (read-only)> Window: <start–end, timezone>
Test accounts: <ids>                   Rate limit: <req/s>
Permitted: recon, non-intrusive scanning, manual auth/logic tests, safe PoC
Not permitted: DoS, brute force, destructive tests, data exfiltration, third-party systems
Stop contact: <name, channel>
```

## Hard limits (not negotiable)

- No malware, ransomware, command-and-control, botnet, or denial-of-service tooling.
- No weaponized exploit chains. Verification means the smallest safe request that proves the issue.
- No bulk reads of real user data. One masked record is proof.
- No lateral movement into systems outside the written scope.
- No modification of production data or configuration during testing.
- Comply with applicable law and the target's disclosure policy.

## Disclosure

- Findings are confidential to the authorizing party until fixed.
- If a finding affects a third party (a vendor library, a SaaS provider), recommend coordinated disclosure to that party with a reasonable deadline (90 days is the common norm) and do not publish details before then.
- Record the disclosure plan in the report.
