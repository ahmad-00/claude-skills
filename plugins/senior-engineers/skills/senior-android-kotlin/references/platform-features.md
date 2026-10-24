# Optional platform features (only if the project uses them)

## Contents
- Firebase Cloud Messaging (FCM)
- Google Play Billing
- Health Connect
- Foreground services
- Credential Manager

## FCM

- Request `POST_NOTIFICATIONS` (API 33+) in context.
- `onNewToken` → send to backend authenticated; tokens rotate.
- Data messages for app logic; keep payloads non-sensitive; heavy work via WorkManager, not in `onMessageReceived`.
- Create notification channels at startup with user-meaningful names.

## Google Play Billing

- One `BillingClient` per app with reconnect logic.
- The purchase flow doesn't end at `launchBillingFlow`: handle `PENDING`, verify on your backend (Play Developer API), then acknowledge or consume within 3 days or the purchase is refunded.
- Query purchases on app start and on resume to recover missed updates.
- Track the deprecation schedule in versions.md.

## Health Connect

- Declare only the needed permissions in the manifest; provide the privacy-policy rationale activity.
- Check SDK availability (`HealthConnectClient.getSdkStatus`) and handle "update required".
- Request permissions with the Health Connect contract; read with time-range filters and paging; write with client record IDs for idempotency.
- Never transfer health data to ads/analytics SDKs.

## Foreground services

- Declare `foregroundServiceType` and the matching `FOREGROUND_SERVICE_*` permission (API 34+).
- Prefer WorkManager (including expedited and long-running workers) unless the user is actively aware of the ongoing task.
- Respect start restrictions from background; show a meaningful notification.

## Credential Manager

- Use `CredentialManager.getCredential` with passkey, password and Sign in with Google options in one request.
- Server validates passkey assertions; store only public keys server-side.
- Handle `NoCredentialException` by offering sign-up; don't loop prompts.
