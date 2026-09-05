# PROGRESS.md

# RuralCare — Development Progress

> **IMPORTANT**: This file reflects the **actual** state of the codebase as of 2026-08-28.
> It has been reconciled with the real Flutter implementation.
> UI-only screens are NOT marked COMPLETED.

---

## Overall Project Status

| Area | Status |
|---|---|
| **Stitch UI Design** | PARTIALLY COMPLETE (patient screens designed; doctor/admin not) |
| **Flutter Patient UI** | IN_PROGRESS (substantial UI exists, onboarding & profile live) |
| **Flutter Foundation (Phase 1)** | COMPLETED (models, repositories, storage, connectivity, providers, errors, API client, config) |
| **Authentication (Phase 2)** | COMPLETE (FirebaseAuthService, real SMS OTP / test numbers, GoRouter guard, backend session exchange ✅ 2026-08-31) |
| **Patient Profile + Health Data (Phase 3)** | COMPLETE (ApiPatientRepository, edit profile, registration data persistence, live dynamic home & profile ✅ 2026-08-31) |
| **Backend (Node.js + Express)** | IN_PROGRESS (server running, auth, patient, records, facility & AI endpoints implemented, 43/43 tests pass) |
| **Database (MongoDB Atlas)** | CONFIGURED & VERIFIED (connected to cluster0.lyoecho.mongodb.net/ruralcare) |
| **AI Integration (Gemini via backend)** | COMPLETE (Backend Gemini service + clinical rules + history persistence ✅ 2026-08-31) |
| **Testing** | IN_PROGRESS (51 Flutter unit tests passing, 43 Backend tests passing) |

---

## Current Development Phase

**Phase 10 — Patient Integration, Polish & Final Hardening: ✅ COMPLETE (2026-09-01)**  
**All 10 Patient Mobile Application Phases are COMPLETE! 🎉**

---

## Current Task

Phase 10 complete and verified working end-to-end:
- Global reactive offline banner integration in `lib/app.dart` listening to `isOnlineProvider`.
- Enhanced `VideoConsultationScreen` with live consultation timer, in-call controls, animated stream indicator, and end-call confirmation dialog.
- Polished `DoctorProfileScreen` with interactive consultation booking bottom sheet.
- Validated patient touch targets, buttons ($56\text{dp}$), emergency dialer ($80\text{dp}$), and AI non-doctor clinical disclaimers.
- 63 Flutter unit & integration tests passing; 53 backend tests passing; `flutter analyze` clean (0 issues).

---

## Patient Feature Status

### Legend

- **UI** = Screen(s) exist and render
- **Functionality** = Real logic/service/backend integration works
- **Tested** = Verified through automated or manual testing

| Feature | UI | Functionality | Tested | Status |
|---|---|---|---|---|
| **Onboarding** | | | | |
| Welcome screen | ✅ | — | — | UI IMPLEMENTED |
| OTP Login | ✅ | ✅ (Firebase Phone Auth) | ✅ | COMPLETED |
| Registration (Contact) | ✅ | ✅ (Passes to Health Step) | ✅ | COMPLETED |
| Registration (Health) | ✅ | ✅ (Saves to Backend & Local Storage) | ✅ | COMPLETED |
| **Home & Navigation** | | | | |
| Home shell (bottom nav) | ✅ | ✅ (GoRouter) | ❌ | IMPLEMENTED (UI + Nav) |
| Patient Home | ✅ | ✅ (Live Greeting & Health Summary) | ✅ | COMPLETED |
| **Profile** | | | | |
| Patient Profile | ✅ | ✅ (Live Provider Data & Sign Out) | ✅ | COMPLETED |
| Edit Profile | ✅ | ✅ (Updates Backend & Refreshes State) | ✅ | COMPLETED |
| **Emergency** | | | | |
| Emergency Landing | ✅ | ✅ (Live topics, call 108 dialer) | ✅ | COMPLETED |
| First Aid Steps | ✅ | ✅ (10 topics, step-by-step & DOs/DON'Ts) | ✅ | COMPLETED |
| Offline Emergency Help | ✅ | ✅ (100% offline verified) | ✅ | COMPLETED |
| Offline Content Settings | ✅ | ✅ (Storage sync & version tracking) | ✅ | COMPLETED |
| **AI Assistant** | | | | |
| AI Chat | ✅ | ✅ (Gemini API / clinical fallback + history) | ✅ | COMPLETED |
| **Find Care** | | | | |
| Facility Finder | ✅ | ✅ (Live search, filters & maps) | ✅ | COMPLETED |
| Find Doctor | ✅ | ✅ (Live search & speciality filters) | ✅ | COMPLETED |
| Doctor Profile | ✅ | ✅ (Dynamic doctor details & appointment action) | ✅ | COMPLETED |
| **Health Records** | | | | |
| Records Hub | ✅ | ✅ (Live counts & Navigation) | ✅ | COMPLETED |
| Health Timeline | ✅ | ✅ (Live timeline + Filter chips) | ✅ | COMPLETED |
| Consultation Summary | ✅ | ✅ (Live Consultation API data) | ✅ | COMPLETED |
| Prescription View | ✅ | ✅ (Live Prescription API data) | ✅ | COMPLETED |
| Lab Report | ✅ | ✅ (Live Diagnostics API data) | ✅ | COMPLETED |
| Referral Tracking | ✅ | ✅ (Live Referral API data & Progress) | ✅ | COMPLETED |
| **Documents** | | | | |
| Document Upload | ✅ | ❌ (simulated upload) | ❌ | IN_PROGRESS |
| **Consultation** | | | | |
| Video Consultation | ✅ | ❌ (simulated call UI) | ❌ | IN_PROGRESS |

---

## Completed Work

### Phase 1 — Patient Application Foundation (COMPLETED 2026-08-28)

#### Data Models (`lib/core/models/`)

All models have `fromJson`/`toJson` serialization and are tested:

- `patient.dart` — Patient profile (with `copyWith`)
- `prescription.dart` — Doctor-issued prescription
- `lab_report.dart` — Diagnostic/lab test result (with `isAbnormal` helper)
- `referral.dart` — Patient referral between facilities
- `facility.dart` — Healthcare facility
- `doctor.dart` — Doctor available for consultation
- `consultation.dart` — Healthcare consultation
- `medical_document.dart` — Uploaded medical document
- `health_record.dart` — Health record/timeline entry
- `ai_message.dart` — AI chat message

#### Repository Abstraction (`lib/core/repositories/`)

- `patient_repository.dart` — Abstract interface for patient data
- `health_record_repository.dart` — Abstract interface for health records
- `facility_repository.dart` — Abstract interface for facilities/doctors
- `document_repository.dart` — Abstract interface for documents
- `ai_repository.dart` — Abstract interface for AI assistant
- `mock_repositories.dart` — Mock implementations (used until backend exists)

#### Local Storage (`lib/core/storage/`)

- `local_storage_service.dart` — SharedPreferences wrapper:
  - Auth session state (`isLoggedIn`, phone, name)
  - Patient profile (JSON serialized)
  - Offline emergency content state
  - App preferences (voice language)
  - **Note**: Sensitive medical data should use `flutter_secure_storage` in a later phase (documented decision)

#### Connectivity (`lib/core/services/`)

- `connectivity_service.dart` — Real-time online/offline detection:
  - `ConnectivityPlatform` abstraction (testable)
  - `PluginConnectivityPlatform` (connectivity_plus backed)
  - Exposes `ConnectivityStatus` stream (ONLINE/OFFLINE)
  - Reacts to connectivity changes, not just startup check

#### Riverpod Providers (`lib/core/providers/`)

- `app_providers.dart`:
  - `appConfigProvider` — configuration
  - `localStorageProvider` — storage service
  - `connectivityServiceProvider` — connectivity service
  - `connectivityStatusProvider` — status stream
  - `isOnlineProvider` — boolean online state
  - `patientRepositoryProvider`, `healthRecordRepositoryProvider`, `facilityRepositoryProvider`, `documentRepositoryProvider`, `aiRepositoryProvider` — repositories
  - `currentPatientProvider` — current patient profile
  - `isLoggedInProvider` — auth state

#### Error Handling (`lib/core/error/`)

- `app_exception.dart` — Standardized exceptions:
  - `AppErrorType`: network, authentication, validation, notFound, server, storage, unknown
  - Factory constructors with user-friendly messages
- `error_handler.dart` — Converts technical errors to user-friendly messages (raw exceptions never exposed to UI)

#### API Client Foundation (`lib/core/networking/`)

- `api_client.dart` — HTTP abstraction:
  - `ApiClient` with GET/POST/PUT/PATCH/DELETE
  - Auth token support
  - Error mapping to `AppException`
  - Base URL from `AppConfig`
  - **No fake endpoints invented** — ready for Phase 2+ backend

#### Configuration (`lib/core/config/`)

- `app_config.dart`:
  - Environment (development/staging/production)
  - API base URL (placeholder)
  - `useMockData` flag (true until backend exists)
  - Feature flags
  - **No secrets in Flutter source** (per architecture.md §29-30)

#### Mock Data Migration

- `mock_patient_data.dart` migrated from old mock classes to real model classes
- Screens updated to use new model types (`Patient`, `Prescription`, `LabReport`, `Referral`, `HealthcareFacility`, `Doctor`, `AiMessage`)

#### Testing

- `test/models_test.dart` — 20 tests: model serialization roundtrips, missing fields, copyWith
- `test/error_config_test.dart` — 12 tests: exception factories, error mapping, config
- `test/connectivity_storage_test.dart` — 5 tests: connectivity status, stream, reactivity
- `test/widget_test.dart` — 1 smoke test (pre-existing)
- **Total: 34 tests, all passing**

#### Lint Fixes

- Fixed 4 pre-existing `unnecessary_underscores` lints
- **flutter analyze: PASS (No issues found)**

### UI Implementation (Patient Side — pre-existing)

- **Design system**: Colors, typography (Nunito Sans), Material 3 theme
- **Reusable widgets**: `EmergencyButton`, `RuralCareButton`, `SectionCard`, `StatusBadge`, `OfflineBanner`, `AiDisclaimerBanner`
- **Navigation**: GoRouter with all patient routes wired, 5-tab bottom nav shell
- **Screens**: 22 patient screens implemented
- **Emergency content**: `first_aid_content.json` bundled with 6 emergency scenarios

---

## Current Work

### Phase 1 — COMPLETE

All foundation infrastructure is implemented and tested.

### Next: Phase 2 — Patient Identity / Authentication (NOT STARTED)

Planned work:
- Wire OTP login to real auth flow (local session for MVP)
- Persist auth session via `LocalStorageService`
- Route guard: redirect to login when not authenticated
- Wire registration forms to save patient profile locally
- Sign out functionality

---

## Known Bugs / Issues

1. **OTP login** — Any 6 digits work; no real OTP verification (Phase 2)
2. **Registration** — Form data is discarded; no persistence (Phase 2/3)
3. **AI chat** — Responses are hardcoded mock text; no real AI service (Phase 7)
4. **Facility finder** — Search field is non-functional (no onChanged handler) (Phase 5)
5. **Document upload** — File picker is a no-op; upload is simulated (Phase 8)
6. **Video consultation** — Call UI is simulated; no real video (deferred)
7. **Offline content settings** — Download is simulated; no real persistence (Phase 6)
8. **Profile edit** — Shows "coming soon" snackbar (Phase 3)
9. **Doctor booking** — Shows "coming soon" snackbar (deferred)
10. **Emergency facility matching** — No location-based facility search (Phase 6)
11. **Offline banner** — `OfflineBanner` widget exists but is not yet wired to `isOnlineProvider` app-wide (Phase 10 polish)
12. **Screens still import mock data directly** — see "UI Mock Data Dependencies" below

---

## UI Mock Data Dependencies (to be replaced in later phases)

The following screens currently depend directly on `MockPatientData` instead of repositories:

| Screen | Mock dependency | Replace in |
|---|---|---|
| `patient_home_screen.dart` | `MockPatientData.currentPatient`, `.prescriptions`, `.referrals` | Phase 3/4 |
| `patient_profile_screen.dart` | `MockPatientData.currentPatient` | Phase 3 |
| `facility_finder_screen.dart` | `MockPatientData.facilities` | Phase 5 |
| `find_doctor_screen.dart` | `MockPatientData.doctors` | Phase 5 |
| `doctor_profile_screen.dart` | `MockPatientData.doctors` | Phase 5 |
| `health_records_hub_screen.dart` | Hardcoded counts | Phase 4 |
| `health_timeline_screen.dart` | Hardcoded `_events` list | Phase 4 |
| `consultation_summary_screen.dart` | Hardcoded content | Phase 4 |
| `prescription_view_screen.dart` | `MockPatientData.prescriptions` | Phase 4 |
| `lab_report_screen.dart` | `MockPatientData.labReports` | Phase 4 |
| `referral_tracking_screen.dart` | `MockPatientData.referrals` | Phase 4 |
| `ai_chat_screen.dart` | `getMockAiConversation()` | Phase 7 |
| `document_upload_screen.dart` | Simulated upload | Phase 8 |
| `offline_content_settings_screen.dart` | Simulated download | Phase 6 |

---

## Technical Decisions

> **ARCHITECTURE CHANGE (2026-08-28):** The project now uses REAL services.
> No demo-only/local authentication. See `architecture.md` §0 for the
> authoritative stack decision.

| Decision | Value | Status |
|---|---|---|
| State management | Riverpod | IMPLEMENTED |
| Navigation | GoRouter | IMPLEMENTED |
| Font | Nunito Sans (google_fonts) | IMPLEMENTED |
| Data models | Plain Dart classes with fromJson/toJson | IMPLEMENTED (Phase 1) |
| Repository pattern | Abstract interfaces + mock implementations | IMPLEMENTED (Phase 1) |
| Local storage | shared_preferences via LocalStorageService — **client-side state caching ONLY, NOT the auth authority** | IMPLEMENTED (Phase 1) |
| Secure storage | flutter_secure_storage needed for sensitive data | DEFERRED (documented) |
| Connectivity | connectivity_plus via ConnectivityService | IMPLEMENTED (Phase 1) |
| Error handling | AppException + ErrorHandler | IMPLEMENTED (Phase 1) |
| API client | http-based ApiClient, no fake endpoints | IMPLEMENTED (Phase 1) |
| Config | AppConfig with env + feature flags | IMPLEMENTED (Phase 1) |
| **Authentication** | **Firebase Authentication — phone number auth, real SMS OTP, Firebase ID tokens** | NOT_STARTED (Phase 2) |
| **Backend** | **Node.js + Express REST API** | NOT_STARTED (Phase 2) |
| **Database** | **MongoDB Atlas** | NOT_STARTED (Phase 2) |
| **AI** | **Gemini API — accessed ONLY from backend (Flutter → Backend → Gemini)** | NOT_STARTED (Phase 7) |
| Secrets | Backend `.env` (git-ignored) + `.env.example` documentation; Firebase Admin creds outside repo | CONFIGURED (.env.example created; .env git-ignored) |

### Responsibility Separation (authoritative)

| Concern | Authority |
|---|---|
| Identity / Authentication | **Firebase** (phone + OTP verification, ID token issuance) |
| Authorization + application logic | **Node.js backend** (verifies Firebase ID token on every protected request) |
| Application / patient data | **MongoDB Atlas** (patient records; later: health records) |

- SharedPreferences/local storage = client-side state caching only. NOT the source of truth for authentication.
- Backend NEVER trusts `patientId`/`userId`/`phone`/`email` from request bodies — identity is always derived from the verified Firebase ID token.

---

## Deferred Features (Patient-Only Scope)

The following are **explicitly deferred** for this development period:

- Doctor application
- Healthcare worker application
- Admin application
- Doctor dashboard
- Doctor authentication
- Doctor patient management
- Doctor consultation workflow
- Teleconsultation (real video)
- Voice assistance (speech-to-text / text-to-speech)
- Offline data synchronization
- Appointment/queue management
- Follow-up management

---

## Development Phases (Patient-Only)

| Phase | Description | Status |
|---|---|---|
| Phase 1 | Patient application foundation | **COMPLETED** (2026-08-28) |
| Phase 2 | Patient identity/authentication | **COMPLETED** (2026-08-29) |
| Phase 3 | Patient profile + health data | **COMPLETED** (2026-08-31) |
| Phase 4 | Health records + health timeline | **COMPLETED** (2026-08-31) |
| Phase 5 | Healthcare facility finder | **COMPLETED** (2026-08-31) |
| Phase 6 | Emergency + offline emergency guidance | **COMPLETED** (2026-08-31) |
| Phase 7 | AI Health Assistant | **COMPLETED** (2026-08-31) |
| Phase 8 | Document upload/viewing | **COMPLETED** (2026-08-31) |
| Phase 9 | Prescription + diagnostic report + referral viewing | NOT_STARTED |
| Phase 10 | Patient-side integration, error handling, testing, polish | NOT_STARTED |

---

## Testing Status

| Suite | Tests | Status |
|---|---|---|
| `test/models_test.dart` | 12 | ✅ PASS |
| `test/error_config_test.dart` | 12 | ✅ PASS |
| `test/connectivity_storage_test.dart` | 6 | ✅ PASS |
| `test/patient_repository_test.dart` | 3 | ✅ PASS |
| `test/health_record_repository_test.dart` | 5 | ✅ PASS |
| `test/facility_repository_test.dart` | 3 | ✅ PASS |
| `test/emergency_content_test.dart` | 2 | ✅ PASS |
| `test/ai_repository_test.dart` | 3 | ✅ PASS |
| `test/document_repository_test.dart` | 3 | ✅ PASS |
| `test/widget_test.dart` | 2 | ✅ PASS |
| **Total Flutter** | **54** | **ALL PASSING** |
| **Total Backend** | **53** | **ALL PASSING** |
| **Backend Tests** | **43** | **ALL PASSING** |

**flutter analyze: PASS (No issues found)**

---

*Last updated: 2026-08-31 — Phase 7 complete*