# DEVELOPMENT_PLAN.md

# RuralCare — MVP Development Plan

## 1. Purpose

This document defines the development sequence for the RuralCare MVP.

The project has a limited development window, so development must prioritize:

1. A working end-to-end healthcare journey
2. Emergency functionality
3. AI-assisted patient interaction
4. Doctor workflow
5. Patient continuity of care
6. Offline emergency capability
7. A polished and understandable UI

The team must avoid spending excessive time on infrastructure that does not improve the demonstrable MVP.

---

# 2. Development Philosophy

The project should be built incrementally.

Do not attempt to build the entire application in one step.

Each development phase should:

* Have a clear objective
* Produce working functionality
* Be tested before moving forward
* Avoid breaking previously completed functionality

The development agent should read the relevant project documentation before implementing a feature.

---

# 3. Development Order

Recommended order:

```text
Phase 1
Project Foundation
        ↓
Phase 2
Authentication + RBAC
        ↓
Phase 3
Patient Profiles + Health Records
        ↓
Phase 4
Doctor Workflow
        ↓
Phase 5
AI Health Assistant
        ↓
Phase 6
Emergency System
        ↓
Phase 7
Documents + AI Summaries
        ↓
Phase 8
Referrals + Diagnostics
        ↓
Phase 9
Appointments + Follow-ups
        ↓
Phase 10
Offline Functionality
        ↓
Phase 11
Voice Accessibility
        ↓
Phase 12
Integration Testing
        ↓
Phase 13
UI Polish + Demo Preparation
```

The exact order may be adjusted when implementation dependencies require it.

---

# 4. Phase 1 — Project Foundation

## Objective

Create the initial project structure and development environment.

### Tasks

* Initialize Flutter application
* Establish Flutter project structure
* Establish backend project
* Configure environment variables
* Establish API communication
* Configure MongoDB
* Configure Redis if required
* Establish development configuration
* Establish error handling structure
* Establish logging structure
* Establish reusable UI components
* Establish basic navigation

### Completion criteria

* Flutter application runs
* Backend runs
* Flutter can communicate with backend
* Database connection works
* Environment configuration works
* No secrets are committed to source control

---

# 5. Phase 2 — Authentication + RBAC

## Objective

Implement secure authentication and user roles.

### Tasks

* Registration/login
* Session/token handling
* Logout
* Role detection
* Patient role
* Healthcare-worker role
* Doctor role
* Admin role
* Backend authorization middleware
* Protected routes
* Frontend role-based navigation

### Completion criteria

A user can:

```text id="z5r7n2"
Login
 ↓
Backend authenticates
 ↓
Role determined
 ↓
Correct dashboard displayed
```

Users must not be able to access another role's protected APIs simply by changing frontend navigation.

---

# 6. Phase 3 — Patient Profiles + Health Records

## Objective

Create the patient-centered healthcare record.

### Tasks

* Patient profile
* Patient health record
* Health timeline
* Consultation model
* Prescription model
* Diagnostic model
* Referral model
* Follow-up model
* Document metadata
* Patient record APIs
* Patient record UI

### Completion criteria

A patient can:

* View profile
* View health history
* View consultations
* View prescriptions
* View diagnostics
* View referrals
* View follow-ups

The doctor can access authorized patient records.

---

# 7. Phase 4 — Doctor Workflow

## Objective

Create the basic clinical workflow before adding AI assistance.

### Tasks

* Doctor dashboard
* Patient list
* Consultation list
* Patient detail screen
* Consultation workspace
* Clinical notes
* Diagnosis entry
* Prescription creation
* Diagnostic request
* Referral creation
* Follow-up creation

### Completion criteria

A doctor can:

```text id="q8m3v5"
Open patient
 ↓
Review history
 ↓
Conduct consultation
 ↓
Record clinical information
 ↓
Create prescription/referral/follow-up
```

Clinical information must be explicitly created by the doctor.

---

# 8. Phase 5 — General AI Health Assistant

## Objective

Implement the patient-facing AI assistant.

### Tasks

* AI chat UI
* Backend AI endpoint
* AI service abstraction
* Conversation handling
* System instructions
* Safety rules
* Symptom conversation
* General health information
* Healthcare navigation guidance
* AI error handling

### Safety requirements

The AI must:

* Avoid diagnosis
* Avoid prescribing
* Avoid medication changes
* Avoid autonomous treatment decisions
* Escalate potential emergencies
* Use simple language
* Respect user permissions

### Completion criteria

A patient can communicate with the AI and receive useful general guidance without the AI acting as a doctor.

---

# 9. Phase 6 — Emergency System

## Objective

Create the fast emergency workflow.

This is a flagship MVP feature.

### Tasks

* Emergency home-screen button
* Emergency selection screen
* Emergency categories
* Emergency guidance screens
* Emergency facility search
* Location access
* Facility suitability logic
* Call facility
* Navigation
* Emergency event recording

### Initial emergency scenarios

* Snake bite
* Severe bleeding
* Breathing difficulty
* Unconsciousness
* Chest pain
* Severe allergic reaction

### Completion criteria

A user can:

```text id="m2k7v9"
Open app
 ↓
Press EMERGENCY
 ↓
Select emergency
 ↓
Find appropriate healthcare facility
 ↓
Call / Navigate
 ↓
Receive immediate guidance
```

---

# 10. Phase 7 — Emergency Offline Content

## Objective

Ensure critical emergency guidance does not depend on internet connectivity.

### Tasks

* Local emergency content
* Emergency illustrations
* Emergency text
* Emergency audio
* Optional short videos
* Offline emergency navigation
* Offline availability indicator

### Completion criteria

With internet disabled:

```text id="v6q3n8"
Open app
 ↓
Emergency
 ↓
Snake Bite
 ↓
Emergency instructions
```

must still work.

The app must not call the AI API to retrieve critical emergency instructions.

---

# 11. Phase 8 — Medical Documents

## Objective

Allow patients to upload previous medical information.

### Tasks

* Document upload UI
* Camera/image upload
* File selection
* Document classification
* Secure file upload
* Document metadata
* Document viewing
* Doctor document access

### Supported document types

* Prescription
* Lab report
* X-ray
* ECG
* Discharge summary
* Medical report
* Other

### Completion criteria

A patient can upload a previous prescription/report before a consultation.

An authorized doctor can view it.

---

# 12. Phase 9 — AI Patient Health Summary

## Objective

Reduce the time doctors spend reviewing historical information.

### Tasks

* Select relevant patient records
* Prepare structured AI input
* Generate patient summary
* Store summary metadata
* Display summary to doctor
* Link summary information to source records
* Allow doctor to open source documents

### Summary should include where available:

* Relevant medical history
* Recent consultations
* Diagnostic findings
* Prescription history
* Referrals
* Follow-ups

### Completion criteria

A doctor can open a patient and quickly understand their history without manually reading every previous document.

---

# 13. Phase 10 — Diagnostics

## Objective

Create the diagnostic workflow.

### Tasks

* Diagnostic request
* Diagnostic status
* Report upload
* Report association
* Doctor report viewing
* Patient report viewing
* Optional AI report summarization

### Completion criteria

```text id="h7m4q2"
Doctor
 ↓
Requests test
 ↓
Report uploaded
 ↓
Report stored
 ↓
Doctor views report
 ↓
Patient record updated
```

---

# 14. Phase 11 — Referral Tracking

## Objective

Create continuity across healthcare facilities.

### Tasks

* Referral creation
* Destination facility
* Referral reason
* Priority
* Referral status
* Referral timeline
* Patient referral view
* Doctor referral view
* Healthcare-worker referral view

### Completion criteria

A referral can move through:

```text id="x3n8p5"
Created
 ↓
Accepted
 ↓
Appointment Scheduled
 ↓
Completed
 ↓
Follow-up
```

---

# 15. Phase 12 — Appointment + Queue Management

## Objective

Manage patient consultations.

### Tasks

* Appointment creation
* Appointment list
* Appointment status
* Queue token
* Queue display
* Doctor queue
* Patient queue status

### Completion criteria

The patient can see:

```text id="r4q8m2"
Token: A27
Current: A23
```

The doctor/healthcare worker can manage the queue.

---

# 16. Phase 13 — Follow-Up Management

## Objective

Ensure healthcare continues after consultation.

### Tasks

* Follow-up creation
* Follow-up date
* Follow-up instructions
* Required diagnostic association
* Patient follow-up screen
* Reminder mechanism
* Completion status

### Completion criteria

A doctor can create a follow-up and the patient can see it.

---

# 17. Phase 14 — Healthcare Facility Finder

## Objective

Help patients discover appropriate public healthcare services.

### Tasks

* Facility list
* Facility details
* Location
* Distance
* Services
* Contact information
* Navigation
* Geospatial search
* Emergency suitability filtering

### Completion criteria

A patient can find an appropriate nearby facility.

---

# 18. Phase 15 — Voice Assistance

## Objective

Improve accessibility for users with limited literacy.

### Tasks

* Voice language selection
* Speech-to-text
* Text-to-speech
* Voice navigation
* AI voice interaction
* Emergency voice guidance

### Initial languages

* English
* Hindi
* Marathi

### Important

The application UI remains in plain English.

Voice assistance provides spoken guidance in the selected language.

---

# 19. Phase 16 — Offline Patient Data

## Objective

Allow selected workflows to continue during poor connectivity.

### Tasks

* Local storage
* Offline detection
* Offline data capture
* Sync queue
* Synchronization
* Conflict handling
* Sync status UI

### Initial offline scope

Prioritize:

* Emergency information
* Selected patient information
* Healthcare-worker data capture
* Basic emergency events

Do not attempt to make every online feature fully offline in the first MVP.

---

# 20. Phase 17 — Integration Testing

## Objective

Verify that the major workflows work together.

### Patient workflow

```text id="j6m2q8"
Register
 ↓
AI Assistant
 ↓
Healthcare Finder
 ↓
Consultation
 ↓
Upload Documents
 ↓
Doctor
 ↓
Prescription / Referral
 ↓
Follow-up
```

### Emergency workflow

```text id="p8v3n5"
Emergency
 ↓
Select Emergency
 ↓
Facility
 ↓
Call / Navigation
 ↓
Offline Guidance
```

### Existing patient workflow

```text id="q4r7m2"
Existing Record
 ↓
New Consultation
 ↓
Historical Summary
 ↓
Doctor
 ↓
Updated Record
```

---

# 21. Security Testing

Before demo preparation, verify:

### Authentication

* Invalid login rejected
* Expired session handled
* Logout works

### Authorization

* Patient cannot access another patient
* Patient cannot create prescriptions
* Healthcare worker cannot perform unauthorized doctor actions
* Doctor cannot access unauthorized patients
* Admin permissions are controlled

### Documents

* Unauthorized users cannot access medical documents
* Document URLs are not publicly exposed

### AI

* AI cannot directly modify clinical records
* AI cannot directly create prescriptions
* AI provider credentials are not exposed to Flutter

---

# 22. Offline Testing

Test the application with:

* Wi-Fi disabled
* Mobile data disabled
* Intermittent connectivity
* Connection restored after offline data creation

Verify:

```text id="n8c5v3"
Offline
 ↓
Data saved
 ↓
Connection restored
 ↓
Sync
 ↓
Server confirms
```

No silent data loss should occur.

---

# 23. UI Testing

Test the application using a first-time user mindset.

Verify:

* Emergency button is obvious
* Primary actions are easy to identify
* Text is readable
* Buttons are large enough
* Icons are understandable
* Voice controls are discoverable
* Error messages are simple
* Loading states are clear
* Offline state is understandable

---

# 24. Demo Preparation

The final demo should focus on a small number of powerful journeys.

### Demo 1 — AI Assistance

```text id="w5m8q2"
Patient
 ↓
Voice / Text
 ↓
AI understands concern
 ↓
General guidance
 ↓
Healthcare pathway
```

### Demo 2 — Emergency

```text id="c3n7v4"
Emergency
 ↓
Snake Bite
 ↓
Suitable Facility
 ↓
Call / Directions
 ↓
Offline Visual Guidance
```

### Demo 3 — Doctor

```text id="q8r2m6"
Doctor opens patient
 ↓
AI Summary
 ↓
Previous Reports
 ↓
Consultation
 ↓
Prescription / Referral
```

### Demo 4 — Continuity

```text id="p4v9n2"
Referral
 ↓
Hospital
 ↓
Consultation
 ↓
Follow-up
 ↓
Patient Record
```

---

# 25. Ten-Day Execution Strategy

The project should follow this priority structure.

## Days 1–2

### Foundation

* Flutter project
* Backend
* Database
* Authentication
* Roles
* Basic UI shell

---

## Days 3–4

### Core Healthcare Workflow

* Patient profile
* Health record
* Doctor dashboard
* Consultation
* Prescriptions
* Diagnostics
* Documents

---

## Days 5–6

### AI + Emergency

* General AI assistant
* AI safety
* Emergency mode
* Emergency facility finder
* Offline emergency content

---

## Days 7–8

### Continuity

* AI patient summary
* Referral tracking
* Follow-ups
* Appointment/queue
* Facility discovery

---

## Day 9

### Accessibility + Offline

* Voice assistance
* Hindi/Marathi voice
* Offline data
* Synchronization
* Error handling

---

## Day 10

### Stabilization

* Bug fixing
* Integration testing
* UI polish
* Performance checks
* Demo data
* Demo rehearsal
* Presentation preparation

If a feature threatens the stability of the core workflow, reduce its scope rather than delaying the entire MVP.

---

# 26. Feature Freeze Rule

Before the final demo:

> **Do not add major new features.**

The final development period should focus on:

* Fixing bugs
* Improving UX
* Improving reliability
* Improving demo flow
* Testing emergency functionality
* Testing offline functionality

A stable smaller MVP is better than an unstable feature-rich application.

---

# 27. Definition of Done

A feature is considered complete only when:

1. UI is implemented.
2. Backend/API functionality is implemented where required.
3. Database integration works.
4. Authorization is implemented.
5. Loading state exists.
6. Error state exists.
7. Offline behavior is defined.
8. The feature has been tested.
9. It does not break existing functionality.
10. Documentation/progress is updated.

---

# 28. AI Agent Development Rules

When Antigravity implements a feature:

1. Read `PROJECT_OVERVIEW.md`.
2. Read `FEATURES.md`.
3. Read `USER_ROLES.md`.
4. Read `ARCHITECTURE.md`.
5. Read `DATABASE.md`.
6. Read `AI_SAFETY.md` if AI is involved.
7. Read `UI_UX.md` for UI work.
8. Check `PROGRESS.md`.
9. Implement only the requested phase/feature.
10. Test the implementation.
11. Update `PROGRESS.md`.

The agent should not silently redesign the system architecture.

---

# 29. Change Management

If implementation requires a significant architectural change:

```text id="v7m3q8"
Identify Problem
      ↓
Explain Proposed Change
      ↓
Evaluate Impact
      ↓
Update Architecture Documentation
      ↓
Implement
      ↓
Test
```

Do not make major architectural changes silently.

---

# 30. Scope Control

When development time becomes limited, use this priority order:

```text id="m2q8v5"
P0 Critical
   ↓
P1 Important
   ↓
P2 Future
```

Never sacrifice:

* Emergency safety
* Patient privacy
* Authentication
* Authorization
* AI safety
* Core healthcare workflow

for additional visual features.

---

# 31. Final MVP Architecture Goal

At the end of the development period, the MVP should demonstrate:

```text id="x8n4q2"
                    PATIENT
                       │
       ┌───────────────┼────────────────┐
       │               │                │
       ▼               ▼                ▼
   AI Assistant    Emergency       Healthcare
                       │             Finder
                       ▼
                Suitable Facility
                       │
                       ▼
                  Doctor
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
          Records  Diagnostics Referral
             │         │         │
             └─────────┼─────────┘
                       ▼
                   Follow-up
```

The system should demonstrate that these are connected rather than isolated features.

---

# 32. Final Development Principle

> **Build the smallest reliable system that demonstrates the complete healthcare journey.**

Do not optimize for the number of screens.

Optimize for:

**Access → Assistance → Emergency Response → Consultation → Continuity → Follow-up**
