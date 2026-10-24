# Django stack versions (last verified: 2026-10-25)

Re-verify anything marked **verify** before relying on it.

## Core

| Component | Current | Notes |
|---|---|---|
| Django 6.1 | 6.1.2 | Released 2026-08-05; Python 3.12–3.14; drops PostgreSQL 14; supported until 2027-12. 6.1.2 / 6.0.9 / 5.2.18 (2026-10-06) are security releases: DoS in language-variant lookup and HTTP header parsing, request forgery via byte values in spatial lookups, privilege abuse in model formsets with editable PKs. Treat anything older as a security finding |
| Django 6.0 | 6.0.9 | Mainstream support ended 2026-08; security fixes until 2027-04 |
| Django 5.2 LTS | 5.2.x | Supported until 2028-04 |
| DRF | 3.18.2+ | 3.18.0 drops Django 4.2/5.0/5.1; list serializer (`many=True`) errors are now a dict. 3.18.2 (2026-10-21) fixes a `JSONParser` upload-limit bypass and two DoS issues; 3.17.2 fixed an AdminRenderer data leak. Floor for security reviews: 3.18.2 |
| DRF 3.17 | 3.17.0 | First release officially supporting Django 6.0 and Python 3.14; dropped Python 3.9 and coreapi |
| Calendar versioning | DEP 20 | Majors after 6.x are named by year (e.g. "Django 2028") (**verify** final naming) |

## Features by version

- **5.1**: psycopg 3 connection pool via `DATABASES[...]["OPTIONS"]["pool"]`; `LoginRequiredMiddleware`.
- **6.0**: template partials; `django.tasks` (API only; ships Immediate and Dummy backends, **no production worker**); built-in CSP via `SECURE_CSP`.
- **6.1**:
  - `QuerySet.fetch_mode(FETCH_ONE | FETCH_PEERS | FETCH_RAISE)`.
  - `on_delete=DB_CASCADE | DB_SET_NULL | DB_SET_DEFAULT`, which run in the database and skip signals.
  - The `MAILERS` setting replaces `EMAIL_*` settings (deprecated).
  - PBKDF2 iterations raised.
  - 6.1.1 fixed regressions in `from_db()` overrides and `__in` lookups on annotations. Use ≥ 6.1.1.

### fetch_mode gotchas (community-reported, **verify** against your version)

- `FETCH_PEERS` combined with `.iterator()` silently does nothing.
- It does not help reverse/many relations (`author.books.all()`); keep `prefetch_related`.
- Overriding `Model.from_db()` without the `fetch_mode` kwarg is deprecated.

## Background tasks

- `django.tasks` needs a third-party backend for production, such as the `django-tasks` package (database backend plus worker). **verify** current package names/versions.
- Celery 5.x: use it when you need beat scheduling, chains/chords, routing, or rate limits.

## Alternatives

- django-ninja: typed, Pydantic-based, async-friendly API layer. **verify** current version and Django 6.1 support before adopting.
- uv: default packaging tool in this skill; **verify** project CI supports it.

## Old patterns / deprecated APIs → replacement

| Old | Replace with | Since |
|---|---|---|
| `EMAIL_BACKEND`, `EMAIL_HOST`, … | `MAILERS = {"default": {...}}` | 6.1 (deprecated) |
| `DEFAULT_FILE_STORAGE`, `STATICFILES_STORAGE` | `STORAGES` | removed 5.1 |
| `Meta.index_together` | `Meta.indexes` | removed 5.1 |
| psycopg2 | psycopg 3 (`psycopg[binary,pool]`) | — |
| `django-csp` middleware (new projects) | `SECURE_CSP` | 6.0 |
| DRF coreapi schemas | drf-spectacular / OpenAPI | removed in DRF 3.17 |
| `pytz` | `zoneinfo` | removed 5.0 |
| Manual N+1 hunting on FK access | `fetch_mode(FETCH_PEERS)` + `FETCH_RAISE` in tests | 6.1 |
