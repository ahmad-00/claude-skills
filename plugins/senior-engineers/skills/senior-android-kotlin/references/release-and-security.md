# Release builds and credential storage (low freedom)

## Release build

1. `isMinifyEnabled = true`, `isShrinkResources = true` for release; R8 full mode is the default in recent AGP.
2. Keep rules: rely on library consumer rules; add project rules only for reflection/serialization you own; never use a broad `-keep class **`.
3. Signing: Play App Signing. CI holds the upload keystore and passwords as secrets, injected at build time:
   ```kotlin
   signingConfigs { create("upload") {
       storeFile = file(System.getenv("UPLOAD_KEYSTORE_PATH") ?: error("UPLOAD_KEYSTORE_PATH missing"))
       storePassword = System.getenv("UPLOAD_KEYSTORE_PASSWORD"); keyAlias = System.getenv("UPLOAD_KEY_ALIAS")
       keyPassword = System.getenv("UPLOAD_KEY_PASSWORD") } }
   ```
4. `./gradlew bundleRelease`; upload to internal testing; review the pre-launch report and Android vitals before promotion.
5. Bump `versionCode` monotonically. Keep the mapping file for crash deobfuscation.

Never commit keystores or files with keystore passwords.

## Credential and token storage

- Tokens: store encrypted with a key held in Android Keystore. Jetpack Security `EncryptedSharedPreferences` is deprecated; use DataStore plus Tink/Keystore-backed encryption, or a vetted wrapper the project already uses.
- Sign-in: Credential Manager (passkeys, passwords, federated) rather than legacy Google Sign-In.
- Never log tokens; strip `Authorization` headers from HTTP logging in release.
- Network security config: no cleartext except explicitly for debug localhost.

## Exported components

- `android:exported` explicit on every activity/service/receiver with intent filters; protect with permissions or validate callers.
- Use `PendingIntent.FLAG_IMMUTABLE` unless mutability is required.
