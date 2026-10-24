# google provider 7.x → 8.x (exact procedure)

## Breaking changes to check (confirm against the official version_8_upgrade guide)

**Resources and data sources removed**
- `google_beyondcorp_app_connection`, `google_beyondcorp_app_connector`, `google_beyondcorp_app_gateway` → `google_beyondcorp_security_gateway`, `google_beyondcorp_security_gateway_application`
- `google_iap_brand`, `google_iap_client` (+ data source), no replacement
- `google_ml_engine_model`
- `google_notebooks_environment`, `google_notebooks_instance`, `google_notebooks_runtime` (+ IAM) → `google_workbench_instance`
- `google_vertex_ai_schedule` → `google_colab_schedule`

**Default changes**
- `load_balancing_scheme` on `google_compute_backend_service` and `google_compute_global_forwarding_rule` defaults to `EXTERNAL_MANAGED` instead of `EXTERNAL`. Unset values on classic LBs will plan a replacement.

**Field and validation changes**
- Several order-insensitive lists became sets (diff formatting changes; index-based references like `[0]` may break).
- Other field changes on BigQuery, Workflows, container and compute resources: read the guide sections for every resource type you use.

## Procedure (one environment at a time)

1. Pin `version = "~> 7.<latest>"`, run `terraform init -upgrade`, then `plan`. Fix every deprecation warning until the plan is a no-op.
2. Search the code for removed resources:
   `grep -rnE "google_(iap_brand|iap_client|notebooks_|ml_engine_model|vertex_ai_schedule|beyondcorp_app_)" .`
3. For each `google_compute_backend_service` / `google_compute_global_forwarding_rule`, set `load_balancing_scheme` explicitly to the current value.
4. For removed resources still in state: migrate to the replacement (`import` + `removed { from = ... lifecycle { destroy = false } }`), or `terraform state rm` after confirming the real resource must persist.
5. Bump to `~> 8.0`, `terraform init -upgrade`, commit `.terraform.lock.hcl` (include `-platform` hashes for CI OSes).
6. `terraform plan`: require **zero** replace/destroy on existing resources. Any replacement → stop, find the attribute, set it explicitly.
7. Apply in non-prod via the pipeline; soak; repeat for each env.

Rollback: revert the version pin and lock file, then restore state from the GCS object version if an apply partially ran.

OpenTofu: same breaking changes; write-only attributes need ≥ 1.11.
