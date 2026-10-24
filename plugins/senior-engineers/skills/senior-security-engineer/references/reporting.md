# Report format

## Structure

1. **Executive summary** (3–6 lines): what was tested, the overall risk, the top 3 actions.
2. **Scope and method**: rules of engagement, environments, dates, tools and versions, what was *not* tested.
3. **Findings table**: ID, title, severity, CWE, owner/handoff, status.
4. **Findings** (one block each, sorted by severity).
5. **Positive observations**: controls that worked (keeps the report credible).
6. **Appendix**: raw scanner outputs (SARIF/JSON), request logs, SBOM.

## Finding block

```
### SEC-003 · IDOR on /api/orders/{id}
Severity: High (CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N = 7.1)   KEV: no   EPSS: n/a
CWE-639 · OWASP A01:2025 · ASVS 5.0 V8
Location: apps/orders/api/views.py:42 (OrderViewSet.get_queryset) · endpoint GET /api/orders/{id}
Evidence: as user A (id 17), GET /api/orders/9031 → 200 with user B's order (fields masked in appendix)
Impact: any authenticated user can read every order, including addresses and last-4 card digits
Likelihood: trivial; IDs are sequential
Remediation: scope the queryset to the requesting user (Order.objects.filter(owner=request.user)); add a test that asserts 404 for another user's order; consider non-sequential public IDs
Owner: senior-django-backend (handed off) · Status: Handed off
References: OWASP Authorization Cheat Sheet; CWE-639
```

Rules: evidence is mandatory; a finding without evidence is labeled "Hypothesis" and goes in a separate list. Mask real user data. Remediation is a spec, not a diff, unless a one-line patch sketch makes it clearer.

## Statuses

Open → Confirmed → Handed off → Fixed (verified on <date>) / Risk accepted (by whom, until when) / False positive (why).

## SARIF normalization

Scanner SARIF files are inputs, not the report. `scripts/merge_sarif.py` de-duplicates on (rule, file, line) and prints a Markdown table with tool, rule, level, location. From that table, triage each row into Confirmed / False positive / Needs dynamic check before writing finding blocks. Keep the merged table in the appendix.
