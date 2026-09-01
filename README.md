# ruralcare

**RuralCare** — AI-assisted healthcare access for rural and underserved communities in India.
Built with Flutter (Android + iOS) + Riverpod + GoRouter, backed by a Node.js/Express API, MongoDB Atlas, and Firebase Authentication.

> Product docs and project memory live in [`Ai-HealthCare/`](Ai-HealthCare/). Read `Ai-HealthCare/memory.md` first.

---

## Getting Started

```bash
flutter pub get
flutter run          # pick your Android emulator / device
```

Backend (in a separate terminal):

```bash
cd backend
cp .env.example .env   # fill in MONGODB_URI, FIREBASE_PROJECT_ID, GOOGLE_APPLICATION_CREDENTIALS
npm install
npm start              # serves http://localhost:3000/api/v1
```

---

## ⚠️ Android Phone Authentication (OTP) Setup

The app signs users in with **real Firebase SMS OTP**. If you tap "Send OTP" and it fails
or no OTP arrives, the usual causes are listed below. The most common by far is **#1**.

### 1. Register your debug SHA fingerprint in Firebase (REQUIRED)

Firebase refuses to send OTP unless the **SHA-1 and SHA-256** fingerprints of the keystore
signing the APK are registered for the app.

> ✅ **Already done for this machine** — the fingerprints below are registered on the
> Firebase Android app `com.ruralcare.ruralcare` (verified programmatically via the
> Firebase Management API on 2026-08-29). You only need to repeat this if you change
> machines, generate a new debug keystore, or use a release keystore.

Print your fingerprints (any time):

```powershell
powershell -ExecutionPolicy Bypass -File tools/android_sha.ps1
```

Register them on Firebase (either):
- **Automatically** — `node tools/register-sha-fingerprints.js` (uses the Firebase
  service account; idempotent — safe to re-run), or
- **Manually** — Firebase Console → project (`luciferai-3b049`) → **Project settings →
  Your apps → `com.ruralcare.ruralcare`** → **Add fingerprint**.

Fingerprints for this machine's default debug keystore (`%USERPROFILE%\.android\debug.keystore`):

```
SHA1:   07:25:E7:C2:1E:16:EC:2F:B1:8D:1D:BC:0B:49:42:67:08:60:66:B4
SHA256: CA:B3:55:73:3E:25:D3:56:25:35:B0:F3:1E:17:F0:DD:F7:6E:BF:7E:AB:45:DE:F8:03:9E:38:F2:81:23:E7:BB
```

> If you build with a **release** keystore or on a different machine, re-run the script and register those fingerprints too.
> After changing fingerprints, **uninstall the app** and install fresh (Firebase caches app credentials).

### 2. Enable the Phone sign-in provider

Firebase Console → **Authentication → Sign-in method → Phone** → **Enable**. Without this you get
`operation-not-allowed` ("Phone sign-in is not enabled").

> ✅ **Already enabled** — verified programmatically via the Identity Toolkit Admin API
> (`signIn.phoneNumber.enabled = true`) on 2026-08-29.

### 3. Emulator must have Google Play Services

Use an emulator image that includes **Google Play** (not a bare AOSP image). Check: the emulator
must be able to run the Play Store / have Google Play Services installed. Otherwise phone
verification fails with a "Google Play Services could not verify this device" error.

### 4. Test Numbers & Carrier SMS (Dev & Testing)

- Firebase Spark (free) plan blocks carrier SMS dispatch across telecom networks (`BILLING_NOT_ENABLED`), which requires Blaze plan.
- To test with any real phone number without SMS charges, register it with `tools/manage-test-phone-numbers.js`:
  ```bash
  # Add phone number with custom or default OTP (123456):
  node tools/manage-test-phone-numbers.js add +918100194750 123456

  # List registered test numbers:
  node tools/manage-test-phone-numbers.js list
  ```
- This allows entering real phone numbers into the app and verifying with the set OTP.

### 5. Cleartext HTTP to the dev backend

The app talks to the local backend over plain HTTP (`10.0.2.2:3000` on the emulator, LAN IP on a
physical device). Android 9+ blocks cleartext by default, so we whitelist only the dev hosts in
`android/app/src/main/res/xml/network_security_config.xml`. If you change `_devLanIp` in
`lib/core/config/app_config.dart`, add that IP to the XML too.

### 6. Useful diagnostics

- The OTP screen now shows the **exact** Firebase error (e.g. `operation-not-allowed`,
  `invalid-app-credential`) instead of a generic message — read what it says.
- `flutter analyze` and `flutter test` should both pass.
- Backend tests: `cd backend && npm test`.
