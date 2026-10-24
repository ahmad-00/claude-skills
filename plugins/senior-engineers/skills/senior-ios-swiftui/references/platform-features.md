# Optional platform features (only if the project uses them)

## Contents
- Push notifications (APNs)
- StoreKit 2 in-app purchases and subscriptions
- HealthKit
- Widgets and Live Activities
- App Intents
- Privacy manifest

## Push notifications (APNs)

- Request authorization in context (after the user sees value), not at launch.
- Register via `UIApplication.shared.registerForRemoteNotifications()`; send the device token to the backend over an authenticated call; tokens change, so re-send on each launch.
- Use a Notification Service Extension for rich/encrypted payloads; keep payload data minimal and non-sensitive.

## StoreKit 2

- Load products with `Product.products(for:)`; purchase with `product.purchase()`; always `await transaction.finish()` after delivering content.
- Listen to `Transaction.updates` from app launch (renewals, refunds, Ask to Buy).
- Entitlements: derive from `Transaction.currentEntitlements`; verify `VerificationResult`.
- Server: use the App Store Server API / Server Notifications V2 as the source of truth for subscription state when there is a backend.
- Test with StoreKit configuration files.

## HealthKit

- Request the narrowest read/write types; explain each in `NSHealthShareUsageDescription`/`NSHealthUpdateUsageDescription`.
- Read authorization status is not revealed for privacy; design for "no data" rather than "denied".
- Never send health data to third parties or ads/analytics SDKs.

## Widgets and Live Activities

- Widgets: `TimelineProvider` with sensible reload policies; share data through App Groups; keep views lightweight.
- Live Activities: ActivityKit; respect update budgets; end activities when done; push updates via APNs with the `liveactivity` push type.

## App Intents

- Expose key actions as `AppIntent`s for Shortcuts, Spotlight and Siri; keep `perform()` fast and idempotent.

## Privacy manifest

- `PrivacyInfo.xcprivacy` declares collected data types, tracking domains and required-reason API usage (e.g. UserDefaults, file timestamps, system boot time).
- Third-party SDKs must ship their own manifests and signatures; update SDKs that don't.
