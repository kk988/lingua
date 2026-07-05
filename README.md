# Lingua

Lingua is a SwiftUI iPhone and iPad app for translating phrases, saving them, and grouping them by the situations where they are useful.

## MVP in this scaffold

- Translate between common language pairs
- Save translated phrases locally with SwiftData
- Sync saved phrases with CloudKit
- Suggest categories such as Study, Travel, Dining, Emergency, and Casual
- Browse saved phrases by search and category

## Project generation

This project is configured for XcodeGen because this machine does not currently have a native iOS project generator installed.

1. Install XcodeGen on your Mac.
2. From this folder, run `xcodegen generate`.
3. Open `Lingua.xcodeproj` in Xcode.
4. Update the bundle identifier and CloudKit container in `project.yml` and `Lingua/Support/Lingua.entitlements`.
5. Build and run on an iPhone or iPad simulator.

## Working without local Xcode

If your Mac cannot run a modern Xcode version, use the included GitHub Actions workflow to build and test in the cloud:

1. Push your branch to GitHub.
2. Open the Actions tab and run the `iOS CI` workflow (or open a pull request).
3. The workflow will install XcodeGen, generate `Lingua.xcodeproj`, and run unit tests on a hosted macOS runner.

Workflow file: `.github/workflows/ios-ci.yml`

## Translation backend

Lingua now uses a real network-backed translation provider via `TranslationProvider`.

- Default endpoint: `https://libretranslate.com/translate`
- Configure endpoint and key in `Lingua/Support/Info.plist` using `TranslationAPIEndpoint` and `TranslationAPIKey`
- Keep `TranslationProviderFactory` as the app-level composition point for swapping providers later

## CloudKit sync conflict behavior

This scaffold uses a conflict-resolution strategy designed to reduce accidental data loss when iPhone and iPad update the same phrase close together:

- Phrase text and language pair: last-write-wins using newest `updatedAt`
- Favorite status: logical OR so a favorite is not silently dropped
- Categories: set union from both devices

See `SyncConflictResolverTests` for executable examples of this merge policy.

## TestFlight readiness checklist

- [ ] Replace `com.example` bundle identifiers in `project.yml` and entitlements
- [ ] Configure the production CloudKit container and verify iPhone/iPad use the same container
- [ ] Set `TranslationAPIEndpoint` and `TranslationAPIKey` for the production translation backend
- [ ] Verify no translation secrets are hardcoded in Swift source files
- [ ] Validate iPhone to iPad sync for create/edit/favorite/category updates on same Apple ID
- [ ] Add App Privacy details for network translation and CloudKit usage
- [ ] Add app icon, launch assets, and localized metadata for App Store Connect
- [ ] Run unit tests and a clean release build before uploading
