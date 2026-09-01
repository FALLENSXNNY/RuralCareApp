# UI_UX.md

# RuralCare — UI/UX Design Specification

## 1. Purpose

This document defines the user-interface and user-experience principles for RuralCare.

The UI must prioritize:

* Simplicity
* Accessibility
* Low cognitive load
* Low health literacy
* Clear navigation
* Emergency accessibility
* Voice assistance
* Visual communication
* Consistency
* Fast access to healthcare

The application must be understandable even for users who have limited experience with smartphones or healthcare applications.

---

# 2. Core UI Language

The application interface will use:

> **Plain English**

The UI itself should not become a multilingual text-heavy interface.

Examples of UI labels:

```text
Emergency
Health Assistant
Talk to Doctor
Find Hospital
My Health Record
Appointments
Reports
Referrals
Follow-ups
```

Avoid complicated terminology.

Prefer:

```text
My Reports
```

instead of:

```text
Diagnostic Documentation Repository
```

Prefer:

```text
Talk to Doctor
```

instead of:

```text
Initiate Telemedicine Consultation
```

---

# 3. Voice Accessibility

Voice assistance is an accessibility layer on top of the English UI.

Initial supported voice languages:

* English
* Hindi
* Marathi

The architecture should allow additional languages later.

Voice assistance can provide:

* Navigation guidance
* Button explanations
* AI conversations
* Emergency instructions
* Appointment information
* Healthcare facility information
* Basic health explanations

---

# 4. Voice Assistance Entry Point

The application should provide an obvious voice-assistance control.

Example:

```text id="y7k2m4"
┌──────────────────────────────┐
│ 🔊 Voice Assistance          │
└──────────────────────────────┘
```

The user can select their preferred spoken language.

Example:

```text id="q4m8n1"
Choose Voice Language

🇬🇧 English
🇮🇳 Hindi
🇮🇳 Marathi
```

The UI remains English after the selection.

---

# 5. Low-Literacy Design Principle

The application must not assume that users can comfortably read long English text.

Use:

* Large icons
* Large touch targets
* Short labels
* Visual hierarchy
* Simple sentences
* Voice guidance
* Images
* Step-by-step instructions

Where possible:

```text id="c8v3p5"
Icon
+
Short Label
+
Optional Voice
```

should replace long paragraphs.

---

# 6. Primary Patient Home Screen

The patient home screen should prioritize the most important actions.

Conceptually:

```text id="m5r9k2"
┌───────────────────────────┐
│ Good morning              │
│                           │
│ 🔊 Voice Assistance       │
│                           │
│ 🚨 EMERGENCY              │
│                           │
│ 🤖 Health Assistant       │
│                           │
│ 👨‍⚕️ Talk to Doctor        │
│                           │
│ 🏥 Find Healthcare        │
│                           │
│ 📋 My Health Record       │
│                           │
└───────────────────────────┘
```

Emergency should be visually dominant.

---

# 7. Emergency Button

The emergency button must:

* Be immediately visible
* Have a large touch target
* Use a recognizable emergency icon
* Have a clear label
* Be accessible from the home screen
* Require minimal navigation

The user should not need to open a menu to find emergency assistance.

---

# 8. Emergency UX

Emergency mode must be substantially simpler than normal application navigation.

The workflow should prioritize:

```text id="r6q2w8"
Emergency
   ↓
What happened?
   ↓
Get help
   ↓
Follow immediate instructions
```

Avoid unnecessary forms.

---

# 9. Emergency Selection

Use large visual cards.

Example:

```text id="v4m8p2"
🚑
Breathing Problem

🩸
Severe Bleeding

🐍
Snake Bite

❤️
Chest Pain

😵
Unconscious

⚠️
Other Emergency
```

The user should be able to recognize an option visually.

---

# 10. Emergency Guidance

Emergency guidance should be presented one step at a time.

Example:

```text id="k8q3m6"
┌─────────────────────────┐
│ 🐍 Snake Bite           │
│                         │
│       [IMAGE]           │
│                         │
│ Keep the person still.  │
│                         │
│ 🔊 Listen               │
│                         │
│        NEXT →           │
└─────────────────────────┘
```

Avoid presenting ten instructions on one screen.

---

# 11. Emergency Visual Content

Emergency guidance may use:

* Illustrations
* Images
* Short videos
* Icons
* Audio

Visual content should communicate the action even when the user cannot read the text.

Critical content must be clinically reviewed.

---

# 12. Emergency "Do Not" Instructions

Important harmful actions to avoid should receive strong visual emphasis.

Example:

```text id="p5n7x2"
❌ DO NOT CUT THE WOUND

❌ DO NOT SUCK THE WOUND

❌ DO NOT DELAY MEDICAL HELP
```

Exact instructions must come from clinically verified content.

---

# 13. Emergency Voice

Every emergency instruction should have an optional voice playback control.

Example:

```text id="m2v8q5"
🔊 Listen
```

Voice instructions should be short and direct.

Example:

> "Keep the person still."

rather than:

> "It is recommended that the individual remain in a stationary position."

---

# 14. Emergency Offline Indicator

When emergency information is available offline, the interface should communicate this clearly.

Example:

```text id="n7c3k1"
✓ Emergency information available offline
```

This reassures users that critical information does not depend on internet connectivity.

---

# 15. Healthcare Facility Finder UI

The facility finder should provide both:

### List view

```text id="w4q9m2"
PHC A
4.2 km

General OPD
Diagnostics

[CALL] [DIRECTIONS]
```

### Map view

Where map functionality is available.

The list should remain usable even if maps cannot load.

---

# 16. Emergency Facility Display

Emergency facility information should prioritize:

1. Facility name
2. Suitability/capability
3. Distance
4. Contact
5. Navigation

Example:

```text id="j8m3r6"
🏥 District Hospital

Suitable for:
Emergency care

Distance:
18 km

[📞 CALL]
[🧭 DIRECTIONS]
```

The system must not claim that a facility is suitable unless its capability information is verified.

---

# 17. AI Assistant UI

The AI assistant should feel like a simple conversation rather than a technical chatbot.

Example:

```text id="q2v7m5"
AI Assistant

"Tell me what is troubling you."

🎙 Speak
⌨ Type

---------------------

Patient:
"I have had fever for two days."

AI:
"How high has your temperature been,
if you have measured it?"
```

---

# 18. AI Voice Interaction

The patient should be able to:

1. Press the microphone
2. Speak naturally
3. See/transmit the recognized text where appropriate
4. Hear the AI response

Conceptually:

```text id="x5n8q3"
🎙 Speak
   ↓
Speech-to-Text
   ↓
AI
   ↓
Response
   ↓
Text + Voice
```

---

# 19. AI Language Selection

The patient should be able to select the spoken interaction language.

Example:

```text id="f7m2k9"
Voice Language

English
Hindi
Marathi
```

Language selection should be easy to change.

---

# 20. AI Safety UI

AI-generated health information should not visually appear as an official doctor's diagnosis.

Where appropriate, display:

```text id="r3q8v1"
ℹ AI-assisted information

This information is for general guidance
and does not replace a healthcare professional.
```

The warning should be clear without overwhelming the user.

---

# 21. Doctor Dashboard

The doctor interface can be more information-dense than the patient interface.

Doctors are expected to handle structured healthcare information.

Example:

```text id="p8k4m2"
Doctor Dashboard

Today's Queue
────────────────────
🔴 Urgent       3
🟡 Priority     7
🟢 Routine     15

Upcoming Consultations
────────────────────
Patient A   10:30
Patient B   11:00
Patient C   11:30
```

---

# 22. Doctor Patient View

The doctor should receive a consolidated patient view.

Priority order:

```text id="v6m3q8"
Patient
 ↓
Current Complaint
 ↓
AI Health Summary
 ↓
Recent Diagnostics
 ↓
Previous Consultations
 ↓
Prescription History
 ↓
Referrals
 ↓
Follow-ups
 ↓
Original Documents
```

The doctor should not have to search through multiple unrelated screens to understand the patient.

---

# 23. AI Patient Summary UI

The AI summary should be visually distinct from original clinical records.

Example:

```text id="k4n9r2"
AI-GENERATED SUMMARY

Patient Overview
...

Recent Diagnostics
...

Relevant History
...

Previous Prescriptions
...

Pending Follow-ups
...

[VIEW SOURCE RECORDS]
```

The doctor should always have a way to access the original source information.

---

# 24. Source Document Access

For important AI summary information, the UI should allow the doctor to open the source document.

Example:

```text id="w8p3m6"
Hemoglobin appears low.

Source:
[View Lab Report]
```

This improves trust and allows verification.

---

# 25. Patient Health Record UI

The patient record should be timeline-oriented.

Example:

```text id="q6m2v8"
MY HEALTH RECORD

25 Aug
👨‍⚕️ Consultation

26 Aug
🧪 Blood Report

27 Aug
📄 Prescription

28 Aug
🏥 Referral
```

Each event can be opened for more detail.

---

# 26. Patient Document Upload

The upload flow should be simple.

Example:

```text id="r5k8n3"
Add Medical Document

📷 Take Photo

🖼 Choose Image

📄 Choose File
```

After upload:

```text id="m7q2c9"
Document Type

Prescription
Lab Report
X-Ray
ECG
Discharge Summary
Other
```

Avoid complicated metadata forms for patients.

---

# 27. Consultation Preparation

Before a teleconsultation, the patient should see a simple preparation screen.

Example:

```text id="x3v8k5"
Your Consultation

Doctor:
Dr. ______

Time:
10:30 AM

Before you start:

✓ Check your internet connection
✓ Keep your reports nearby
✓ Keep your previous prescriptions nearby

[JOIN CONSULTATION]
```

---

# 28. Doctor Consultation Workspace

The doctor should be able to access:

```text id="p7m4q2"
Current Complaint
Patient Summary
Reports
Prescriptions
Consultation Notes
Diagnosis
Prescription
Referral
Follow-up
```

Clinical actions should be clearly separated from AI assistance.

---

# 29. Referral UI

Patients should see a simple status tracker.

Example:

```text id="n8q3v6"
Your Referral

✓ Referral Created
✓ Hospital Assigned
● Appointment Scheduled
○ Specialist Visit
○ Follow-up
```

The patient should not need to understand internal administrative terminology.

---

# 30. Healthcare Worker UI

Healthcare workers need a balance between simplicity and operational functionality.

Primary actions:

```text id="f4m9k2"
👥 Patients

➕ Register Patient

📋 Queue

🏥 Referrals

📅 Appointments
```

Frequently performed actions should be easily accessible.

---

# 31. Registration UI for Healthcare Workers

Patient registration should use short steps.

Avoid one enormous form.

Use:

```text id="v2k7m5"
Step 1
Basic Information

        ↓

Step 2
Contact

        ↓

Step 3
Basic Health Information

        ↓

Done
```

---

# 32. Form Design

Forms should:

* Use large input fields
* Have clear labels
* Avoid unnecessary fields
* Use dropdowns where appropriate
* Use icons where useful
* Provide understandable validation errors
* Avoid technical terminology

---

# 33. Buttons

Primary buttons should:

* Be large
* Have clear action-oriented labels
* Have sufficient spacing
* Remain consistent throughout the application

Prefer:

```text
Find Hospital
```

over:

```text
Search
```

when the purpose is specifically finding a healthcare facility.

Prefer:

```text
Talk to Doctor
```

over:

```text
Create Consultation
```

for patients.

---

# 34. Navigation

Navigation should be predictable.

The same action should not appear in different locations on different screens without a strong reason.

Patient navigation should remain minimal.

Doctor and healthcare-worker navigation may contain more sections because their workflows are more complex.

---

# 35. Icons

Icons should be:

* Recognizable
* Consistent
* Large enough to identify
* Accompanied by short text when ambiguity is possible

Do not rely on icons alone for actions that could be misunderstood.

---

# 36. Color Usage

Color should communicate meaning consistently.

Possible semantic conventions:

```text
Red    → Emergency / urgent attention
Yellow → Attention / priority
Green  → Completed / available / normal state
Gray   → Secondary/inactive
```

Color should never be the only indicator.

Use:

**Color + Icon + Text**

for important statuses.

This is important for accessibility.

---

# 37. Typography

Patient-facing text should use:

* Large readable font sizes
* High contrast
* Clear font family
* Adequate line spacing
* Short paragraphs

Avoid:

* Tiny text
* Dense paragraphs
* Decorative fonts
* Excessive capitalization

---

# 38. Touch Targets

Interactive controls should have sufficiently large touch areas.

Important actions such as:

* Emergency
* Call
* Navigation
* Voice
* Next
* Confirm

must be easy to tap accurately.

---

# 39. Loading States

The application should clearly communicate when an operation is in progress.

Example:

```text id="z5q8m2"
Finding suitable healthcare facilities...

Please wait.
```

Avoid unexplained infinite spinners.

---

# 40. Error States

Errors should use plain language.

Instead of:

> NetworkException: SocketException...

show:

> **You're offline.**

or:

> **We couldn't load this information. Please try again.**

Provide a clear next action whenever possible.

---

# 41. Offline State

The application should clearly distinguish between:

### Online

```text
✓ Online
```

### Offline

```text
⚠ Offline

Emergency information is still available.
```

The application should not make users think the entire application has stopped working.

---

# 42. Offline Sync UI

When offline-created information is waiting for synchronization:

```text id="h6m3q8"
Saved on this device

⟳ Waiting for internet connection
```

After synchronization:

```text id="c8v2n5"
✓ Synced
```

The system should not silently discard offline information.

---

# 43. Accessibility Mode

The application may provide an accessibility setting that increases:

* Text size
* Button size
* Voice guidance
* Visual emphasis

The default interface should already be accessible; accessibility mode should enhance it rather than fix a poor baseline design.

---

# 44. Patient Experience Principle

The patient should not need to understand:

* Healthcare administration
* Medical terminology
* Backend systems
* AI technology
* Referral infrastructure

The application should translate complexity into simple actions.

---

# 45. Healthcare Worker Experience Principle

The healthcare worker interface should optimize for:

* Speed
* Patient throughput
* Accurate information capture
* Easy referral creation
* Easy consultation preparation
* Minimal repetitive data entry

---

# 46. Doctor Experience Principle

The doctor interface should optimize for:

* Fast patient understanding
* Relevant history
* Source-document access
* Consultation efficiency
* Clinical record creation
* Referral/follow-up management

AI summaries should reduce information overload rather than create another long document to read.

---

# 47. Emergency Experience Principle

Emergency UX follows a different rule:

> **Every unnecessary interaction can create delay.**

Therefore emergency mode should:

* Be immediately accessible
* Minimize text
* Minimize decisions
* Use visual instructions
* Use voice
* Prioritize calling/getting help
* Work offline for critical guidance
* Avoid unnecessary AI interaction

---

# 48. Consistency Rules

The following must remain consistent throughout the application:

* Button styles
* Icon meanings
* Status colors
* Typography
* Spacing
* Navigation patterns
* Voice controls
* Error handling
* Loading behavior

The design system should be implemented through reusable Flutter components.

---

# 49. Stitch Design Integration

Stitch-generated designs should be treated as the visual design reference.

When implementing Stitch designs:

* Preserve the intended layout
* Preserve hierarchy
* Preserve spacing
* Preserve component relationships
* Preserve interaction intent

However, implementation must still respect:

* Accessibility
* Flutter best practices
* Responsive layouts
* Offline states
* Loading states
* Error states
* Role-based behavior

A visually accurate design is not sufficient if the resulting workflow is difficult to use.

---

# 50. MVP UX Goal

The final patient experience should make a first-time user able to understand the primary options immediately:

```text id="m4q8v2"
🚨 I NEED EMERGENCY HELP

🤖 I HAVE A HEALTH QUESTION

👨‍⚕️ I WANT TO TALK TO A DOCTOR

🏥 I NEED TO FIND HEALTHCARE

📋 I WANT TO SEE MY RECORDS
```

The application should feel like a **simple healthcare assistant**, not a complicated hospital management system.

---

# 51. Core UI/UX Principle

> **If the user has to understand the system before they can use it, the interface has failed.**

RuralCare should make the healthcare process understandable through:

**Simple English + Icons + Visual Guidance + Voice + Clear Actions**

while maintaining more detailed, information-rich interfaces for healthcare professionals.
