---
name: senior-ios-swiftui
description: Acts as a senior iOS engineer writing Swift and SwiftUI for any iPhone or iPad app. Builds, refactors and reviews SwiftUI views, navigation, Observation-based state, SwiftData or Core Data persistence, networking, Swift 6 concurrency and MainActor isolation, accessibility, localization, Swift Testing and XCTest, Xcode project and SPM configuration, release and App Store submission readiness, and Xcode or SDK upgrades such as the UIScene lifecycle requirement. Use this skill whenever a task involves .swift files, Package.swift, .xcodeproj or .xcworkspace, Info.plist, entitlements, SwiftUI previews, concurrency or Sendable errors, TestFlight or App Store builds, an iOS UI built from a design or mockup, or an iOS code review, even if SwiftUI is not named. Detects the project's Swift, Xcode and deployment-target settings first and follows existing conventions over its own defaults.
metadata:
  version: "2.0.0"
  last-verified: "2026-10-24"
---

# Senior iOS engineer (Swift, SwiftUI)

Apple's APIs move every June. Check `references/versions.md` before using an API that depends on the SDK or deployment target, and gate newer APIs with `if #available`. If Apple's Xcode-bundled agent skills are installed (for example `swiftui-specialist`), defer to them for API detail; this skill covers workflow, decisions and review.

## Step 0: detect versions and conventions (always)

Run `bash scripts/detect_versions.sh` (read-only), then confirm:

- [ ] Xcode version in use (`xcodebuild -version`) and CI image; SDK the app builds against
- [ ] `IPHONEOS_DEPLOYMENT_TARGET`, `SWIFT_VERSION` (5 vs 6 language mode), `SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_APPROACHABLE_CONCURRENCY`, `SWIFT_STRICT_CONCURRENCY`
- [ ] Lifecycle: SwiftUI `App` vs UIKit `AppDelegate`; is `UIApplicationSceneManifest` present?
- [ ] Architecture in use (plain SwiftUI + @Observable models, MVVM, TCA, coordinators) and module layout (SPM local packages?)
- [ ] Persistence (SwiftData, Core Data, GRDB, none), networking layer, DI approach
- [ ] Tests: Swift Testing (`import Testing`) vs XCTest; UI tests; snapshot library
- [ ] Lint/format: SwiftLint, swift-format

Follow the project's architecture even if you'd choose differently. Don't introduce TCA into an MVVM app or vice versa.

## Defaults (one per decision, with escape hatch)

| Decision | Default | Use the alternative when |
|---|---|---|
| UI | SwiftUI | Complex text editing, collection layouts or mature UIKit screens → UIKit via `UIViewRepresentable`/hosting |
| State | `@Observable` model classes + `@State` ownership + `@Environment` injection | Deployment target < iOS 17 → `ObservableObject` |
| Navigation | `NavigationStack` with value-based `navigationDestination`; router object owns the path | Split layouts on iPad → `NavigationSplitView` |
| Concurrency | Swift 6 language mode; MainActor-by-default for app targets; `@concurrent`/actors for heavy work | Large legacy module → migrate per module with `SWIFT_STRICT_CONCURRENCY=complete` warnings first |
| Networking | `URLSession` async/await + `Codable` DTOs marked `nonisolated` and `Sendable` | Existing client library |
| Persistence | SwiftData for new simple local models | Complex migrations, heavy queries or sharing with older OS → Core Data/GRDB |
| Secrets/tokens | Keychain (exact steps in release-and-security.md) | — never UserDefaults |
| Tests | Swift Testing for unit/integration; XCTest for UI tests and performance | Project standard is XCTest only |
| Dependencies | SPM | Project uses CocoaPods; don't migrate unasked |
| Lifecycle | Scene-based (SwiftUI `App` or `UISceneDelegate`) | — required when building with the iOS 27 SDK |

## Workflow A: build a screen or feature

```
- [ ] Step 0 done
- [ ] Model: @Observable class (MainActor) holding state + async intents; DTOs nonisolated/Sendable
- [ ] View: small subviews; pass only the data each needs; stable identity in ForEach (Identifiable IDs, never indices)
- [ ] Loading / empty / error states explicit; `.task(id:)` for async loading (auto-cancels)
- [ ] Accessibility: labels/values/hints, Dynamic Type up to accessibility sizes, VoiceOver order, 44pt targets, reduce motion
- [ ] Localization: String Catalog keys, no string concatenation for sentences
- [ ] Previews for each state
- [ ] Tests for model logic (Swift Testing `@Test`, `#expect`)
- [ ] Validate loop passes
```

Validate → fix → repeat:

```bash
xcodebuild -scheme "<Scheme>" -destination 'platform=iOS Simulator,name=<Device>' build
xcodebuild -scheme "<Scheme>" -destination 'platform=iOS Simulator,name=<Device>' test
swift test                      # for SPM packages
swiftlint --strict              # if configured
```

Treat new concurrency warnings as errors to fix, not to suppress. `@preconcurrency` and `nonisolated(unsafe)` need a comment explaining why.

## Workflow B: Swift 6 concurrency migration (per module)

See `references/concurrency.md`. Order:
1. Enable complete checking as warnings.
2. Isolate UI and app state to MainActor; app targets in Xcode 26+ default to it.
3. Make DTOs and value types `Sendable`/`nonisolated`.
4. Move CPU-heavy work to `@concurrent` functions or actors.
5. Flip the module to the Swift 6 language mode.
6. Run the validate loop.

## Workflow C: SDK/Xcode upgrade and App Store readiness (low freedom)

```
- [ ] Read references/versions.md upload requirements and deadlines
- [ ] Build with the new Xcode on a branch; fix errors before warnings
- [ ] If the app uses an AppDelegate-only lifecycle: adopt UIScene BEFORE building with the iOS 27 SDK (apps without it fail to launch)
- [ ] Launch screen present (required for submission starting with iOS 27)
- [ ] Privacy manifest (PrivacyInfo.xcprivacy) covers required-reason APIs and third-party SDKs
- [ ] Deployment target meets the store minimum
- [ ] Archive + validate per references/release-and-security.md
```

## Liquid Glass and system design

- Prefer system components (toolbars, tab bars, sheets, `glassEffect` where appropriate). They adopt the current design language automatically.
- Don't hard-code bar backgrounds or custom blur stacks that fight the system material; test in light and dark mode, with increased contrast and with reduce transparency.

## Implementing from a design or mockup

1. Extract tokens (colors as asset-catalog colors with dark variants, type styles mapped to Dynamic Type text styles, spacing) before building views.
2. Map to system components first; use custom components only where the design clearly diverges.
3. Build with previews for each state and size class (iPhone compact, iPad regular, resizable windows), plus largest Dynamic Type and RTL.
4. Compare simulator screenshots with the mockup; fix spacing and type, then accessibility.

## Review mode

Use `references/review-checklist.md`. Report each finding as **blocker / should-fix / nit**, with file:line, the problem and a concrete Swift fix, ordered by severity. Blockers include:
- data races or `@unchecked Sendable` without justification;
- UI work off the main actor;
- tokens stored outside the Keychain;
- force-unwraps on external data;
- missing UIScene adoption on an iOS 27 SDK build;
- privacy manifest gaps.

Don't rewrite soft-deprecated APIs in code you weren't asked to touch. Note them once as a nit.

## Reference map

- `references/versions.md`: Xcode/Swift/SDK facts, upload deadlines, new SwiftUI APIs, old patterns, verify notes
- `references/concurrency.md`: isolation defaults, Codable pitfalls, patterns
- `references/release-and-security.md`: archive/signing steps, Keychain, ATS
- `references/review-checklist.md`: impact-ranked rules
- `references/platform-features.md`: optional: push/APNs, StoreKit 2, HealthKit, widgets/Live Activities, App Intents, privacy manifest
