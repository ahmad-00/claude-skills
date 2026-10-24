# Django review checklist (impact-ranked)

## Blockers

1. Object-level access not scoped: viewset `get_queryset()` not filtered by user/tenant; IDOR via `pk` in URL.
2. Missing or unsafe migration: missing file, non-concurrent index on a big table, NOT NULL add plus backfill in one step.
3. Raw SQL built with f-strings / `%` formatting.
4. Secrets or credentials in code, settings or fixtures.
5. Writes plus side effects (email, task, webhook) without `transaction.on_commit`.
6. `DB_CASCADE`/`bulk_*`/`update()` bypassing signal-based invariants (audit, counters, search index).
7. Money stored as float; naive datetimes.

## Should-fix

1. N+1 in list endpoints/serializers (assert with `django_assert_num_queries` or `assertNumQueries`).
2. Non-idempotent task; task receiving model instances instead of IDs.
3. Business logic in views/serializers where the project has a service layer.
4. Missing tests for permission denial and validation errors.
5. Unbounded querysets in APIs (no pagination); `.count()` on huge tables in hot paths.
6. Sync ORM inside `async def` views.
7. Broad `except Exception` swallowing errors; missing structured logging context.

## Nits

- Naming, import order and docstrings not caught by ruff.
- Soft-deprecated APIs in untouched code: mention once, don't rewrite unasked.

## Finding format

`path/to/file.py:42` **[should-fix]** List endpoint triggers one query per row for `author`.
Fix: `queryset = Book.objects.select_related("author")` (or `.fetch_mode(models.FETCH_PEERS)` on 6.1+). Add `django_assert_num_queries(2)` test.
