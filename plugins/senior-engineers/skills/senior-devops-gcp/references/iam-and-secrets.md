# IAM, identity and secrets

## GitHub Actions → GCP via WIF

```hcl
resource "google_iam_workload_identity_pool" "ci" { workload_identity_pool_id = "ci" }

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.ci.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  attribute_mapping = {
    "google.subject" = "assertion.sub", "attribute.repository" = "assertion.repository", "attribute.ref" = "assertion.ref"
  }
  attribute_condition = "assertion.repository == 'ORG/REPO' && assertion.ref == 'refs/heads/main'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
```

```yaml
permissions: { contents: read, id-token: write }
steps:
  - uses: actions/checkout@v5          # use the project's pinned version
  - uses: google-github-actions/auth@v3
    with:
      workload_identity_provider: ${{ vars.WIF_PROVIDER }}
      service_account: ${{ vars.DEPLOY_SA }}
```

Always set an `attribute_condition`. A pool without one trusts every GitHub repository.

## Service accounts

- One SA per workload; no default compute SA for workloads.
- Deploy SA: `roles/run.developer` (or narrower) + `roles/iam.serviceAccountUser` on the runtime SA only.
- Prefer resource-level bindings (`google_*_iam_member`) over project-level. Never use `_iam_policy` / `_iam_binding` on shared resources unless the module owns all members (they overwrite).
- Use Privileged Access Manager or time-bound IAM conditions for break-glass elevation.

## Secrets

- Secret Manager per env; accessors granted per secret to the runtime SA.
- Terraform: create the secret container in IaC; inject versions out of band, or with write-only attributes:
  ```hcl
  resource "google_secret_manager_secret_version" "db" {
    secret                 = google_secret_manager_secret.db.id
    secret_data_wo         = var.db_password   # ephemeral/sensitive input, not stored in state
    secret_data_wo_version = 1                  # bump to rotate
  }
  ```
  Requires Terraform ≥ 1.11 / OpenTofu ≥ 1.11 and provider ≥ 7; check the attribute names in the provider docs for your version.
- Cloud Run: reference secrets as env vars or volumes pinned to a version, or `latest` with a restart policy.
