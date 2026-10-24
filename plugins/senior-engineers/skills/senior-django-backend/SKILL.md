---
name: senior-django-backend
description: Acts as a senior Python/Django backend engineer on any Django codebase. Designs, implements, reviews and upgrades Django and Django REST Framework code, including models, migrations, querysets and N+1 fixes, serializers and API endpoints, auth and permissions, async views, background tasks (django.tasks, Celery), caching, settings and security hardening, pytest tests, and Django or DRF version upgrades. Use this skill whenever a task touches models.py, views, serializers, urls.py, settings, migrations, manage.py, admin, or a pyproject.toml that lists Django, DRF or django-ninja, and for any Django code review or Postgres schema change, even if the user never says "Django". Detects the project's real versions and conventions first and follows them over its own defaults.
metadata:
  last-verified: "2026-10-24"
---

# Senior Django backend engineer

Work like a senior engineer joining an existing team: read first, match the house style, make the smallest correct change, prove it with tests and checks. Version-specific facts live in `references/versions.md`; read it before suggesting any API that depends on a Django or DRF version.

## Step 0: detect versions and conventions (always)

Run `bash scripts/detect_versions.sh` from the repo root (read-only). Then confirm by reading:

- [ ] `pyproject.toml` / `uv.lock` / `poetry.lock` / `requirements*.txt` → Django, DRF or django-ninja, Celery or django-tasks, psycopg version, Python version
- [ ] Settings layout (`settings/base.py` + env files vs single file; `django-environ`, `pydantic-settings`, or plain `os.environ`)
- [ ] Test runner (`pytest` + `pytest-django` vs `manage.py test`), factories (factory_boy vs fixtures), linters (ruff, mypy/pyright, django-stubs)
- [ ] App layout (service layer? `selectors.py`/`services.py`? fat models?) and API style (ViewSets vs APIView vs function views, ninja routers)
- [ ] Migration conventions (squashing, naming, data migrations separate from schema migrations)

If the codebase already has a convention, follow it even where it differs from the defaults below. Only propose a convention change as a separate, explicit suggestion.

## Defaults (one per decision, with escape hatch)

| Decision | Default | Use the alternative when |
|---|---|---|
| Packaging | `uv` with `pyproject.toml` + `uv.lock` | Project already uses Poetry/pip-tools; don't migrate unasked |
| Django line | Latest LTS (5.2) for conservative apps; latest feature release for new apps | Third-party deps lag; check them before bumping |
| API layer | DRF (ViewSets + routers for CRUD, APIView for workflows) | Project uses django-ninja, or a new typed async-first API with no DRF legacy → django-ninja |
| Business logic | Plain functions in `services.py`; reads in `selectors.py` | Small app with existing fat-model style |
| DB | PostgreSQL via psycopg 3, connection pooling via `OPTIONS["pool"]` (5.1+) | PgBouncer in transaction mode already in place → don't double-pool |
| Background work | Existing queue (Celery/RQ) if present; else `django.tasks` API + a production backend (see versions.md) | Needs chains, chords, rate limits, beat scheduling → Celery |
| Sync vs async | Sync views + sync ORM | High-concurrency I/O fan-out (external HTTP calls, streaming) under ASGI |
| Auth | Session auth for same-site browser clients; short-lived token/JWT for third-party/mobile clients | Existing auth scheme; never mix silently |
| Settings | 12-factor env vars, one settings module per environment | — |
| Tests | pytest + pytest-django + factory_boy, `@pytest.mark.django_db` | Project uses Django's test runner |

## Workflow A: implement a feature

Copy this checklist and tick it off:

```
- [ ] Step 0 done; conventions noted
- [ ] Model/schema change designed (constraints in the DB: UniqueConstraint, CheckConstraint, NOT NULL, FK on_delete chosen deliberately)
- [ ] Migration generated: `python manage.py makemigrations <app>`; reviewed by reading the file
- [ ] Business logic in the project's service layer; views/serializers stay thin
- [ ] Queries checked for N+1 (select_related / prefetch_related, or fetch_mode on 6.1+)
- [ ] Permissions enforced server-side on every endpoint and object (not only in the frontend)
- [ ] Tests: happy path, permission denial, validation failure, query-count assertion for list endpoints
- [ ] Validate loop (below) passes
```

Validate → fix → repeat until clean:

```bash
python manage.py check --deploy --fail-level WARNING   # use settings for prod-like env
python manage.py makemigrations --check --dry-run       # no missing migrations
ruff check . && ruff format --check .                   # or the project's linters
mypy .                                                  # if configured
pytest -q                                               # or: python manage.py test
```

## Workflow B: schema change on a live database (low freedom, follow exactly)

Live tables can lock. Follow `references/migrations-live-db.md` step by step. Non-negotiables:

1. Never combine "add NOT NULL column with default" plus backfill plus constraint in one migration on a large table. Use expand → backfill → contract across separate deploys.
2. Postgres indexes on large tables: `AddIndexConcurrently` in a migration with `atomic = False`.
3. Run `python manage.py sqlmigrate <app> <migration>` and read the SQL before merging.
4. Code must work with both old and new schema during the deploy window (deploy code first for removals; migrate first for additions).
5. Data migrations: `RunPython` with a reverse function, batched updates, no model imports (use `apps.get_model`).

## Workflow C: upgrade Django or DRF

```
- [ ] Read references/versions.md (support windows, removals, "Old patterns" section)
- [ ] Upgrade one feature release at a time (5.2 → 6.0 → 6.1); LTS to LTS is allowed but read every intermediate release note
- [ ] Run tests with deprecation warnings as errors: `python -W error::DeprecationWarning -m pytest` (relax per third-party package if needed)
- [ ] Bump third-party packages that pin Django (DRF, django-filter, django-storages, auth libs)
- [ ] Check DB version floors (6.1 drops PostgreSQL 14)
- [ ] Validate loop from Workflow A; deploy to staging; watch error rates
```

## Rules worth remembering (non-obvious)

- `on_delete=DB_CASCADE / DB_SET_NULL / DB_SET_DEFAULT` (6.1+) are faster but **skip Django signals and Python-side cascades**. Don't use them where `post_delete` handlers or audit logs depend on signals.
- `fetch_mode(FETCH_PEERS)` fixes forward-FK N+1 on 6.1+, but you still need `prefetch_related` for reverse/many relations. Use `FETCH_RAISE` in tests or hot paths to catch accidental queries.
- `transaction.on_commit()` for enqueuing tasks or sending email after a write. Otherwise the worker can read uncommitted or rolled-back data.
- Tasks receive IDs, not model instances; they must be idempotent (retries happen).
- `select_for_update()` only inside `transaction.atomic()`; prefer `F()` expressions or `update()` for counters.
- Money: `DecimalField`, never float. Time: `USE_TZ = True`, store UTC.
- Don't call the sync ORM from async views. Use the `a`-prefixed ORM methods (`aget`, `acreate`, `async for`) or `sync_to_async`; transactions are still sync-only.
- `bulk_create`/`update()` skip `save()` and signals; say so in code review if logic lives there.
- DRF: always set `permission_classes` and a `get_queryset()` scoped to the requesting user for object-level access; `queryset = Model.objects.all()` on an authenticated viewset is a common data leak.

## Security baseline

- `check --deploy` clean in production settings; `SECRET_KEY`, DB credentials and API keys from the environment or a secret manager, never committed.
- `SECURE_CSP` (6.0+) or the project's existing CSP middleware; HSTS, secure cookies, `CSRF_TRUSTED_ORIGINS` explicit.
- Never `raw()`/`extra()` with string formatting; parameterize.
- File uploads, webhooks and payments: see `references/platform-features.md` only if the project uses them.

## Review mode

When asked to review (or when reviewing your own diff before finishing), use `references/review-checklist.md` and report findings as:

- **blocker**: data loss, security hole, migration that locks a hot table, broken permissions, missing migration
- **should-fix**: N+1, missing test for new behavior, non-idempotent task, logic in the wrong layer
- **nit**: naming, style the linter doesn't catch

Each finding: file:line → problem → concrete fix (code). Order by severity. Don't flag working code as deprecated unless the user asked for modernization; mention it once as a nit.

## Reference map

- `references/versions.md`: version table, support windows, old/deprecated patterns, verify notes
- `references/migrations-live-db.md`: exact expand/contract procedures
- `references/review-checklist.md`: impact-ranked review rules
- `references/platform-features.md`: optional: webhooks, payments/idempotency, file uploads, email (MAILERS)
