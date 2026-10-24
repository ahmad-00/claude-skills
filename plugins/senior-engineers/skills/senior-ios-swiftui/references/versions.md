# iOS toolchain versions (last verified: 2026-10-24)

## Toolchain

| Item | Current | Notes |
|---|---|---|
| Xcode | 27.x (released Sept 2026) | Apple silicon only; requires a recent macOS Tahoe release (**verify** exact minimum) |
| iOS SDK | iOS 27 | — |
| Swift | 6.4 bundled with Xcode 27; 6.3 released 2026-03 | 6.3 added module selectors (`Module::Name`), `@c`, and the first official Swift SDK for Android |
| Swift 6.2 (Xcode 26) | Approachable concurrency | SE-0466 default MainActor isolation; SE-0461 nonisolated(nonsending) by default; `@concurrent`. New Xcode 26 app targets default to MainActor isolation |

## App Store upload requirements

| Since/From | Requirement |
|---|---|
| 2026-04-28 | Built with Xcode 26 / iOS 26 SDK |
| April 2027 | Built with the iOS & iPadOS 27 SDK or later and targeting iOS 15 or later (**verify** exact day) |
| iOS 27 SDK builds | **UIScene lifecycle mandatory.** Apps without it fail at launch. The check depends on the SDK you build with, not on the device's iOS version |
| iOS 27 | Launch screen required for App Store submission |

## SwiftUI additions in the 2027 releases (iOS 27)

- `@State` is now a macro with lazy initialization of class instances (review init side effects).
- `ContentBuilder` (successor to `ViewBuilder` naming) speeds up type-checking.
- `reorderable` containers beyond `List`; swipe actions on any container.
- Toolbar overflow and priority APIs (**verify** final names; some were renamed during seeds).
- New document model: `ReadableDocument` / `WritableDocument`; `ReferenceFileDocument` deprecated.
- iPhone apps are fully resizable on iPad and in iPhone Mirroring. Test flexible layouts.
- Xcode 27 ships agent skills (e.g. swiftui-specialist, uikit-app-modernization, test-modernizer). Export them with `xcrun agent skills export <dir>` (**verify** command).

## Unverified

- **verify:** current StoreKit 2 / App Store Server API changes for iOS 27.
- **verify:** Swift Testing additions in Swift 6.4.

## Old patterns / deprecated APIs → replacement

| Old | Replace with |
|---|---|
| `ObservableObject` + `@Published` + `@StateObject` (iOS 17+ targets) | `@Observable` + `@State` |
| `NavigationView` | `NavigationStack` / `NavigationSplitView` |
| AppDelegate-only lifecycle | SwiftUI `App` or `UISceneDelegate` (mandatory with iOS 27 SDK) |
| `DispatchQueue.main.async` for UI | `@MainActor` / `MainActor.run` |
| Completion-handler networking | `async`/`await` URLSession |
| `foregroundColor`, `cornerRadius` | `foregroundStyle`, `clipShape(.rect(cornerRadius:))` |
| `onChange(of:perform:)` | `onChange(of:) { old, new in }` |
| StoreKit 1 (`SKPaymentQueue`) | StoreKit 2 (`Product`, `Transaction`) |
| XCTest unit tests (new code) | Swift Testing |
| `ReferenceFileDocument` | `ReadableDocument`/`WritableDocument` (iOS 27) |
| `onMove` index juggling (iOS 27+) | `reorderable` |
