# Schema changes on a live PostgreSQL database (exact procedures)

Use these whenever the table is large (roughly >1M rows) or hot (written every second). When unsure, assume it is.

## Add a required column

1. Migration 1: add the column as `null=True`, no default backfill. Deploy.
2. Code: write the new column on every insert/update. Deploy.
3. Migration 2 (`RunPython`, `atomic = False`): backfill in batches of 1–10k rows by primary key range, sleeping briefly between batches. Provide a no-op reverse.
4. Migration 3: `AddConstraint(CheckConstraint(condition=Q(col__isnull=False), name=...))`. Alternatively, add the constraint with `NOT VALID` via `RunSQL`, then `VALIDATE CONSTRAINT` separately.
5. Migration 4: `AlterField(null=False)` (cheap once a validated check constraint exists on PG 12+).

## Add an index

```python
from django.contrib.postgres.operations import AddIndexConcurrently
class Migration(migrations.Migration):
    atomic = False
    operations = [AddIndexConcurrently("order", models.Index(fields=["created_at"], name="order_created_idx"))]
```

If it fails midway, drop the INVALID index (`DROP INDEX CONCURRENTLY`) before retrying.

## Rename or drop a column

- Rename: add the new column → dual-write → backfill → switch reads → stop writing the old column → drop it. Never use `RenameField` on a hot table across a rolling deploy.
- Drop: remove all code references and deploy; then drop in the next release. Use `SeparateDatabaseAndState` if you must remove the field from state first.

## Foreign keys

- New FK on a big table: create it with `db_constraint=False` and add the constraint `NOT VALID` + `VALIDATE` via `RunSQL`.
- Choosing `DB_CASCADE` (6.1+) changes delete semantics: signals no longer fire for cascaded rows.

## Before merging (every time)

```bash
python manage.py sqlmigrate <app> <number>      # read the SQL
python manage.py migrate --plan                 # order across apps
python manage.py makemigrations --check --dry-run
```

Set `lock_timeout` (e.g. `SET lock_timeout = '5s'` via `RunSQL`) so a blocked migration fails fast instead of queueing every query behind it.
