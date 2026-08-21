# Signed mobile releases

Nexus never falls back to debug signing for a production build. Release jobs run only for a `v*` tag and are bound to the protected `release-android` or `release-ios` GitHub environment.

## Android environment

Configure these environment secrets:

- `ANDROID_KEYSTORE_BASE64`: base64 of the upload `.jks` file.
- `ANDROID_KEY_ALIAS`: upload-key alias.
- `ANDROID_KEY_PASSWORD`: private-key password.
- `ANDROID_STORE_PASSWORD`: keystore password.

The workflow decodes the keystore into `$RUNNER_TEMP`, writes `key.properties` with mode `0600`, runs the complete Flutter verification suite, builds signed AAB/APK files, validates their signatures, emits SHA-256 checksums, uploads them to the tag release, and deletes transient signing material.

## iOS environment

Configure these environment secrets:

- `IOS_DISTRIBUTION_P12_BASE64`: base64 of the Apple Distribution certificate and private key.
- `IOS_DISTRIBUTION_P12_PASSWORD`: password protecting the `.p12`.
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 of the App Store provisioning profile.
- `IOS_KEYCHAIN_PASSWORD`: random password for the temporary CI keychain.
- `APPLE_TEAM_ID`: Apple Developer Team ID.

Configure environment variable `IOS_BUNDLE_ID` to the identifier contained in the provisioning profile. The workflow uses a temporary keychain, verifies the signed archive with `codesign`, exports the IPA, emits its SHA-256 checksum, and destroys the imported signing identity and profile.

## Protection checklist

1. Add required reviewers to both release environments and prevent self-review where the repository plan supports it.
2. Protect `v*` tags so only maintainers can create or update them.
3. Keep signing secrets at environment scope, never repository files or mobile assets.
4. Rotate the Android upload key or Apple distribution certificate when access changes.
5. Compare the published certificate/team identity and checksums with the expected values before store upload.

Without every required input the corresponding release job fails before any build begins.
