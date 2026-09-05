# USER_ROLES.md

# RuralCare — User Roles & Permissions

## 1. Purpose

This document defines the user roles, responsibilities, permissions, and access boundaries within RuralCare.

The system must enforce role-based access control (RBAC).

A user's role determines:

* Which screens they can access
* Which actions they can perform
* Which patient information they can view
* Which information they can create or modify
* Which administrative operations they can perform

The frontend should hide actions that the user is not authorized to perform, but **backend authorization must always be the final security boundary**.

---

# 2. Roles

RuralCare MVP contains four primary roles:

1. Patient
2. Healthcare Worker
3. Doctor
4. Administrator

---

# 3. Role Overview

| Role              | Primary Purpose                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------- |
| Patient           | Access healthcare, manage personal records, use AI assistance, request consultations and emergency help |
| Healthcare Worker | Assist patients, collect basic information, manage PHC workflows, coordinate referrals                  |
| Doctor            | Provide clinical care, conduct consultations, review records, make clinical decisions                   |
| Administrator     | Manage facilities, users, services and system configuration                                             |

---

# 4. PATIENT

## 4.1 Purpose

The patient is the primary beneficiary of the platform.

The patient should be able to access healthcare services without needing to understand the underlying healthcare infrastructure.

---

## 4.2 Patient Navigation

Primary navigation should prioritize:

```text
Home
AI Assistant
Emergency
Healthcare
Health Record
Appointments
Profile
```

The exact navigation structure may be refined during UI development.

---

# 5. Patient Permissions

## 5.1 Profile

Patient CAN:

* View their profile
* Create their profile
* Update permitted personal information
* Select preferred voice language
* Add/update emergency contact

Patient CANNOT:

* Modify doctor-entered clinical records
* Modify prescriptions
* Modify diagnostic results
* Modify referral outcomes

---

## 5.2 AI Health Assistant

Patient CAN:

* Start an AI conversation
* Ask health-related questions
* Describe symptoms
* Use supported voice interaction
* Receive general health information
* Ask the AI to explain medical terminology
* Ask the AI to explain their own uploaded documents
* Ask the AI to help prepare for a consultation
* Ask the AI about healthcare services

The AI conversation belongs to the authenticated patient.

Patient CANNOT use the AI assistant to bypass clinical authorization.

---

# 6. Patient Emergency Access

Patient CAN:

* Open Emergency Mode
* Select a predefined emergency
* Provide required information
* Share location when permitted
* View suitable healthcare facilities
* Call available emergency contacts
* Call a healthcare facility
* Open navigation
* View emergency instructions
* Listen to emergency instructions
* Access offline emergency instructions

Emergency functionality must remain accessible without navigating through normal patient workflows.

---

# 7. Patient Healthcare Finder

Patient CAN:

* Search healthcare facilities
* View nearby facilities
* Filter facilities by available services
* View facility information
* View contact information
* View location
* Open navigation

Patient should be able to understand the purpose of a facility without requiring medical knowledge.

---

# 8. Patient Teleconsultation

Patient CAN:

* Request a consultation
* Select available healthcare services/doctors where applicable
* Join an appointment
* View appointment information
* Join the teleconsultation
* Cancel/request changes where supported
* View consultation history

Patient CANNOT:

* Modify doctor consultation notes
* Modify diagnosis
* Modify prescriptions
* Modify referral status

---

# 9. Patient Document Management

Patient CAN:

* Upload medical documents
* View their uploaded documents
* Delete documents where permitted
* Associate documents with relevant healthcare events where supported

Possible documents:

* Prescriptions
* Blood reports
* Diagnostic reports
* X-rays
* ECG reports
* Discharge summaries
* Other relevant healthcare documents

The patient should not be able to modify the contents of an uploaded document after submission.

---

# 10. Patient Health Record

Patient CAN view:

* Their consultations
* Their prescriptions
* Their diagnostic reports
* Their uploaded documents
* Their referrals
* Their follow-ups
* Their health timeline
* Relevant doctor-entered information

Patient CANNOT modify clinical information entered by authorized healthcare professionals.

---

# 11. Patient Prescription Access

Patient CAN:

* View prescriptions
* Download/view prescription documents where supported
* Ask the AI to explain the prescription in simple language

The AI must not:

* Modify the prescription
* Recommend dosage changes
* Recommend starting/stopping medication
* Generate a new prescription

---

# 12. Patient Referral Tracking

Patient CAN:

* View referrals
* View referral destination
* View referral reason where appropriate
* View referral status
* View appointment information
* View follow-up information

Patient CANNOT:

* Mark a referral as completed
* Change referral priority
* Change referral destination
* Modify clinical referral information

---

# 13. Patient Follow-Up

Patient CAN:

* View upcoming follow-ups
* View follow-up instructions
* View required tests
* View follow-up dates
* Receive reminders

Patient cannot modify clinical follow-up requirements.

---

# 14. HEALTHCARE WORKER

## 14.1 Purpose

Healthcare workers support patients and help bridge the gap between communities and healthcare facilities.

Examples include:

* ASHA/community healthcare workers
* PHC staff
* Other authorized frontline workers

---

# 15. Healthcare Worker Navigation

Possible primary navigation:

```text
Dashboard
Patients
Queue
Referrals
Appointments
Tasks
Profile
```

---

# 16. Healthcare Worker Permissions

Healthcare workers CAN, subject to authorization:

* Register patients
* Search authorized patients
* View relevant patient information
* Record basic observations
* Record symptoms
* Record vitals
* Assist with AI-assisted patient intake
* Help patients request consultations
* Manage queues
* Create referrals
* View referral status
* Upload diagnostic documents
* Assist patients with document uploads
* View relevant healthcare facility information

---

# 17. Healthcare Worker Clinical Boundaries

Healthcare workers must not receive permissions intended exclusively for doctors unless their account explicitly has the required authorized role.

Healthcare workers must not:

* Create unauthorized diagnoses
* Create prescriptions
* Modify doctor prescriptions
* Modify diagnostic results
* Override doctor decisions
* Present AI output as a clinical diagnosis

The exact scope may depend on the real-world role and deployment environment.

---

# 18. Healthcare Worker Patient Registration

Healthcare workers can register patients who may have difficulty registering themselves.

Workflow:

```text id="7jgj3p"
Healthcare Worker
      ↓
Register Patient
      ↓
Create Patient Profile
      ↓
Patient receives/accesses account
      ↓
Health Record Created
```

Duplicate patient creation should be minimized through appropriate identity matching.

---

# 19. Healthcare Worker Patient Intake

The worker may record:

* Symptoms
* Basic medical history
* Vitals
* Relevant observations
* Current concern
* Basic patient information

The information should become part of the patient's record.

---

# 20. Healthcare Worker Queue Management

Healthcare workers can:

* View queue
* Add patients to queue
* View appointment status
* Mark patient as arrived
* Assist with queue management

Clinical prioritization should remain subject to appropriate healthcare-professional oversight.

AI-generated triage information must not automatically override clinical decisions.

---

# 21. Healthcare Worker Referral Management

Healthcare workers can create referrals where authorized.

They can:

* Select destination facility
* Enter referral reason
* Attach relevant documents
* View referral status
* Follow up on pending referrals

They cannot alter a doctor's clinical decision unless authorized by the system's real-world governance model.

---

# 22. DOCTOR

## 22.1 Purpose

Doctors are the primary clinical decision-makers within RuralCare.

The doctor remains responsible for:

* Clinical assessment
* Diagnosis
* Treatment decisions
* Prescriptions
* Referral decisions
* Follow-up plans

---

# 23. Doctor Navigation

Possible primary navigation:

```text
Dashboard
Patients
Appointments
Consultations
Referrals
Diagnostics
Profile
```

---

# 24. Doctor Permissions

Doctors CAN:

* View authorized patient records
* View patient history
* View AI-generated patient summaries
* View original supporting documents
* Conduct teleconsultations
* Create consultation notes
* Enter diagnoses
* Create prescriptions
* Request diagnostics
* Review diagnostic reports
* Create referrals
* Update referral information where authorized
* Create follow-up plans
* View appointment and queue information

---

# 25. Doctor Patient Record Access

The doctor should see a consolidated patient view containing:

```text id="d9lye1"
Patient Profile
      ↓
Current Complaint
      ↓
AI Health Summary
      ↓
Previous Consultations
      ↓
Diagnostic Reports
      ↓
Prescription History
      ↓
Referrals
      ↓
Follow-ups
      ↓
Original Documents
```

The summary should prioritize relevant information while preserving access to the complete source record.

---

# 26. Doctor AI Summary

Doctors CAN view:

* AI-generated health summaries
* Diagnostic summaries
* Historical information summaries
* Relevant trends identified from stored records

Doctors must be able to access the underlying source information.

AI output must be clearly marked as AI-generated.

The doctor must not be forced to rely on the AI summary.

---

# 27. Doctor Consultation

During a consultation, doctors can:

* View patient information
* Review current symptoms
* Review history
* Review uploaded documents
* Conduct consultation
* Add clinical notes
* Enter diagnosis
* Create prescription
* Request diagnostics
* Create referral
* Create follow-up

---

# 28. Doctor Clinical Authority

Only authorized doctors/clinical professionals may perform clinical actions such as:

* Diagnosis
* Prescription
* Treatment decisions
* Clinical referral decisions

AI cannot independently perform these actions.

---

# 29. Doctor Prescription Permissions

Doctors can:

* Create prescriptions
* View previous prescriptions
* Issue updated prescriptions
* Record prescription instructions

Patients and AI assistants cannot modify doctor-created prescriptions.

---

# 30. Doctor Diagnostic Permissions

Doctors can:

* Request diagnostics
* View diagnostic reports
* Associate reports with consultations
* Review historical diagnostic information

AI may summarize reports but must not convert a summary into an autonomous diagnosis.

---

# 31. Doctor Referral Permissions

Doctors can:

* Create referrals
* Select appropriate destination facilities
* Enter referral reason
* Set appropriate priority where authorized
* Attach supporting documents
* Track referral progress
* Review referral completion

---

# 32. Doctor Follow-Up Permissions

Doctors can:

* Create follow-up plans
* Set follow-up dates
* Specify required tests
* Add instructions
* Create follow-up requirements

Patients can view but cannot clinically modify these instructions.

---

# 33. ADMINISTRATOR

## 33.1 Purpose

Administrators manage the operational configuration of the platform.

Administrators are not automatically clinical users.

---

# 34. Administrator Permissions

Administrators may manage:

### Users

* Create/manage doctor accounts
* Create/manage healthcare-worker accounts
* Manage patient accounts where operationally necessary
* Disable accounts
* Assign roles according to authorization policy

### Facilities

* Create facilities
* Update facility information
* Set facility type
* Configure available services
* Update contact information
* Update location

### Services

* Manage services offered by facilities
* Manage facility capability information

### System configuration

* Manage selected system settings
* Monitor system health
* Review operational metrics

---

# 35. Administrator Clinical Restriction

Administrators should not automatically have unrestricted access to clinical records simply because they have administrative privileges.

Clinical information access should follow the principle of least privilege.

If administrative access to specific medical data is required for operational reasons, it should be explicitly controlled and auditable.

---

# 36. Cross-Role Access Rules

## Patient

Can access:

**Own data only**

---

## Healthcare Worker

Can access:

**Authorized patients and information necessary for their assigned duties**

---

## Doctor

Can access:

**Patients assigned to/associated with their clinical workflow or otherwise explicitly authorized**

---

## Administrator

Can access:

**Operational/system information required for administration**

Clinical data access should be restricted unless explicitly authorized.

---

# 37. Medical Document Access

Medical documents are sensitive.

Access should follow:

```text id="9zllmy"
Patient
   ↓
Own documents

Authorized Healthcare Worker
   ↓
Necessary documents

Authorized Doctor
   ↓
Relevant clinical documents

Administrator
   ↓
Only when explicitly authorized
```

Documents should never be globally accessible through predictable URLs or IDs.

---

# 38. AI Access Permissions

AI should operate using the permissions of the requesting user.

For example:

### Patient AI

Can access:

* Patient's own permitted information

### Doctor AI

Can access:

* Patient information the doctor is authorized to view

### Healthcare Worker AI

Can access:

* Patient information necessary for the worker's authorized workflow

AI must not bypass backend authorization.

---

# 39. Emergency Access

Emergency functionality should be accessible to patients without requiring completion of normal healthcare workflows.

However:

* Emergency mode must not expose another patient's information.
* Location sharing requires appropriate user permission where applicable.
* Emergency guidance must come from controlled, verified content.
* AI must not dynamically invent emergency procedures.

---

# 40. Auditability

Important actions should be recorded where practical.

Examples:

* Doctor viewed patient record
* Doctor created prescription
* Doctor created referral
* Healthcare worker created patient
* Patient uploaded document
* Patient granted/revoked relevant access
* Referral status changed

Audit records should help identify who performed important actions and when.

---

# 41. Role Hierarchy Principle

Roles must not be treated as simple UI labels.

Authorization must be enforced at the backend/API/database-access layer.

For every protected operation:

```text id="rj2j3a"
Request
   ↓
Authenticate user
   ↓
Identify role
   ↓
Check authorization
   ↓
Check resource ownership/access
   ↓
Perform operation
```

The frontend must never be considered a security boundary.

---

# 42. Core Permission Principle

RuralCare follows:

> **Least privilege + clinical authority + patient privacy + human oversight**

Users should have enough access to perform their responsibilities, but no more access than necessary.
