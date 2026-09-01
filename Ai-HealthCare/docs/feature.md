# FEATURES.md

# RuralCare — Feature Specification

## 1. Purpose

This document defines the functional behavior of the RuralCare MVP.

It describes:

* What each feature does
* Who can use it
* What information it requires
* What the system should produce
* Important safety constraints
* What is inside and outside the MVP

This document should be treated as the functional source of truth when implementing the application.

---

# 2. User Roles

The MVP contains four primary roles:

1. Patient
2. Healthcare Worker
3. Doctor
4. Administrator

Each role must have appropriate permissions and must only access information necessary for its responsibilities.

---

# 3. Feature Priority

Feature priorities are:

* **P0 — Critical:** Required for the MVP
* **P1 — Important:** Should be implemented if feasible within the MVP timeline
* **P2 — Future:** Not required for the initial MVP

---

# 4. Patient Features

## 4.1 Patient Registration & Profile

**Priority:** P0

### Purpose

Create a persistent identity for the patient so that their healthcare information can be maintained over time.

### Patient information

The MVP may store:

* Full name
* Age/date of birth
* Gender
* Phone number
* Address/location
* Preferred spoken language
* Emergency contact
* Basic relevant medical information

### Requirements

* Registration should be simple.
* The patient should not have to repeatedly enter the same information.
* The patient profile should be associated with their longitudinal health record.

---

# 5. Patient Home Screen

**Priority:** P0

The home screen should provide immediate access to the most important actions.

Primary actions:

```text
🚨 EMERGENCY

🤖 HEALTH ASSISTANT

👨‍⚕️ TALK TO DOCTOR

🏥 FIND HEALTHCARE

📋 MY HEALTH RECORD
```

Secondary actions may include:

```text
📅 APPOINTMENTS

📄 MY REPORTS

🔄 REFERRALS

🔔 FOLLOW-UPS
```

The interface must remain simple and visually understandable.

---

# 6. General AI Health Assistant

**Priority:** P0

## Purpose

Provide accessible general health assistance without replacing a doctor.

## User interaction

The patient can:

* Type questions
* Speak to the assistant
* Receive text responses
* Receive voice responses
* Communicate in supported languages

Initial voice languages:

* English
* Hindi
* Marathi

## AI capabilities

The AI may:

* Ask questions about symptoms
* Help the patient describe their symptoms
* Explain general health concepts
* Explain medical terminology
* Explain previously uploaded documents
* Help prepare questions for a doctor
* Suggest an appropriate healthcare pathway
* Encourage professional medical attention when appropriate
* Help navigate healthcare services

## AI restrictions

The AI must NOT:

* Claim to diagnose a disease
* Prescribe medication
* Recommend starting medication
* Recommend stopping medication
* Change medication dosage
* Make definitive treatment decisions
* Pretend to be a doctor
* Present uncertain information as a confirmed diagnosis

### Example

Acceptable:

> "Difficulty breathing can sometimes indicate a serious health problem. You should seek medical attention promptly."

Not acceptable:

> "You have pneumonia. Take this medicine."

---

# 7. AI Conversation Safety

**Priority:** P0

The AI should recognize situations where the patient may require urgent or emergency care.

If potentially serious symptoms are identified, the assistant should:

1. Explain that the situation may require urgent professional attention.
2. Avoid attempting a definitive diagnosis.
3. Offer the emergency or healthcare-access pathway.
4. Provide appropriate general safety guidance when available.
5. Avoid medication recommendations.

Emergency escalation must be deterministic and safety-controlled where possible rather than relying entirely on free-form LLM reasoning.

---

# 8. Emergency Assistance

**Priority:** P0

## Purpose

Provide rapid access to appropriate healthcare and immediate safety guidance during emergencies.

## Entry point

The patient should be able to access emergency mode directly from the home screen.

The emergency button must be highly visible.

## Initial emergency categories

The MVP should support predefined emergency scenarios such as:

* Snake bite
* Severe bleeding
* Breathing difficulty
* Unconsciousness
* Chest pain
* Severe allergic reaction
* Other emergency

Additional emergency scenarios can be added later.

---

# 9. Emergency Workflow

The emergency workflow should minimize the number of interactions required.

```text
Emergency
   ↓
Select / identify emergency
   ↓
Confirm location
   ↓
Find suitable healthcare facility
   ↓
Contact / call / navigate
   ↓
Show immediate safety guidance
   ↓
Reach healthcare facility
```

The patient should never have to navigate through the normal application to reach emergency assistance.

---

# 10. Emergency Facility Matching

**Priority:** P0

The application should attempt to identify a healthcare facility appropriate for the emergency.

Selection factors may include:

* Distance
* Facility type
* Relevant services
* Emergency capability
* Availability information where reliable data exists

The system should not assume that the geographically closest facility is always the most suitable.

If reliable facility-capability information is unavailable, the system should clearly communicate the limitation rather than inventing capabilities.

---

# 11. Emergency Contact & Navigation

**Priority:** P0

The emergency screen should provide:

* Call facility
* Call emergency service where available
* Open navigation
* Display facility address
* Display relevant contact information

The application should minimize unnecessary steps.

---

# 12. Emergency First-Response Guidance

**Priority:** P0

The application should provide predefined, clinically reviewed emergency guidance.

Guidance should use:

* Illustrations
* Images
* Short videos where appropriate
* Very short text
* Voice instructions

Instructions should be presented one step at a time.

Example structure:

```text
STEP 1
[Visual]

Do this.

🔊 Listen
```

Then:

```text
STEP 2
[Visual]

Do this.

🔊 Listen
```

The application should also clearly show important actions to avoid.

---

# 13. Snake-Bite Emergency Guidance

**Priority:** P0

Snake-bite assistance is a flagship emergency use case.

The emergency module should provide clinically validated first-response information, including appropriate actions and actions to avoid.

The application must NOT generate snake-bite procedures dynamically using a general-purpose AI model.

Emergency instructions should be stored as controlled content so they remain:

* Predictable
* Clinically reviewable
* Offline accessible
* Consistent

---

# 14. Offline Emergency Mode

**Priority:** P0

Critical emergency guidance must work without an internet connection.

Offline emergency resources should include:

* Emergency instructions
* Visual instructions
* Voice/audio instructions where feasible
* Important emergency contacts
* Cached healthcare facility information where appropriate

The application should never require an AI API call to display critical emergency instructions.

---

# 15. Healthcare Facility Finder

**Priority:** P0

Patients should be able to search for healthcare facilities.

The finder should support:

* Current location
* Manual location selection
* Facility type
* Healthcare services
* Distance
* Contact information
* Navigation

Possible facility types:

* Sub-centre
* PHC
* Rural hospital
* District hospital
* Other relevant public healthcare facilities

---

# 16. Healthcare Service Discovery

**Priority:** P1

Patients should be able to understand what services are available at nearby facilities.

Example:

```text
PHC A

Distance: 4.2 km

Services:
✓ General OPD
✓ Vaccination
✓ Basic diagnostics
```

This addresses lack of awareness about available public healthcare services.

---

# 17. Teleconsultation

**Priority:** P0

Patients should be able to request a consultation with a doctor.

Basic workflow:

```text
Patient
   ↓
Request consultation
   ↓
Select available service/doctor
   ↓
Join queue / appointment
   ↓
Doctor reviews patient information
   ↓
Consultation
   ↓
Doctor records outcome
```

The MVP may use a practical video/audio communication mechanism rather than building a sophisticated telemedicine infrastructure from scratch.

---

# 18. Pre-Consultation Document Upload

**Priority:** P0

Patients should be able to upload medical documents before a consultation.

Supported document types may include:

* Prescriptions
* Blood reports
* Diagnostic reports
* X-rays
* ECG reports
* Discharge summaries
* Other medical documents

The system should associate documents with the correct patient.

---

# 19. Longitudinal Patient Health Record

**Priority:** P0

The application should maintain a persistent health timeline.

The record may contain:

```text
Patient
 ├── Consultations
 ├── Diagnoses
 ├── Prescriptions
 ├── Diagnostics
 ├── Referrals
 ├── Follow-ups
 └── Uploaded documents
```

Each new consultation should add to the patient's existing record rather than creating an isolated record.

---

# 20. Patient Health Timeline

**Priority:** P0

The patient should be able to view their history chronologically.

Example:

```text
25 Aug
Doctor consultation
       ↓
Blood test requested

26 Aug
Blood report uploaded
       ↓
Report reviewed

27 Aug
Referral created
       ↓
District Hospital

30 Aug
Specialist consultation
```

The timeline should be easy to understand.

---

# 21. AI-Generated Patient Summary

**Priority:** P0

## Purpose

Help doctors understand a patient's relevant history quickly.

Instead of requiring the doctor to manually inspect every historical document, the system should generate a concise summary.

Possible summary sections:

### Patient Overview

* Relevant existing conditions
* Important medical history

### Recent Consultations

* Recent complaints
* Doctor-entered findings
* Recent clinical events

### Diagnostic Summary

* Important previous findings
* Relevant trends
* Abnormal values that appear in source reports

### Medication History

* Previously prescribed medications
* Prescription dates

The system must distinguish historical prescriptions from current prescriptions.

### Referral & Follow-up

* Previous referrals
* Pending referrals
* Upcoming follow-ups

---

# 22. AI Summary Safety

**Priority:** P0

AI-generated summaries must:

* Clearly be identified as AI-generated
* Preserve access to original documents
* Avoid inventing medical history
* Avoid presenting assumptions as facts
* Avoid replacing the original clinical record

Doctors should be able to open the source document supporting important information.

---

# 23. Doctor Dashboard

**Priority:** P0

The doctor dashboard should provide:

* Today's consultations
* Waiting patients
* Patient details
* Current complaint
* Patient summary
* Previous consultations
* Diagnostic reports
* Prescription history
* Referrals
* Follow-ups

The most relevant information should appear first.

---

# 24. Doctor Consultation Workspace

**Priority:** P0

During a consultation, the doctor should be able to:

* View patient summary
* View original documents
* View diagnostic reports
* Record consultation notes
* Enter diagnosis
* Create prescription
* Request diagnostics
* Create referral
* Schedule follow-up

Only the doctor should be able to create clinical decisions within the normal workflow.

---

# 25. Prescription Management

**Priority:** P0

Doctors can create prescriptions.

Patients can view prescriptions associated with their consultations.

The AI may explain an existing prescription in simple language but must not modify or create prescriptions.

---

# 26. Diagnostic Management

**Priority:** P0

The system should support:

```text
Doctor / Healthcare Worker
        ↓
Diagnostic request
        ↓
Patient completes test
        ↓
Report uploaded
        ↓
Stored in patient record
        ↓
Doctor reviews
```

Reports should be associated with the corresponding patient and consultation where possible.

---

# 27. Diagnostic Report Summarization

**Priority:** P1

AI may assist in summarizing lengthy diagnostic reports.

The summary should:

* Identify information explicitly present in the report
* Avoid unsupported conclusions
* Preserve access to the original report
* Clearly indicate that it is AI-generated

The feature is intended to improve information accessibility, not perform autonomous diagnosis.

---

# 28. Referral Management

**Priority:** P0

Doctors or authorized healthcare workers can create referrals.

A referral should contain:

* Patient
* Referring facility/doctor
* Destination facility
* Reason
* Priority
* Date
* Status
* Relevant supporting documents

---

# 29. Referral Tracking

**Priority:** P0

Referral statuses may include:

```text
Created
   ↓
Accepted
   ↓
Appointment Scheduled
   ↓
Consultation Completed
   ↓
Follow-up Required
   ↓
Completed
```

Additional statuses may be used for:

* Rejected
* Cancelled
* Missed appointment
* Awaiting action

Patients should be able to see the appropriate status.

---

# 30. Appointment & Queue Management

**Priority:** P1

Patients should be able to:

* Request appointments
* View appointment information
* Receive queue/token numbers
* See queue status

Healthcare workers/doctors should be able to:

* Manage queues
* Call the next patient
* Mark consultation status

---

# 31. Follow-Up Management

**Priority:** P1

Doctors can create follow-up plans.

A follow-up can contain:

* Date
* Reason
* Required diagnostics
* Instructions
* Referral requirements

Patients should be able to see upcoming follow-ups.

---

# 32. Voice Assistance

**Priority:** P1

Voice assistance is an accessibility layer rather than a replacement for the English UI.

### UI

The application remains in:

**Plain English**

### Voice

The application may provide spoken guidance in:

* English
* Hindi
* Marathi

The voice system should help with:

* Navigation
* Button/action explanations
* Emergency instructions
* AI conversation
* Basic healthcare information

The UI should remain visually simple even when voice assistance is enabled.

---

# 33. Low-Literacy UX

**Priority:** P0

The patient interface must be designed for users who may have limited literacy or digital experience.

Design requirements:

* Large touch targets
* Large icons
* Minimal text
* Simple English
* One primary action per screen where possible
* Strong visual hierarchy
* Consistent iconography
* Voice assistance
* Visual emergency instructions
* Avoid technical terminology
* Avoid dense forms

The application should not require the user to understand medical terminology to navigate basic workflows.

---

# 34. Offline Data Capture

**Priority:** P1

Where technically appropriate, the application should allow selected information to be captured while offline.

Examples:

* Basic patient information
* Healthcare-worker observations
* Emergency information
* Basic consultation information

Data should be synchronized when connectivity returns.

---

# 35. Offline Synchronization

**Priority:** P1

The system should distinguish between:

### Offline-created data

Data created while disconnected.

### Server data

Data already synchronized with the backend.

When connectivity returns:

```text
Offline Data
     ↓
Sync Queue
     ↓
Server
     ↓
Confirmation
```

Synchronization must avoid accidental duplication or silent data loss.

---

# 36. Security & Privacy

**Priority:** P0

Medical information is sensitive.

The MVP should implement:

* Authentication
* Role-based authorization
* Secure API communication
* Access control
* Protected medical documents
* Appropriate session management
* Auditability of important clinical actions where feasible

Patients must not be able to access another patient's medical records.

Doctors and healthcare workers should only access patient information they are authorized to access.

---

# 37. AI Data Handling

**Priority:** P0

AI services should receive only the information necessary for the requested operation.

Examples:

* Symptom conversation → relevant current conversation
* Patient summary → authorized patient records
* Document explanation → selected document
* Diagnostic summary → selected diagnostic report

The system should avoid unnecessarily sending the patient's entire medical history to an AI service.

---

# 38. Emergency Safety Principle

Emergency functionality has higher priority than convenience.

If the system cannot confidently determine an appropriate healthcare facility or provide reliable information, it should:

1. Encourage immediate professional/emergency assistance.
2. Provide known emergency contacts.
3. Provide safe, predefined emergency guidance where available.
4. Avoid inventing information.

---

# 39. Feature Boundaries

The MVP is intentionally NOT:

* An autonomous doctor
* A diagnostic engine
* A medication-prescribing AI
* A replacement for PHCs
* A replacement for hospitals
* A replacement for emergency medical professionals
* A fully automated clinical decision-making system

The application is an **AI-assisted healthcare access, coordination, information, and support platform**.

---

# 40. MVP End-to-End Demonstration

The final MVP should be capable of demonstrating at least these complete journeys.

## Journey A — New Patient

```text
Register
 ↓
AI Health Assistant
 ↓
Describe symptoms
 ↓
General guidance
 ↓
Request teleconsultation
 ↓
Upload previous prescriptions/reports
 ↓
Doctor opens patient profile
 ↓
AI generates health summary
 ↓
Doctor reviews source documents
 ↓
Teleconsultation
 ↓
Doctor makes clinical decision
 ↓
Prescription / diagnostic / referral
 ↓
Record updated
```

---

## Journey B — Existing Patient

```text
Open app
 ↓
Existing health record
 ↓
AI assistant / consultation
 ↓
Doctor accesses previous history
 ↓
AI-generated summary
 ↓
Doctor reviews relevant records
 ↓
Consultation
 ↓
Updated prescription / diagnostic / referral
 ↓
Follow-up
```

---

## Journey C — Emergency

```text
Open app
 ↓
🚨 EMERGENCY
 ↓
Snake Bite
 ↓
Find suitable healthcare facility
 ↓
Call / Navigation
 ↓
Offline visual instructions
 ↓
Offline voice instructions
 ↓
Reach healthcare facility
```

---

## Journey D — Referral

```text
PHC / Doctor
 ↓
Referral created
 ↓
Destination hospital
 ↓
Appointment
 ↓
Specialist consultation
 ↓
Referral status updated
 ↓
Patient record updated
 ↓
Follow-up
```

---

# 41. Definition of MVP Success

The MVP is considered functionally successful if a demonstration can show:

1. A patient using the application without needing complex navigation.
2. A patient interacting with the general AI assistant.
3. The AI providing safe general guidance without diagnosing or prescribing.
4. A patient accessing emergency assistance.
5. Emergency instructions working without internet connectivity.
6. A suitable healthcare facility being identified.
7. A patient requesting a teleconsultation.
8. A patient uploading previous medical documents.
9. A doctor viewing an AI-generated patient history summary.
10. The doctor accessing original supporting documents.
11. A doctor creating a clinical record.
12. A referral being created and tracked.
13. Diagnostic information becoming part of the longitudinal record.
14. A follow-up being recorded.
15. The system demonstrating continuity of care across multiple interactions.

---

# 42. Product Philosophy

Every feature should answer at least one of these questions:

> Does this improve access?

> Does this improve continuity?

> Does this improve understanding?

> Does this improve coordination?

> Does this improve emergency response?

> Does this reduce unnecessary burden on patients or healthcare workers?

If a proposed feature does not contribute meaningfully to one of these objectives, it should not automatically be added to the MVP.
