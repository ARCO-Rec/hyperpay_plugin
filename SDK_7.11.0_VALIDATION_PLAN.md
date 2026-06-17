# HyperPay SDK v7.11.0 Migration — Local Validation Plan

Run this on your Mac (Xcode + Android tooling required — the sandbox here has neither, so this hasn't been build-tested yet, only statically reviewed). Goal: confirm the v7.11.0 binary swap, podspec/gradle bumps, and branch-pinned Podfiles actually produce a working build before the 2026-07-07 Mastercard cert deadline.

---

## 0. Prerequisites

- Xcode (latest stable) + command line tools: `xcode-select --install`
- CocoaPods: `sudo gem install cocoapods` (or `brew install cocoapods`)
- Flutter SDK on PATH, matching the version these projects already use
- Android Studio / Android SDK with API 35 platform + build-tools installed (`sdkmanager "platforms;android-35"`)
- Network access to GitHub (for the `oppwamobile-ios-sdk` git pod) and Azure DevOps (for Arco/Finzey/Winveston repos)

Run `flutter doctor -v` first and fix anything red before proceeding.

---

## 1. Fix the known mismatch before building

`hyperpay_plugin/example/android/app/build.gradle` is still on `compileSdkVersion 34` / `targetSdkVersion 33`, while the plugin's own `android/build.gradle` is on `compileSdkVersion 35`. Bump the example app to match:

```gradle
compileSdkVersion = 35
targetSdkVersion = 35
```

(Same check applies to Arco / Finzey / Winveston's `android/app/build.gradle` — confirm each consuming app's `compileSdkVersion` is ≥ 35 before building. If you want, tell me and I'll make this edit for you.)

---

## 2. Validate `hyperpay_plugin` standalone + example app

```bash
cd ~/StudioProjects/hyperpay_plugin

# Confirm branch
git status
git log -1 --oneline   # should show 1136f5b...

flutter pub get
cd example
flutter pub get
```

### 2a. Android build

```bash
cd ~/StudioProjects/hyperpay_plugin/example
flutter build apk --debug
```

Expect: clean build, no errors referencing `oppwa.mobile-release`, `ipworks3ds_sdk`, or `ipworks3ds_sdk_deploy`. If you hit a `compileSdkVersion`/resource-linking error, that's the mismatch from Step 1 — fix it there.

### 2b. iOS build

```bash
cd ~/StudioProjects/hyperpay_plugin/example/ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

Expect: CocoaPods resolves `hyperpay_sdk` from the `sdk-7.11.0-mastercard-cert` branch of `https://github.com/ARCO-Rec/oppwamobile-ios-sdk.git`. If it instead resolves to an old commit, run `pod update hyperpay_sdk` and check the Podfile.lock pins to that branch's latest commit.

Then build:

```bash
open Runner.xcworkspace
```

In Xcode: select a simulator or device, Product → Build (⌘B). Confirm no linker errors for `OPPWAMobile` or `ipworks3ds_sdk`.

### 2c. Smoke test

Run the example app on a simulator/device and exercise the actual checkout screen with HyperPay's sandbox/test card details (use whatever test merchant credentials you've been using pre-migration). Confirm:
- 3DS challenge screen renders correctly (this is the actual cert-related path)
- transaction completes (or returns the expected sandbox response)

---

## 3. Validate the three consuming apps

Repeat for each of `Arco Hourly Mobile/app`, `FinzeyMobileNewArchitecture`, `Winveston_Mobile`:

```bash
cd <app-path>
git log -1 --oneline   # confirm you're on feature/hyperpay-sdk-7.11.0 with the expected commit
flutter pub get
```

Update the plugin dependency to point at the pushed `hyperpay_plugin` commit if these apps consume it via git/path dependency (check each `pubspec.yaml`) — if they pull from pub.dev or a local path instead, make sure that path/version actually has the new podspec/build.gradle.

### Android

```bash
flutter build apk --debug
```

### iOS

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
open Runner.xcworkspace
```

Build (⌘B) and run a real checkout flow with a HyperPay test card in each app — these are the apps actually exposed to the cert expiry, so this step matters more than the plugin's own example.

---

## 4. Common failure modes to watch for

| Symptom | Likely cause | Fix |
|---|---|---|
| `pod install` resolves old SDK content | Podfile.lock cached an old commit | `pod update hyperpay_sdk --repo-update`, delete `Podfile.lock` if needed |
| CocoaPods can't reach the branch | Branch deleted/renamed on `oppwamobile-ios-sdk` | Confirm `sdk-7.11.0-mastercard-cert` still exists on the remote |
| Android resource-linking error | `compileSdkVersion` mismatch (Step 1) | Bump consuming app's `compileSdkVersion`/`targetSdkVersion` |
| Xcode duplicate symbol / framework not found | Stale `Pods`/`DerivedData` from pre-swap xcframeworks | `rm -rf Pods Podfile.lock ~/Library/Developer/Xcode/DerivedData/*`, re-run `pod install` |
| 3DS challenge fails or doesn't render | Real cert/SDK incompatibility (the thing we're trying to catch) | Escalate — this means the swap itself needs another look, not just tooling |

---

## 5. After this validates cleanly

- Run the full Phase 3 test cycle: six confirmation transactions across the three merchant accounts (per HyperPay's email).
- Track the open follow-up: once `sdk-7.11.0-mastercard-cert` merges into `oppwamobile-ios-sdk`'s default branch, remove the `:branch =>` override from all four Podfiles (Arco, Finzey, Winveston, hyperpay_plugin/example) so they stop pointing at a branch that may get deleted post-merge.
