# Release builds and credential storage (low freedom)

## Archive and upload (CI or local)

1. Confirm Xcode version meets the current upload requirement (versions.md).
2. Bump `CURRENT_PROJECT_VERSION` (build number) monotonically; set `MARKETING_VERSION`.
3. Archive:
   ```bash
   xcodebuild -scheme "<Scheme>" -configuration Release -destination 'generic/platform=iOS' \
     -archivePath build/App.xcarchive archive
   ```
4. Export with an `ExportOptions.plist` (method `app-store-connect`, automatic or manual signing as the project uses):
   ```bash
   xcodebuild -exportArchive -archivePath build/App.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/export
   ```
5. Upload with the project's tool (Xcode Organizer, Transporter, or fastlane). Use App Store Connect API keys stored in CI secrets, never committed.
6. Check the processed build in TestFlight before submitting; review privacy manifest warnings.

Never commit signing certificates, `.p8` keys or provisioning profiles. Never disable code signing to "make CI pass".

## Keychain for tokens

```swift
import Security

enum Keychain {
    static func save(_ data: Data, account: String, service: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
    }
}
```

- Use `AfterFirstUnlockThisDeviceOnly` for refresh tokens needed in background; use `WhenUnlockedThisDeviceOnly` otherwise.
- Never use UserDefaults, plist files or logs for secrets. Redact tokens in network logging.
- Share via Keychain access groups only when an extension needs it.

## Transport

- Keep App Transport Security on; per-domain exceptions only with justification.
- Certificate pinning only with a rotation plan (pin public keys, ship backups).
