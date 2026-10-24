# Android stack versions (last verified: 2026-10-24)

## Build and language

| Item | Current stable | Notes |
|---|---|---|
| Android Gradle Plugin | 9.4.x | Built-in Kotlin on by default; needs a recent Gradle (9.6+ for 9.4) and JDK 17 |
| AGP 10 | not released | Roadmap: "late 2026". Removes legacy Variant API and the `android.newDsl`/`android.builtInKotlin` opt-outs |
| Kotlin | 2.4.x (2.4.21 latest patch) | 2.5.0 in beta |
| KSP | 2.3.x | Versioned independently of Kotlin since 2.3.0 |
| compileSdk | 37 available (Android 17) | Newer AndroidX artifacts may require compileSdk 37 |

## Libraries

| Library | Current | Notes |
|---|---|---|
| Compose BOM | 2026.09.00 (stable) | Alpha/beta BOMs newer |
| material3 | 1.4.0 stable; 1.5.0 in beta | Material 3 Expressive APIs in 1.5 beta |
| Navigation 3 | 1.2.0 | Deep-link support added in 1.2 |
| Room | 3.0.x (`androidx.room3`) | Kotlin/KSP only, coroutine-first, no SupportSQLite (wrapper artifact for migration); Room 2.8 for prep |
| DataStore | 1.3.0 | — |
| Hilt (Dagger) | 2.60.x | 2.60 removed multidex support; Hilt minSdk 23 |
| Coil | 3.6.x | — |
| Play Billing | 9.x | — |
| Health Connect client | 1.1.0 stable | Requires compileSdk 36+ |

## Google Play deadlines

| Date | Requirement |
|---|---|
| 2026-08-31 | New apps and updates must target API 36 (extension to 2026-11-01 reportedly available) |
| 2026-08-31 | Billing Library 7 no longer accepted (extension to 2026-11-01) |
| 2027-08-31 | Billing Library 8 deadline |
| 2028-08-31 | Billing Library 9 deadline (**verify**) |
| End of 2026 | Google Fit APIs end; migrate to Health Connect |

## Android 16 (API 36) behavior changes when targeting 36

- Edge-to-edge opt-out is ignored.
- Predictive back is enabled by default (`onBackPressed` is not called).
- Orientation, resizability and aspect-ratio restrictions are ignored on displays ≥ 600dp.

## Old patterns / deprecated APIs → replacement

| Old | Replace with |
|---|---|
| `org.jetbrains.kotlin.android` plugin + `android { kotlinOptions {} }` | AGP 9 built-in Kotlin + top-level `kotlin { compilerOptions {} }` |
| kapt | KSP |
| `androidx.room` 2.x SupportSQLite APIs (new KMP code) | `androidx.room3` with SQLiteDriver |
| SharedPreferences | DataStore |
| `collectAsState()` in Android UI | `collectAsStateWithLifecycle()` |
| `onBackPressed()` override | `OnBackPressedCallback` / `BackHandler` / NavigationEvent |
| Navigation 2 XML graphs (new apps) | Navigation 3 |
| Accompanist insets/system UI controller | `WindowInsets` APIs, `enableEdgeToEdge()` |
| Play Billing ≤ 7 | Billing 9 |
| Google Sign-In (legacy) / Smart Lock | Credential Manager |
| Google Fit APIs | Health Connect |
| Multidex with Hilt | minSdk ≥ 23 (native multidex) |

## Unverified

- **verify:** whether AGP 10 has shipped by the time you read this.
- **verify:** Health Connect feature changes beyond 1.1.0.
