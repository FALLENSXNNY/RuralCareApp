# DATABASE.md

# RuralCare — Database Design

## 1. Purpose

This document defines the data model for the RuralCare MVP.

The database must support:

* User authentication and roles
* Patient profiles
* Longitudinal health records
* Consultations
* Prescriptions
* Diagnostic reports
* Medical documents
* Referrals
* Appointments
* Queue management
* Follow-ups
* Healthcare facilities
* Emergency events
* AI conversations
* AI-generated summaries
* Audit logs
* Offline synchronization metadata

MongoDB is the primary persistent database.

---

# 2. Database Principles

## 2.1 Patient-Centered Data Model

The patient is the central entity.

Most healthcare information should be associated with a patient.

```text
Patient
 ├── Consultations
 ├── Prescriptions
 ├── Diagnostics
 ├── Documents
 ├── Referrals
 ├── Appointments
 ├── Follow-ups
 └── Emergency Events
```

---

## 2.2 Original Data Must Be Preserved

AI-generated information must never replace the original clinical information.

For example:

```text
Original Diagnostic Report
        +
AI Summary
```

not:

```text
Diagnostic Report
        ↓
AI Summary replaces report
```

The original document remains the authoritative source.

---

## 2.3 Clinical Records Should Be Traceable

Clinical information should be associated with:

* Patient
* Author/creator
* Date/time
* Relevant consultation or event
* Source document where applicable

---

## 2.4 Sensitive Data

Healthcare information is sensitive.

Database access must always be performed through authorized backend services.

The frontend must never connect directly to MongoDB.

---

# 3. Core Collections

The MVP should use the following primary collections:

```text id="x1q7n4"
users
patients
healthcare_workers
doctors
facilities
consultations
prescriptions
diagnostics
documents
referrals
appointments
followups
emergency_events
ai_conversations
ai_summaries
audit_logs
sync_operations
```

Additional collections may be introduced only when there is a clear requirement.

---

# 4. Users Collection

## Collection

`users`

## Purpose

Stores authentication and role information.

## Example structure

```text id="6h3p9a"
{
  _id,
  email,
  phone,
  passwordHash,
  role,
  isActive,
  createdAt,
  updatedAt,
  lastLoginAt
}
```

## Role values

```text id="p3q8x2"
PATIENT
HEALTHCARE_WORKER
DOCTOR
ADMIN
```

The role must be controlled by the backend.

A client must never be allowed to arbitrarily change its own role.

---

# 5. Patient Collection

## Collection

`patients`

## Purpose

Stores patient-specific profile information.

## Example structure

```text id="r5k1m8"
{
  _id,
  userId,
  fullName,
  dateOfBirth,
  gender,
  phone,
  address,
  location,
  preferredVoiceLanguage,
  emergencyContact,
  basicMedicalInformation,
  createdAt,
  updatedAt
}
```

## Important

The patient profile should not contain every historical medical event.

Healthcare events should be stored in their respective collections.

---

# 6. Location Structure

Patient/facility locations should use a consistent structure.

Conceptually:

```text id="k8f2v4"
{
  latitude,
  longitude,
  address
}
```

If geospatial queries are required, MongoDB geospatial indexing should be used.

Location collection/storage decisions should minimize unnecessary exposure of precise patient location.

---

# 7. Doctor Collection

## Collection

`doctors`

## Purpose

Stores doctor-specific professional information.

## Example structure

```text id="d4q7w1"
{
  _id,
  userId,
  fullName,
  specialization,
  qualifications,
  facilityIds,
  availability,
  licenseInformation,
  isActive,
  createdAt,
  updatedAt
}
```

Sensitive professional credentials should not be unnecessarily exposed to patients.

---

# 8. Healthcare Worker Collection

## Collection

`healthcare_workers`

## Purpose

Stores healthcare-worker information.

## Example

```text id="v9m2c6"
{
  _id,
  userId,
  fullName,
  roleType,
  facilityId,
  assignedArea,
  isActive,
  createdAt,
  updatedAt
}
```

`roleType` can distinguish different frontline worker categories if required.

---

# 9. Facility Collection

## Collection

`facilities`

## Purpose

Stores healthcare facility information.

## Example

```text id="q3z7h5"
{
  _id,
  name,
  facilityType,
  location,
  address,
  phone,
  services,
  emergencyCapabilities,
  operatingHours,
  isActive,
  lastVerifiedAt,
  createdAt,
  updatedAt
}
```

## Facility types

Possible values:

```text id="a7n4k9"
SUB_CENTER
PHC
RURAL_HOSPITAL
DISTRICT_HOSPITAL
OTHER
```

## Important

Emergency capabilities should only be recorded when verified.

The application must not assume that every hospital can treat every emergency.

---

# 10. Consultation Collection

## Collection

`consultations`

## Purpose

Represents a healthcare consultation.

This may be:

* Teleconsultation
* In-person consultation
* Healthcare-worker-assisted consultation

## Example

```text id="m6p2r8"
{
  _id,
  patientId,
  doctorId,
  healthcareWorkerId,
  facilityId,
  type,
  status,
  reason,
  symptoms,
  doctorNotes,
  diagnosis,
  consultationDate,
  createdAt,
  updatedAt
}
```

## Consultation types

```text id="t4w8q1"
TELECONSULTATION
IN_PERSON
ASSISTED
```

## Status values

Possible values:

```text id="n5x2j7"
REQUESTED
SCHEDULED
WAITING
IN_PROGRESS
COMPLETED
CANCELLED
NO_SHOW
```

---

# 11. Clinical Information

Doctor-entered clinical information must be distinguished from AI-generated information.

For example:

```text id="y8c3v1"
doctorNotes
diagnosis
prescription
```

are clinical records created by authorized healthcare professionals.

AI-generated information should be stored separately.

---

# 12. Prescription Collection

## Collection

`prescriptions`

## Purpose

Stores doctor-created prescriptions.

## Example

```text id="b7m4q2"
{
  _id,
  patientId,
  doctorId,
  consultationId,
  medications,
  instructions,
  issuedAt,
  createdAt,
  updatedAt
}
```

## Medication structure

Conceptually:

```text id="e9r3w6"
{
  name,
  dosage,
  frequency,
  duration,
  instructions
}
```

The exact structure should support the doctor's prescription workflow.

---

# 13. Prescription Authority

Only authorized doctors may create or modify prescriptions through the clinical workflow.

The AI assistant must never write directly to the `prescriptions` collection.

Patients can view prescriptions but cannot modify their contents.

---

# 14. Diagnostic Collection

## Collection

`diagnostics`

## Purpose

Represents diagnostic tests and their results.

## Example

```text id="s2k7p5"
{
  _id,
  patientId,
  consultationId,
  requestedBy,
  facilityId,
  testType,
  status,
  requestedAt,
  completedAt,
  resultSummary,
  reportDocumentId,
  createdAt,
  updatedAt
}
```

## Status

Possible values:

```text id="f8v2n5"
REQUESTED
SCHEDULED
IN_PROGRESS
COMPLETED
CANCELLED
```

---

# 15. Document Collection

## Collection

`documents`

## Purpose

Stores metadata for uploaded medical documents.

The actual file should be stored in secure file/object storage rather than directly inside the MongoDB document where practical.

## Example

```text id="u4q8m2"
{
  _id,
  patientId,
  uploadedBy,
  documentType,
  consultationId,
  diagnosticId,
  storageKey,
  originalFileName,
  mimeType,
  fileSize,
  uploadedAt,
  createdAt,
  updatedAt
}
```

---

# 16. Document Types

Possible values:

```text id="j5r1w8"
PRESCRIPTION
LAB_REPORT
XRAY
ECG
DISCHARGE_SUMMARY
MEDICAL_REPORT
OTHER
```

Additional document types may be added later.

---

# 17. Document Access

Medical documents must not be publicly accessible.

Access should follow:

```text id="g6p3t9"
Authenticated User
       ↓
Backend Authorization
       ↓
Verify patient/resource access
       ↓
Generate authorized access
       ↓
Document Storage
```

Documents should not be exposed through predictable public URLs.

---

# 18. Referral Collection

## Collection

`referrals`

## Purpose

Tracks movement of patients between healthcare facilities/providers.

## Example

```text id="c8v4n2"
{
  _id,
  patientId,
  createdBy,
  referringFacilityId,
  destinationFacilityId,
  consultationId,
  reason,
  priority,
  status,
  supportingDocumentIds,
  appointmentId,
  createdAt,
  updatedAt,
  completedAt
}
```

---

# 19. Referral Status

Possible statuses:

```text id="p7x3m1"
CREATED
ACCEPTED
APPOINTMENT_SCHEDULED
IN_PROGRESS
COMPLETED
MISSED
CANCELLED
REJECTED
```

The exact state transitions should be controlled by backend business logic.

---

# 20. Appointment Collection

## Collection

`appointments`

## Purpose

Stores scheduled healthcare interactions.

## Example

```text id="w5q2h8"
{
  _id,
  patientId,
  doctorId,
  facilityId,
  consultationId,
  type,
  scheduledAt,
  status,
  queueToken,
  createdAt,
  updatedAt
}
```

---

# 21. Appointment Types

Possible values:

```text id="r9k4z6"
TELECONSULTATION
IN_PERSON
FOLLOW_UP
DIAGNOSTIC
```

---

# 22. Queue Management

Queue information may be stored using appointments and/or Redis depending on implementation.

Persistent appointment information belongs in MongoDB.

Real-time queue state may use Redis.

Example:

```text id="n3v8p2"
MongoDB
   ↓
Appointment
   ↓
Redis
   ↓
Current Queue
```

Redis must not become the permanent source of appointment history.

---

# 23. Follow-Up Collection

## Collection

`followups`

## Purpose

Stores doctor-created follow-up plans.

## Example

```text id="m2f7q4"
{
  _id,
  patientId,
  doctorId,
  consultationId,
  scheduledDate,
  reason,
  instructions,
  requiredDiagnosticIds,
  referralId,
  status,
  completedAt,
  createdAt,
  updatedAt
}
```

---

# 24. Emergency Event Collection

## Collection

`emergency_events`

## Purpose

Records emergency assistance sessions.

## Example

```text id="x7n4c2"
{
  _id,
  patientId,
  emergencyType,
  location,
  selectedFacilityId,
  contactAction,
  status,
  startedAt,
  endedAt,
  createdAt,
  updatedAt
}
```

The emergency event is primarily for tracking and continuity.

Critical emergency instructions themselves should not depend on this database collection.

---

# 25. Emergency Types

Initial MVP values:

```text id="q4m8j2"
SNAKE_BITE
SEVERE_BLEEDING
BREATHING_DIFFICULTY
UNCONSCIOUSNESS
CHEST_PAIN
SEVERE_ALLERGIC_REACTION
OTHER
```

Additional emergency scenarios may be added later.

---

# 26. Emergency Content

Emergency instructions should be treated as controlled application content rather than ordinary AI-generated database content.

Conceptually:

```text id="k2p7v5"
Emergency Type
 ├── Text Instructions
 ├── Images
 ├── Audio
 ├── Optional Video
 └── Version
```

Critical content should be available locally in the Flutter application.

---

# 27. AI Conversation Collection

## Collection

`ai_conversations`

## Purpose

Stores AI assistant conversation metadata and, where appropriate, conversation messages.

## Example

```text id="h8r3w6"
{
  _id,
  patientId,
  conversationType,
  language,
  messages,
  startedAt,
  lastMessageAt,
  createdAt,
  updatedAt
}
```

The system should avoid retaining unnecessary sensitive conversation information.

Retention policies should be considered for production deployment.

---

# 28. AI Conversation Types

Possible values:

```text id="f4m9q1"
GENERAL_ASSISTANT
DOCUMENT_EXPLANATION
HEALTH_RECORD_ASSISTANCE
EMERGENCY_ASSISTANCE
```

Emergency critical instructions should still come from controlled content rather than depending on the AI conversation.

---

# 29. AI Summary Collection

## Collection

`ai_summaries`

## Purpose

Stores AI-generated summaries that may be useful to doctors.

## Example

```text id="v6q2n8"
{
  _id,
  patientId,
  generatedFor,
  sourceRecordIds,
  summaryType,
  content,
  modelMetadata,
  generatedAt,
  version,
  createdAt
}
```

---

# 30. AI Summary Types

Possible values:

```text id="p3k8w5"
PATIENT_HISTORY
DIAGNOSTIC_REPORT
CONSULTATION_HISTORY
```

---

# 31. AI Summary Source Tracking

Every AI-generated clinical summary should maintain references to the source information used to generate it.

Example:

```text id="u7m2r9"
AI Summary
   ↓
Source Consultation IDs
Source Diagnostic IDs
Source Document IDs
```

This allows the doctor to trace the summary back to the underlying information.

---

# 32. AI Summary Versioning

If patient information changes, a previously generated summary should not silently be treated as current.

The system should store:

* Generation timestamp
* Source records
* Version
* Relevant model metadata where practical

A new summary can be generated when required.

---

# 33. Audit Log Collection

## Collection

`audit_logs`

## Purpose

Records important security and clinical actions.

## Example

```text id="c5x9r3"
{
  _id,
  actorUserId,
  actorRole,
  action,
  resourceType,
  resourceId,
  timestamp,
  metadata
}
```

---

# 34. Audit Actions

Examples:

```text id="m8v4q1"
PATIENT_RECORD_VIEWED
DOCUMENT_UPLOADED
PRESCRIPTION_CREATED
PRESCRIPTION_UPDATED
DIAGNOSIS_CREATED
REFERRAL_CREATED
REFERRAL_UPDATED
PATIENT_UPDATED
AI_SUMMARY_GENERATED
```

Audit logging should avoid unnecessarily storing sensitive content.

---

# 35. Synchronization Collection

## Collection

`sync_operations`

## Purpose

Tracks selected offline-created operations that need synchronization.

## Example

```text id="r4n7k2"
{
  _id,
  userId,
  deviceId,
  operationType,
  entityType,
  localEntityId,
  serverEntityId,
  payloadReference,
  status,
  retryCount,
  createdAt,
  syncedAt,
  updatedAt
}
```

The exact implementation may use a local queue on the Flutter side and server-side synchronization metadata.

---

# 36. Data Relationships

Conceptually:

```text id="t8q3m5"
User
 │
 ├── Patient
 │      │
 │      ├── Consultations
 │      │       ├── Prescriptions
 │      │       └── Diagnostics
 │      │
 │      ├── Documents
 │      ├── Referrals
 │      ├── Appointments
 │      ├── Follow-ups
 │      ├── Emergency Events
 │      └── AI Conversations
 │
 ├── Doctor
 │      └── Consultations
 │
 └── Healthcare Worker
        └── Patient Assistance
```

---

# 37. Consultation Relationships

A consultation may connect multiple entities:

```text id="y5c8n2"
Patient
   │
   └── Consultation
          ├── Doctor
          ├── Facility
          ├── Documents
          ├── Diagnostics
          ├── Prescription
          ├── Referral
          └── Follow-up
```

Not every consultation requires every related entity.

---

# 38. Referral Relationships

```text id="q2m7v4"
Patient
   ↓
Referring Doctor / Facility
   ↓
Referral
   ↓
Destination Facility
   ↓
Appointment
   ↓
Consultation
```

---

# 39. Diagnostic Relationships

```text id="w8f3k1"
Patient
   ↓
Diagnostic Request
   ↓
Diagnostic
   ↓
Report Document
   ↓
Doctor Review
```

---

# 40. Patient Timeline

The application should construct a patient timeline from healthcare events.

The timeline may combine:

* Consultations
* Diagnostics
* Prescriptions
* Referrals
* Follow-ups
* Emergency events
* Uploaded documents

The timeline does not necessarily require a separate `timeline` collection.

It can be generated from existing records.

This avoids unnecessary data duplication.

---

# 41. Denormalization

MongoDB denormalization may be used selectively for performance.

However, duplicated clinical information must not create conflicting sources of truth.

For example, if a doctor's name is cached inside a consultation document, the authoritative doctor profile remains the doctor collection.

---

# 42. Indexing

Indexes should be added for common queries.

Potential indexes include:

### Users

```text id="e6p3v8"
email
phone
role
```

### Patients

```text id="k4r9w2"
userId
phone
```

### Consultations

```text id="n7x2m5"
patientId
doctorId
consultationDate
status
```

### Diagnostics

```text id="q8v3f1"
patientId
consultationId
status
```

### Documents

```text id="r5m2c7"
patientId
consultationId
diagnosticId
uploadedAt
```

### Referrals

```text id="t3k8n4"
patientId
destinationFacilityId
status
```

### Appointments

```text id="y6q2p9"
patientId
doctorId
scheduledAt
status
```

---

# 43. Facility Geospatial Index

Healthcare facilities should support geospatial search.

Where MongoDB geospatial functionality is used, facility location should use an appropriate GeoJSON representation.

Conceptually:

```text id="u8r4m1"
location:
{
  type: "Point",
  coordinates: [longitude, latitude]
}
```

A geospatial index should support nearby-facility searches.

---

# 44. Patient Data Access

Patient access should always be based on the authenticated patient identity.

Example:

```text id="g7n3q5"
GET /patients/me
```

The backend derives the patient identity from authentication rather than trusting a patient ID supplied by the client.

---

# 45. Doctor Data Access

Doctors must only access patients they are authorized to access.

Possible authorization relationships include:

* Current consultation
* Assigned appointment
* Assigned facility/workflow
* Explicit clinical access

The exact authorization rules may depend on deployment requirements.

---

# 46. Healthcare Worker Data Access

Healthcare workers should only access patient information required for their authorized workflow.

The system should avoid giving all healthcare workers unrestricted access to every patient.

---

# 47. Administrator Data Access

Administrator access must follow least privilege.

Being an administrator does not automatically mean unrestricted access to all clinical information.

---

# 48. Data Integrity

The backend must enforce:

* Valid patient references
* Valid doctor references
* Valid facility references
* Valid consultation references
* Valid referral state transitions
* Valid appointment state transitions
* Valid role permissions

The frontend must not be responsible for maintaining database integrity.

---

# 49. Deletion Strategy

Clinical records should not be casually deleted.

Where appropriate, the system should prefer:

* Soft deletion
* Archiving
* Status changes
* Audit trails

Permanent deletion should require explicit authorization and appropriate policy.

---

# 50. Timestamps

All important records should contain timestamps such as:

```text id="v2m8q6"
createdAt
updatedAt
```

Healthcare events should additionally record clinically meaningful timestamps such as:

* consultationDate
* issuedAt
* completedAt
* scheduledAt
* generatedAt

The backend should generate authoritative timestamps.

---

# 51. Data Consistency

Medical records are more important than aggressive caching.

MongoDB should remain the source of truth for persistent healthcare information.

Redis and local device storage should be treated as supporting layers.

```text id="c7x4n2"
MongoDB
   ↓
Source of Truth

Redis
   ↓
Cache / temporary state

Flutter Local Storage
   ↓
Offline / temporary synchronized state
```

---

# 52. AI Data Isolation

AI services must not have unrestricted database credentials.

Correct:

```text id="m4q8w1"
MongoDB
   ↓
Backend
   ↓
Authorized Data Selection
   ↓
AI Service
```

Incorrect:

```text id="n9r2k5"
AI
   ↓
Direct unrestricted MongoDB access
```

---

# 53. Minimum Data Principle

Only collect and store information required for:

* Healthcare access
* Clinical continuity
* Emergency assistance
* Patient communication
* Referral coordination
* System operation

Do not add personal data merely because it might be useful later.

---

# 54. Database Source-of-Truth Rules

The following should be treated as authoritative:

| Data                      | Source of Truth      |
| ------------------------- | -------------------- |
| User identity             | `users`              |
| Patient profile           | `patients`           |
| Doctor profile            | `doctors`            |
| Healthcare worker         | `healthcare_workers` |
| Facility                  | `facilities`         |
| Consultation              | `consultations`      |
| Prescription              | `prescriptions`      |
| Diagnostic                | `diagnostics`        |
| Medical document metadata | `documents`          |
| Referral                  | `referrals`          |
| Appointment               | `appointments`       |
| Follow-up                 | `followups`          |
| Emergency event           | `emergency_events`   |
| AI conversation           | `ai_conversations`   |
| AI summary                | `ai_summaries`       |
| Audit information         | `audit_logs`         |

---

# 55. Database Design Goal

The database should make it possible to answer:

> **What happened to this patient throughout their healthcare journey?**

The system should be able to reconstruct:

```text id="j5w9p3"
Patient
   ↓
Symptoms
   ↓
Consultation
   ↓
Diagnostics
   ↓
Prescription
   ↓
Referral
   ↓
Specialist
   ↓
Follow-up
```

while preserving the original documents and clinical decisions.

The database should support the core RuralCare goal:

> **Continuity of healthcare information across patients, healthcare workers, doctors, diagnostics, referrals, and follow-ups.**
