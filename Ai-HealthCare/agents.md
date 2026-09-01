# RuralCare — Agent Instructions

## ⚠️ MANDATORY FIRST STEP — Read Memory File

**Before doing ANYTHING else in any session, you MUST read the memory file:**

```
c:\Users\User\Desktop\AiProjects\flutter_application_1\Ai-HealthCare\memory.md
```

The `memory.md` file is the authoritative record of:
- What has already been built
- What decisions have been made
- What is in progress
- What has NOT been started yet
- Open decisions that need answers before proceeding
- The Stitch project and screen inventory
- The correct next steps

**Do not start any work until you have read and understood `memory.md`.**

After reading `memory.md`, also read any documentation files in `docs/` that are relevant to your current task.

---

## Project Overview

RuralCare is an AI-**assisted** healthcare access application for rural and underserved communities in India.

It is built in **Flutter** (mobile: Android + iOS).

It is **NOT** an AI diagnostic application. The AI is a health assistant only.

---

## Agent Behaviour Rules

### General

1. Always read `memory.md` first, every session, no exceptions.
2. Always read the relevant `docs/` files before starting a feature.
3. After completing significant work, **update `memory.md`** to reflect what was done.
4. Do not make architectural decisions without documenting them in `memory.md`.
5. Do not deviate from the design system established in Stitch without explicit user instruction.
6. If you are unsure about a requirement, stop and ask. Do not guess and implement.

### Coding Rules

7. Flutter only. No web frontend. No separate admin web app unless explicitly decided.
8. Do not implement backend code until the backend architecture is decided and documented.
9. Do not implement AI APIs until the AI integration design is decided and documented.
10. Do not implement authentication until the auth strategy is decided and documented.
11. Follow the RuralCare design system strictly (colors, fonts, touch targets, components).
12. Use feature-based folder structure in Flutter (not layer-based).
13. Write clean, well-commented Flutter code.

### Safety Rules (Non-Negotiable)

14. **Never** design or implement UI that implies AI is a doctor.
15. **Never** design or implement UI that implies AI provides confirmed diagnosis.
16. **Never** design or implement UI that implies AI prescribes medication.
17. **Never** design or implement UI that implies AI replaces a healthcare professional.
18. Emergency instructions must come from **controlled content**, not AI-generated responses.
19. Emergency mode must work **offline**.
20. AI output must always show the disclaimer: "AI Health Assistant — Not a Doctor".

### UI Rules

21. Patient UI must use **Simple English** only. No Marathi or Hindi in the UI itself.
22. All interactive elements: minimum 48dp touch target.
23. All buttons: minimum 56dp height.
24. Emergency buttons: minimum 80dp height.
25. Every status must use **Color + Icon + Text** — never color alone.
26. Offline state must show yellow banner with `wifi_off` icon.
27. Emergency mode: full-screen red background (`#B71C1C`), completely different visual language.

---

## Key Reference Files

| File | Purpose |
|---|---|
| `memory.md` | **Read first. Always.** Project state, session log, decisions. |
| `docs/projectOverview.md` | High-level product description |
| `docs/feature.md` | Full feature list |
| `docs/userRoles.md` | Patient, HW, Doctor, Admin role descriptions |
| `docs/architecture.md` | Technical architecture decisions |
| `docs/database.md` | Data models and schema |
| `docs/aiSafety.md` | AI safety rules and UI constraints |
| `docs/uiUx.md` | UI/UX design guidelines |
| `docs/developmentWorkflow.md` | Development process and workflow |
| `docs/progress.md` | Feature-level progress tracking |

---

## Stitch Design References

**Project ID:** `5525175805498675419`
**Design System ID:** `assets/9801910436744714884`
**Project URL:** https://stitch.withgoogle.com/projects/5525175805498675419

Full screen inventory is in `memory.md`.

---

## Current Phase

> ✅ **Phase 0 — Stitch UI Design: PARTIALLY COMPLETE** (Patient screens designed in Stitch)
>
> ✅ **Phase 1 — Patient Application Foundation: COMPLETED** (Data models, storage, network, error handling, Riverpod)
>
> ✅ **Phase 2 — Patient Identity / Authentication: COMPLETED** (Firebase Phone Auth, OTP verification, backend session exchange, GoRouter auth guards)
>
> ✅ **Phase 3 — Patient Profile + Health Data: COMPLETED** (ApiPatientRepository, profile edit, registration data persistence, live dynamic screens)
>
> ✅ **Phase 4 — Health Records + Timeline: COMPLETED** (ApiHealthRecordRepository, Mongoose clinical schemas, REST records API, dynamic records hub, timeline, and clinical views)
>
> ✅ **Phase 5 — Healthcare Facility Finder: COMPLETED** (ApiFacilityRepository, Mongoose Facility & Doctor schemas, search & category filters, dynamic facility & doctor screens)
>
> ✅ **Phase 6 — Emergency + Offline Guidance: COMPLETED** (Comprehensive 10-topic first-aid dataset, EmergencyService, 108 emergency dialer, offline sync & guidance)
>
> ✅ **Phase 7 — AI Health Assistant: COMPLETED** (Backend Gemini API integration, clinical safety guardrails, emergency keyword detection, persistent chat history in MongoDB Atlas, dynamic Flutter chat)
>
> ✅ **Phase 8 — Document Upload: COMPLETED** (Mongoose document schema, upload flow, camera/gallery/pdf picker, base64/URL support, document viewer)
>
> ✅ **Phase 9 — Records Viewing: COMPLETED** (Dedicated list screens, category filtering, search, Riverpod family providers, enhanced detail views with actions)
>
> ✅ **Phase 10 — Integration + Polish: COMPLETED** (Global reactive offline banner, teleconsultation polish, doctor appointment booking modal, comprehensive integration tests)
>
> 🚀 **All 10 Patient Mobile Application Phases are FULLY COMPLETED!**

See `memory.md` for full architectural records, session logs, and project decisions.

---

*This file was last updated: 2026-09-01 (Session 15)*
