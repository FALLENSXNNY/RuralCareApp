# PROJECT_OVERVIEW.md

# RuralCare — AI-Assisted Public Healthcare Access Platform

## 1. Project Overview

RuralCare is an AI-assisted healthcare access and coordination platform designed to improve access, continuity, and quality of public healthcare services for people living in rural and underserved communities.

The platform is designed around a simple principle:

> **AI should help people access, understand, prepare for, and navigate healthcare — while qualified healthcare professionals remain responsible for medical decisions.**

The application does **not** attempt to replace doctors or function as an autonomous diagnostic system.

Instead, it connects patients, healthcare workers, doctors, diagnostic services, emergency services, and public healthcare facilities through a unified platform.

---

## 2. Problem Being Addressed

Rural and underserved communities can experience:

* Long travel distances to suitable healthcare facilities
* Limited access to specialists
* Shortages of healthcare staff
* Irregular access to diagnostics
* Fragmented medical records
* Delayed or poorly tracked referrals
* Limited awareness of available public healthcare services
* Language and health-literacy barriers
* Poor or unreliable internet connectivity
* Difficulty understanding medical documents
* Financial barriers to immediate healthcare access

Patients may also move between sub-centres, Primary Health Centres (PHCs), rural hospitals, and district hospitals without their medical information being easily accessible across facilities.

RuralCare aims to improve this journey without attempting to replace or bypass the public healthcare system.

---

## 3. Product Vision

RuralCare should provide a single, accessible platform through which a patient can:

1. Understand their health concern through a safe AI conversation.
2. Receive general health information and guidance.
3. Find an appropriate healthcare facility.
4. Access emergency assistance when necessary.
5. Receive visual and voice-based emergency instructions.
6. Request or attend teleconsultations.
7. Maintain a longitudinal health record.
8. Upload previous medical documents before consultation.
9. Allow doctors to quickly understand relevant medical history.
10. Track referrals and follow-ups.
11. Access important healthcare information even when offline.

The platform should simultaneously provide healthcare workers and doctors with tools that reduce administrative friction and improve continuity of care.

---

## 4. Target Users

### 4.1 Patients

Primary users of the application.

Patients may have:

* Limited medical knowledge
* Limited digital literacy
* Limited literacy
* Limited internet connectivity
* Limited ability to travel
* Limited ability to afford immediate private healthcare

The patient experience must therefore prioritize simplicity, clarity, visual communication, and voice assistance.

---

### 4.2 Healthcare Workers

Examples include frontline/community healthcare workers and PHC staff.

They may use the platform to:

* Register patients
* Record basic patient information
* Record symptoms and observations
* Assist with healthcare navigation
* Manage patient queues
* Initiate referrals
* Track patient progress
* Assist patients with teleconsultations

---

### 4.3 Doctors

Doctors use the platform to:

* View patient information
* Review current complaints
* View summarized medical history
* Review previous diagnostics
* Review prescriptions and consultation history
* Conduct teleconsultations
* Record clinical notes
* Enter diagnoses
* Create prescriptions
* Request diagnostics
* Create referrals
* Schedule follow-ups

Doctors remain the final authority for diagnosis, treatment, prescriptions, and other clinical decisions.

---

### 4.4 Healthcare Administrators

Administrators may manage:

* Healthcare facilities
* Doctors
* Healthcare workers
* Services offered by facilities
* Availability information
* System-level configuration

Administrative functionality should remain separate from patient-facing functionality.

---

## 5. Core Product Areas

RuralCare consists of the following major product areas:

### A. Patient Health Record

A persistent longitudinal record containing relevant healthcare information such as:

* Consultations
* Doctor-entered diagnoses
* Prescriptions
* Diagnostic reports
* Referrals
* Follow-ups
* Uploaded medical documents

Previously stored information should remain available for future consultations.

---

### B. General AI Health Assistant

A conversational AI assistant that helps patients:

* Describe their symptoms
* Answer health-related questions
* Understand general health information
* Understand existing medical documents
* Prepare for consultations
* Navigate healthcare services
* Understand when professional medical attention may be appropriate

The AI must not function as an autonomous doctor.

It must not independently:

* Diagnose diseases
* Prescribe medicines
* Recommend starting or stopping medication
* Make treatment decisions
* Replace professional medical judgment

---

### C. Emergency Assistance

A dedicated emergency experience for situations such as:

* Snake bites
* Severe bleeding
* Breathing difficulty
* Unconsciousness
* Chest pain
* Severe allergic reactions
* Other predefined emergency scenarios

The emergency workflow should prioritize:

1. Immediate recognition of the emergency pathway
2. Contacting or locating an appropriate healthcare facility
3. Emergency service/ambulance access where available
4. Navigation to an appropriate facility
5. Immediate first-response guidance
6. Visual instructions
7. Voice instructions
8. Offline availability of critical guidance

Emergency guidance must be based on reliable, clinically reviewed information.

AI must not freely invent emergency procedures.

---

### D. Healthcare Facility Finder

Patients should be able to find relevant healthcare facilities based on:

* Location
* Facility type
* Available services
* Suitability for the patient's situation
* Contact information
* Distance

For emergency situations, the system should prioritize an appropriate facility rather than simply selecting the geographically closest facility.

---

### E. Teleconsultation

Patients should be able to request or attend remote consultations with doctors.

Before a consultation, doctors should be able to access relevant patient information.

The consultation workflow should support:

* Patient complaint
* Medical history
* Previous documents
* Diagnostic reports
* AI-generated patient summary
* Doctor notes
* Diagnosis
* Prescription
* Referral
* Follow-up

---

### F. AI-Assisted Clinical Summary

The system should transform large amounts of historical patient information into a concise summary for doctors.

The summary may include:

* Relevant previous conditions
* Previous consultations
* Diagnostic findings
* Diagnostic trends
* Previous prescriptions
* Relevant historical information
* Pending referrals
* Follow-up information

Original source documents must remain accessible.

AI-generated summaries are assistive and must not replace the original clinical records.

---

### G. Diagnostic Management

Patients and healthcare workers should be able to upload diagnostic reports.

The system should associate reports with the correct patient and make them accessible to authorized doctors.

AI may assist with summarization and organization of reports, but must not independently diagnose a patient from the report.

---

### H. Referral Tracking

The system should allow referrals to be created and tracked through stages such as:

* Referral created
* Referral accepted
* Appointment scheduled
* Consultation completed
* Follow-up required
* Referral completed

Patients, healthcare workers, and authorized doctors should be able to see appropriate referral status.

---

### I. Appointment and Queue Management

Patients should be able to request appointments and receive queue/token information.

Healthcare workers and doctors should be able to manage queues.

The system may use AI-assisted triage information to help prioritize attention, but final clinical prioritization remains under healthcare-professional control.

---

### J. Follow-up Management

Doctors should be able to create follow-up plans containing:

* Follow-up date
* Required tests
* Instructions
* Referral requirements
* Next consultation

Patients should receive appropriate reminders.

---

## 6. Accessibility Philosophy

The application interface will use **plain English**.

The UI itself will not be converted into a multilingual text-heavy interface.

Instead, accessibility will be provided through:

* Large buttons
* Large recognizable icons
* Minimal text
* Simple navigation
* Visual instructions
* Voice assistance
* Voice-based guidance
* Multiple spoken languages

The initial voice-assistance languages should include:

* English
* Hindi
* Marathi

Additional languages may be added later.

The AI assistant should be capable of communicating with patients through supported spoken languages where technically feasible.

---

## 7. Offline-First Principles

Critical functionality must remain useful during poor or unavailable internet connectivity.

Offline functionality should prioritize:

### Critical emergency information

* Emergency procedures
* Visual instructions
* Voice instructions
* Important emergency contacts
* Cached healthcare facility information where appropriate

### Basic patient functionality

Where technically and securely appropriate:

* Basic patient information
* Previously available essential health information
* Data capture for later synchronization

When connectivity becomes available, locally stored information should synchronize with the server securely.

AI-powered cloud functionality may require connectivity, but critical emergency guidance must not depend entirely on an internet connection.

---

## 8. Human-in-the-Loop Principle

RuralCare is an **AI-assisted healthcare platform**, not an AI diagnostic platform.

The system must preserve human clinical authority.

### AI responsibilities

AI can:

* Understand
* Summarize
* Explain
* Organize
* Translate/communicate
* Guide
* Assist navigation
* Surface potentially important information for professional review

### Healthcare professional responsibilities

Healthcare professionals make decisions regarding:

* Diagnosis
* Treatment
* Medication
* Prescription
* Clinical prioritization
* Referral decisions
* Other medical interventions

The system must never imply that an AI-generated output is equivalent to a doctor's clinical judgment.

---

## 9. Core User Journey

A typical non-emergency journey:

```text
Patient
   ↓
Open Application
   ↓
AI Assistant / Healthcare Services
   ↓
Describe Health Concern
   ↓
General Guidance
   ↓
Find Appropriate Healthcare Service
   ↓
Request Consultation
   ↓
Upload Previous Documents
   ↓
Doctor Reviews Patient Summary
   ↓
Teleconsultation
   ↓
Doctor Makes Clinical Decision
   ↓
Prescription / Diagnostic / Referral
   ↓
Patient Record Updated
   ↓
Follow-up
```

---

## 10. Emergency User Journey

```text
Patient
   ↓
EMERGENCY
   ↓
Select / Describe Emergency
   ↓
Emergency Assistance
   ↓
Identify Appropriate Healthcare Facility
   ↓
Call / Contact / Navigation
   ↓
Immediate Visual + Voice Guidance
   ↓
Reach Healthcare Facility
   ↓
Professional Medical Care
   ↓
Patient Record / Follow-up
```

Critical emergency guidance must remain available offline.

---

## 11. Primary MVP Objective

The MVP should demonstrate that RuralCare can improve the rural healthcare journey by connecting:

**Patient → AI assistance → Appropriate healthcare access → Doctor → Medical information → Referral/diagnostics → Follow-up**

The MVP should prioritize reliability and clarity over the number of features.

A smaller set of well-integrated features is preferable to a large collection of incomplete features.

---

## 12. MVP Priorities

### Highest priority

* Patient profile and health record
* General AI health assistant
* Emergency assistance
* Offline emergency guidance
* Healthcare facility finder
* Teleconsultation workflow
* Doctor dashboard
* AI-generated patient history summary
* Medical document/diagnostic management
* Referral tracking
* Simple low-literacy-focused UI

### Secondary priority

* Appointment and queue management
* Follow-up management
* Voice assistance
* Multilingual AI interaction
* Offline patient data capture and synchronization

### Future scope

Potential future functionality includes:

* Advanced analytics
* Population-level health insights
* Additional regional languages
* Advanced government-system integrations
* Resource allocation analytics
* Broader diagnostic-support capabilities under appropriate clinical governance

These should not distract from the MVP.

---

## 13. Product Success Criteria

The MVP should demonstrate the following:

### Accessibility

A user with limited literacy should be able to navigate the primary patient workflows with minimal reading.

### Emergency usefulness

A user should be able to reach appropriate emergency healthcare and access critical guidance quickly.

### Continuity of care

A doctor should be able to understand a patient's relevant medical history without manually reviewing every historical document.

### Healthcare access

Patients should have a simpler path from symptoms to an appropriate public healthcare service.

### Clinical safety

AI should assist patients and healthcare professionals without independently diagnosing or prescribing.

### Offline resilience

Critical emergency information should remain available without internet connectivity.

### Public healthcare strengthening

The platform should improve coordination between patients, healthcare workers, doctors, diagnostics, referrals, and public healthcare facilities rather than attempting to replace them.

---

## 14. Guiding Product Principle

> **Make healthcare easier to access, easier to understand, and easier to coordinate — especially when the patient has limited connectivity, limited resources, or limited health literacy.**

AI is an enabling layer.

Healthcare professionals remain the clinical authority.

## Design & Implementation Workflow

RuralCare will follow a **design-first development workflow**. The user interface and user experience for each major feature will first be designed in **Stitch** based on the requirements defined in the project documentation. The Stitch designs will be reviewed and approved before implementation begins. Once a design is approved, **Flutter will implement the approved Stitch design as accurately as possible**, including layout, spacing, typography, colors, components, navigation, visual hierarchy, and interaction patterns. Flutter implementation must not independently redesign or significantly reinterpret an approved Stitch screen. After implementation, the Flutter application should be compared against the approved Stitch design and refined to minimize visual and functional differences.

The development workflow is therefore:

```text
Requirements
     ↓
Stitch UI/UX Design
     ↓
Review & Approval
     ↓
Flutter Implementation
     ↓
Visual & Functional Verification
     ↓
Refinement
```

Stitch serves as the **design source of truth**, while the project documentation remains the source of truth for product requirements, functionality, safety constraints, and technical architecture.
