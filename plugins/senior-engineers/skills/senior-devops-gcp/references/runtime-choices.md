# Runtime choices and networking

## Cloud Run

| Workload | Use |
|---|---|
| HTTP/gRPC request-driven | Service |
| Run-to-completion batch / cron (with Cloud Scheduler) | Job |
| Pull-based consumers (Pub/Sub pull, Kafka, queues), always-on background work | Worker pool |
| Internal tool needing SSO | Service with built-in IAP |
| Active-active across regions | Multi-region service (automated failover is Preview) |

Settings to decide explicitly: CPU allocation (request-only vs always), concurrency, min/max instances, timeout, ingress (`internal`, `internal-and-cloud-load-balancing`, `all`), egress (Direct VPC egress), execution environment, startup/liveness probes.

## GKE

- Autopilot by default: you pay per pod resource request; security posture is managed.
- Standard only for custom node configuration, specific GPUs/TPUs, or DaemonSet-heavy needs; use ComputeClass for autoscaling node shapes.
- Ingress: Gateway API (GKE Gateway controller); avoid new legacy Ingress objects.
- Identity: WIF for GKE; grant IAM roles to `principal://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/PROJECT_ID.svc.id.goog/subject/ns/NAMESPACE/sa/KSA`.
- Release channel: Regular; maintenance windows and exclusions set; PodDisruptionBudgets for critical workloads.

## Networking

- Shared VPC for multi-project orgs; subnets per region per env.
- Cloud NAT for egress from private resources; fixed egress IPs only when a partner needs allowlisting.
- Cloud SQL via private IP / PSC; Memorystore via PSC.
- External Application Load Balancer (`EXTERNAL_MANAGED`) + Cloud Armor for public multi-backend entry points.
