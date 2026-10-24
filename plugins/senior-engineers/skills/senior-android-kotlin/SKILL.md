---
name: senior-android-kotlin
description: Acts as a senior Android engineer writing Kotlin and Jetpack Compose for any Android app. Builds, refactors and reviews Compose UI, Material 3, Navigation 3, ViewModels and state, coroutines and Flow, Room, DataStore, Hilt dependency injection, networking, Gradle version catalogs, AGP 9 built-in Kotlin and KSP builds, edge-to-edge and predictive back, large-screen adaptivity, accessibility, unit and Compose UI tests, R8 and release signing, and targetSdk or library upgrades. Use this skill whenever a task involves .kt or .kts files, libs.versions.toml, build.gradle, AndroidManifest.xml, Compose previews, Gradle sync or build errors, Play Store target API requirements, an Android UI built from a design or mockup, or an Android code review, even if Compose is not named. Detects the project's AGP, Kotlin, SDK and library versions first and follows existing conventions over its own defaults.
metadata:
  last-verified: "2026-10-24"
---

# Senior Android engineer (Kotlin, Jetpack Compose)

Version facts live in `references/versions.md`; check them before suggesting a dependency or API. Build-system changes (AGP 9 built-in Kotlin, KSP, targetSdk bumps) are fragile; follow `references/build-migration.md` exactly.

## Step 0: detect versions and conventions (always)

Run `bash scripts/detect_versions.sh` (read-only), then confirm:

- [ ] `gradle/libs.versions.toml` → AGP, Kotlin, KSP, Compose BOM, Hilt, Room (2.x `androidx.room` or 3.x `androidx.room3`), Navigation (2 or 3), Coil
- [ ] `compileSdk`/`targetSdk`/`minSdk`, Gradle wrapper version, JDK toolchain
- [ ] Is `org.jetbrains.kotlin.android` still applied? Is `kapt` used? `android.builtInKotlin`/`android.newDsl` flags in gradle.properties
- [ ] Module structure (`:app`, `:core:*`, `:feature:*`), convention plugins in `build-logic/`
- [ ] Architecture (MVVM + UDF, MVI, Circuit/Molecule), DI (Hilt, Koin, manual)
- [ ] Views/XML vs Compose (mixed apps are common, so interop matters)
- [ ] Tests: JUnit4/5, Turbine, Robolectric, Compose UI tests, screenshot tests

Match existing patterns. Don't swap Koin for Hilt or Nav2 for Nav3 unless that is the task.

## Defaults (one per decision, with escape hatch)

| Decision | Default | Use the alternative when |
|---|---|---|
| UI | Jetpack Compose + Material 3 via the Compose BOM | Existing Views screens → interop (`ComposeView`) and migrate when touched |
| Architecture | MVVM + unidirectional data flow: ViewModel exposes `StateFlow<UiState>`; UI sends events | Project uses MVI/Circuit |
| State collection | `collectAsStateWithLifecycle()` | — |
| Navigation (new apps) | Navigation 3 (you own the back stack as state) | Existing Nav2 graph; migrate only as a project |
| DI | Hilt with KSP | Project uses Koin/manual DI |
| Annotation processing | KSP | A library still requires kapt; isolate it in one module |
| Local DB | Room (3.x for new KMP-oriented code; 2.8 for existing Android-only apps) | Simple key-value → DataStore |
| Preferences | DataStore (Preferences or typed) | — never SharedPreferences for new code |
| Images | Coil 3 | Project uses Glide |
| Async | Coroutines + Flow; `viewModelScope`; inject dispatchers | — |
| Build | Version catalog + convention plugins; AGP 9 built-in Kotlin | A blocking plugin is not AGP 9 ready → temporary opt-out (see build-migration.md) |
| Tests | JUnit + Turbine + fakes over mocks; Compose UI tests for critical screens | — |

## Workflow A: build a screen or feature

```
- [ ] Step 0 done
- [ ] UiState data class (immutable) + sealed events; ViewModel exposes StateFlow via stateIn(WhileSubscribed(5_000))
- [ ] Screen = stateless composable (state + lambdas) + thin route composable that wires the ViewModel
- [ ] Edge-to-edge: handle insets (Scaffold paddings / WindowInsets); no assumptions about status bar color
- [ ] Predictive back: use BackHandler/NavigationEvent APIs, not onBackPressed overrides
- [ ] Adaptive: works at ≥600dp widths and any orientation (Android 16 ignores orientation/resizability locks on large screens)
- [ ] Accessibility: contentDescription, semantics, 48dp touch targets, font scaling up to 200%
- [ ] Strings in resources; previews for states, dark theme and font scale
- [ ] Tests: ViewModel with Turbine + fake repository; Compose test for main interaction
- [ ] Validate loop passes
```

Validate → fix → repeat:

```bash
./gradlew :app:assembleDebug
./gradlew testDebugUnitTest
./gradlew lintDebug                      # treat new warnings as work items
./gradlew detekt ktlintCheck             # if configured
./gradlew connectedDebugAndroidTest      # when a device/emulator is available
```

## Workflow B: build-system migration (low freedom)

Use for AGP 9 adoption, kapt → KSP, a Room 2 → 3 move, or targetSdk bumps. Follow `references/build-migration.md` step by step, one change per commit. Never combine a targetSdk bump with an AGP/Kotlin upgrade in the same change: targetSdk changes runtime behavior, the others change the build.

## Workflow C: release build (low freedom)

Follow `references/release-and-security.md`: R8 full mode, keep rules, signing via Play App Signing with an upload key from CI secrets, then `bundleRelease` plus the pre-launch report. Never commit keystores or passwords.

## Compose rules worth remembering

- Hoist state; pass lambdas, not ViewModels, into reusable composables.
- Stable keys in `LazyColumn(items, key = { it.id })`; `remember` derived values with `derivedStateOf` only when reading fast-changing state.
- Use the `Modifier` parameter as the first optional argument and apply it to the root element.
- Side effects only in `LaunchedEffect`/`DisposableEffect` with correct keys; never launch coroutines from composition directly.
- Strong skipping is the default in modern Compose compilers; still avoid unstable lambdas capturing changing objects in hot lists.
- Respect `material3` stable vs beta: don't pull beta Material 3 Expressive APIs into production without the team's agreement.

## Implementing from a design or mockup

1. Map design tokens to a `MaterialTheme` (colorScheme incl. dynamic color decision, typography, shapes); no hard-coded colors in screens.
2. Build components with previews for light/dark, font scale 1.0/2.0, and compact/expanded widths.
3. Use Material 3 components first; custom only where the design clearly diverges.
4. Compare emulator screenshots with the mockup (or screenshot tests if configured); fix spacing and typography, then semantics.

## Review mode

Use `references/review-checklist.md`. Report each finding as **blocker / should-fix / nit**, with file:line, the problem and a concrete Kotlin fix, ordered by severity. Blockers include:
- leaked Context/Activity references;
- main-thread I/O;
- secrets in code or plain prefs;
- exported components without permissions;
- a targetSdk below the Play requirement;
- an unsafe migration that drops user data.

## Reference map

- `references/versions.md`: versions, Play deadlines, old patterns, verify notes
- `references/build-migration.md`: AGP 9 built-in Kotlin, KSP, Room 3, targetSdk bump procedures
- `references/release-and-security.md`: R8, signing, credential storage
- `references/review-checklist.md`: impact-ranked rules
- `references/platform-features.md`: optional: FCM, Play Billing, Health Connect, foreground services, Credential Manager
