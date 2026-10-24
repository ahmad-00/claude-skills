# GCP tooling versions (last verified: 2026-10-24)

## IaC

| Item | Current | Notes |
|---|---|---|
| Terraform | 1.17.x | — |
| OpenTofu | 1.13.x | Write-only attributes need OpenTofu ≥ 1.11 |
| google provider | 8.x (8.0.0 released 2026-08) | See provider-8-upgrade.md |
| google provider 7.0 | — | Added write-only attributes (Terraform ≥ 1.11) and ephemeral resources |
| HashiCorp agent skills | hashicorp/agent-skills | Complementary Terraform style/module skills |

## CI

| Item | Current | Notes |
|---|---|---|
| google-github-actions/auth | v3 | Node 24; removed old parameters. Pin `@v3` |
| google-github-actions/setup-gcloud | v2 in official examples (**verify** v3) | — |

## Cloud Run status

| Feature | Status |
|---|---|
| Worker pools | GA (Cloud Deploy support GA) |
| Built-in IAP (`--iap`) | GA |
| Multi-region services | GA |
| Automated multi-region failover/failback | Preview |
| Direct VPC egress | available |
| GPUs for services/jobs | available (**verify** worker-pool GPU status) |
| Budget spend caps for Cloud Run | **verify** |

## Other statuses to verify before relying on them

- **verify:** GKE built-in Autopilot ComputeClass on Standard clusters (1.34.1-gke.1829001+).
- **verify:** GKE Gateway API GA/default status.
- **verify:** WIF for GKE `principal://` direct KSA grants.
- **verify:** Secret Manager regional secrets GA; Privileged Access Manager GA.
- **verify:** Security Command Center Enterprise tier deprecation (shutdown reported for 2027-05-21).
- **verify:** Cloud Foundation Fabric / FAST current release.

## Old patterns / deprecated → replacement

| Old | Replace with |
|---|---|
| SA JSON keys in CI (`credentials_json`) | WIF with `google-github-actions/auth@v3` |
| GKE Workload Identity via KSA→GSA impersonation annotations (new setups) | WIF for GKE `principal://` grants to KSA directly |
| Serverless VPC Access connector (new services) | Direct VPC egress |
| `google_iap_brand` / `google_iap_client` | Removed in provider 8; manage OAuth clients outside Terraform or use Cloud Run built-in IAP |
| Legacy Notebooks (`google_notebooks_*`) | `google_workbench_instance` |
| BeyondCorp app connections/connectors/gateways | `google_beyondcorp_security_gateway` (+ application) |
| `google_vertex_ai_schedule` | `google_colab_schedule` |
| Secrets in `variable` + state | write-only attributes (`*_wo` + `*_wo_version`), ephemeral resources |
| Container Registry (gcr.io) | Artifact Registry |
| Cloud Run "always on CPU" workarounds for queue consumers | worker pools |
