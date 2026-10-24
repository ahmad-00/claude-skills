# GCP / Terraform review checklist (impact-ranked)

## Blockers

1. Service-account keys created, committed or stored in CI secrets for new setups.
2. Secrets in `.tf`, `.tfvars`, outputs (non-sensitive) or state without write-only attributes.
3. `allUsers`/`allAuthenticatedUsers` on non-public buckets/services; basic roles on workloads.
4. Plan destroys/replaces a stateful resource; missing `prevent_destroy`/`deletion_protection`.
5. WIF provider without `attribute_condition`.
6. Provider unpinned or `.terraform.lock.hcl` not committed; relying on a default that changed in 8.0.
7. `google_*_iam_policy`/`_iam_binding` clobbering bindings managed elsewhere.

## Should-fix

1. Project-level IAM where resource-level suffices.
2. Missing labels (env, team, cost-center) and budgets.
3. Public IPs on databases/VMs; missing private connectivity.
4. Cloud Run without explicit ingress, concurrency, or max instances; images deployed by mutable tag.
5. No backups/PITR on Cloud SQL; no versioning on the state bucket.
6. Hard-coded project IDs/regions instead of variables; copy-pasted env directories drifting.
7. Missing CI checks (fmt, validate, tflint/checkov) or plan output not attached to PRs.

## Nits

- Naming conventions, variable descriptions, `for_each` vs `count` style.

## Finding format

`modules/lb/main.tf:18` **[blocker]** `google_compute_backend_service.api` has no `load_balancing_scheme`; provider 8 defaults to `EXTERNAL_MANAGED`, which will replace the classic LB.
Fix: `load_balancing_scheme = "EXTERNAL"` now; plan a separate migration to `EXTERNAL_MANAGED`.
