# Build migrations (exact procedures)

## AGP 9 with built-in Kotlin

1. Ensure the Gradle wrapper meets the AGP minimum and JDK 17+.
2. Update `agp` in `libs.versions.toml`; sync.
3. Remove `alias(libs.plugins.kotlin.android)` / `id("org.jetbrains.kotlin.android")` from every Android module (applying it is an error with built-in Kotlin).
4. Move `android { kotlinOptions { jvmTarget = "17" } }` to a top-level block:
   ```kotlin
   kotlin { compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) } }
   ```
5. Keep `org.jetbrains.kotlin.plugin.compose` (Compose compiler) and `kotlin.plugin.serialization` where used.
6. KMP library modules: switch to `com.android.kotlin.multiplatform.library`.
7. Remove temporary `android.builtInKotlin=false` / `android.newDsl=false` once every plugin supports AGP 9. AGP 10 removes these opt-outs.
8. Validate: `./gradlew clean assembleDebug testDebugUnitTest lintDebug`; check release bytecode target.

## kapt → KSP

1. Add the `com.google.devtools.ksp` plugin.
2. Replace `kapt(...)` with `ksp(...)` for Hilt, Room, Moshi, etc.; remove `kotlin-kapt`.
3. Move kapt arguments to `ksp { arg("room.schemaLocation", "$projectDir/schemas") }`.
4. Validate a clean build; check generated code paths in the IDE.

## Room 2.x → 3.0

1. First move to Room 2.8 and adopt driver APIs (`setDriver(BundledSQLiteDriver())`) and suspend DAOs.
2. Replace artifacts `androidx.room:room-*` → `androidx.room3:room3-*`; imports `androidx.room.` → `androidx.room3.`.
3. KSP only; Kotlin codegen only.
4. Remaining SupportSQLite usages: temporary sqlite wrapper artifact.
5. Keep exported schemas; run migration tests (`MigrationTestHelper`) against real old schemas before shipping. Data loss is a blocker.

## targetSdk bump (separate change)

1. Read the behavior changes for the target level (versions.md lists 36).
2. Bump `targetSdk` only; run the app on the matching OS image.
3. Check edge-to-edge, predictive back, foreground service types, exact alarms, photo picker and intent restrictions, and large-screen behavior.
4. Fix the issues, run the validate loop, run the internal testing track and the pre-launch report.
