# Optional integrations (only if the project uses them)

## Contents
- Webhooks (inbound)
- Payments and idempotency
- File uploads
- Email (MAILERS)

## Webhooks (inbound)

- Verify the signature on the raw body before parsing (`request.body`); use constant-time compare (`hmac.compare_digest`).
- Store the provider event ID with a unique constraint; return 200 for duplicates (providers retry).
- Acknowledge fast: persist the event, then process in a task via `transaction.on_commit`.
- Exempt only the webhook view from CSRF; never globally.

## Payments and idempotency

- Accept an `Idempotency-Key` header on create endpoints; store `(key, user, request_hash, response)` with a unique constraint and return the stored response on replay.
- Treat the provider as source of truth: reconcile with webhooks, never trust client-reported success.
- Amounts in minor units (integer) or `DecimalField`; store currency alongside.

## File uploads

- Storage via `STORAGES` (e.g. django-storages to an object store); never serve user uploads from the app domain without content-type checks.
- Validate size and type server-side; generate your own filenames; prefer direct-to-bucket signed uploads for large files.
- Scan or sandbox untrusted files if they are re-served.

## Email (MAILERS, Django 6.1+)

```python
MAILERS = {
    "default": {
        "BACKEND": "django.core.mail.backends.smtp.EmailBackend",
        "HOST": env("SMTP_HOST"), "PORT": 587, "USE_TLS": True,
        "HOST_USER": env("SMTP_USER"), "HOST_PASSWORD": env("SMTP_PASSWORD"),
    }
}
```

On older versions, keep `EMAIL_*` settings. Send mail from tasks, after commit.
