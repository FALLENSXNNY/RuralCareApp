# AI_SAFETY.md

# RuralCare — AI Safety & Clinical Boundaries

## 1. Purpose

This document defines the safety rules, responsibilities, limitations, and operating boundaries for all AI functionality in RuralCare.

RuralCare is an **AI-assisted healthcare access and support platform**.

It is **not an AI doctor** and must not operate as an autonomous diagnostic or treatment system.

The AI exists to:

* Understand
* Explain
* Summarize
* Organize
* Communicate
* Guide
* Assist navigation
* Help patients access appropriate healthcare

Qualified healthcare professionals remain responsible for:

* Diagnosis
* Treatment
* Medication
* Prescriptions
* Clinical decisions
* Referral decisions
* Follow-up decisions

---

# 2. Fundamental Principle

The most important AI rule is:

> **AI may assist healthcare decisions, but AI must not independently make clinical decisions.**

The system should always maintain a distinction between:

```text id="3b7f9q"
AI Assistance
      ≠
Clinical Decision
```

---

# 3. AI Components

RuralCare may contain multiple AI-assisted components.

## 3.1 Patient AI Assistant

Communicates directly with patients.

Responsibilities:

* Understand patient questions
* Understand symptom descriptions
* Ask clarifying questions
* Provide general health information
* Explain medical terminology
* Help patients prepare for consultations
* Explain existing documents
* Guide patients toward healthcare services

---

## 3.2 Clinical Information Assistant

Assists doctors by organizing existing patient information.

Responsibilities:

* Summarize patient history
* Summarize previous consultations
* Summarize diagnostic reports
* Organize relevant medical information
* Highlight information explicitly present in source records

It does not make clinical decisions.

---

## 3.3 Document Explanation Assistant

Helps patients understand documents they already possess.

Examples:

* Prescription explanation
* Lab report explanation
* Discharge summary explanation

It may simplify terminology but must not convert an explanation into a diagnosis or treatment recommendation.

---

# 4. What the AI MAY Do

The AI may:

### Understand

* Understand natural-language symptom descriptions
* Interpret conversational language
* Ask follow-up questions
* Identify information the patient has explicitly provided

### Explain

* Explain medical terms
* Explain general health concepts
* Explain the contents of uploaded documents
* Simplify complex information

### Summarize

* Summarize consultations
* Summarize diagnostic reports
* Summarize patient history
* Summarize existing prescriptions
* Organize healthcare information for doctors

### Guide

* Explain how to access healthcare
* Help find appropriate healthcare services
* Explain appointment procedures
* Explain referral processes
* Guide users through application navigation

### Communicate

* Communicate in supported languages
* Provide voice-based assistance
* Help users describe their symptoms to healthcare professionals

---

# 5. What the AI MUST NOT Do

The AI must NOT:

* Diagnose a disease as a confirmed fact
* Prescribe medication
* Recommend a medication for a current condition
* Recommend changing medication
* Recommend stopping medication
* Recommend increasing/decreasing dosage
* Select a treatment plan
* Claim to replace a doctor
* Generate a medical prescription
* Override a doctor's decision
* Modify clinical records
* Modify prescriptions
* Modify diagnostic results
* Make autonomous referral decisions
* Present speculative information as established fact

---

# 6. Medication Safety

Medication is a particularly sensitive area.

The AI must not independently tell a patient:

> "Take this medicine."

or:

> "Stop taking this medicine."

or:

> "Increase your dosage."

The AI may explain an existing doctor-created prescription.

For example:

> "Your prescription states that this medicine should be taken according to the instructions provided by your doctor."

The AI may explain terminology appearing on the prescription without changing the doctor's instructions.

If the patient asks:

> "Can I take another medicine instead?"

The AI should not select the alternative.

It should direct the patient toward a qualified healthcare professional.

---

# 7. Diagnosis Safety

The AI must not present a diagnosis as a confirmed medical fact.

Unsafe:

> "You have dengue."

Safer:

> "Fever can have many possible causes. A healthcare professional may need to evaluate your symptoms and, if appropriate, perform testing."

The AI may discuss general possibilities for educational purposes only, provided it does not imply that the patient has a specific disease.

---

# 8. Symptom Conversations

The AI may ask questions to understand the patient's complaint.

Example:

```text id="h5n2r8"
Patient:
"I have had a fever for three days."

AI:
"How high has your temperature been, if you have measured it?"

Patient:
"About 102°F."

AI:
"Are you experiencing difficulty breathing, confusion,
severe weakness, or any other serious symptoms?"
```

The purpose is to:

* Gather information
* Improve communication
* Identify potential urgency
* Help the patient reach appropriate care

The purpose is not to independently diagnose the patient.

---

# 9. Urgency Guidance

The AI may help identify situations that could require urgent professional attention.

It may classify the interaction for navigation purposes such as:

```text id="q7m4p1"
Routine
Priority
Urgent
Emergency
```

However, this classification must not be represented as a medical diagnosis.

For high-risk situations, the AI should encourage appropriate professional/emergency assistance.

---

# 10. Emergency Escalation

If a conversation contains potentially serious symptoms, the AI should prioritize safety over continuing a long conversation.

Conceptually:

```text id="w3k8n2"
Potential Emergency
       ↓
Stop unnecessary questioning
       ↓
Explain need for urgent help
       ↓
Offer Emergency Mode
       ↓
Find/contact appropriate healthcare
       ↓
Provide controlled emergency guidance
```

The AI should not delay emergency access by asking unnecessary questions.

---

# 11. Emergency Content Must Not Depend on AI

Critical emergency procedures must come from controlled, clinically reviewed content.

Examples include:

* Snake-bite first response
* Severe bleeding
* Breathing emergencies
* Unconsciousness
* Other predefined emergency scenarios

The application must not ask a general-purpose LLM:

> "What should the patient do for a snake bite?"

and display the answer directly.

Instead:

```text id="p8v2m5"
Emergency Type
      ↓
Verified Emergency Content
      ↓
Visual + Audio Instructions
```

This content must be available offline.

---

# 12. Snake-Bite Safety

Snake-bite guidance is a flagship emergency feature.

The system must use predetermined, clinically reviewed instructions.

The AI may help the patient navigate the emergency workflow, but it must not dynamically generate medical procedures.

The emergency workflow should prioritize:

1. Getting professional medical help
2. Appropriate transport
3. Safe predefined first-response instructions
4. Avoiding harmful actions
5. Reaching an appropriate healthcare facility

---

# 13. AI Cannot Override Emergency Content

If AI-generated content conflicts with controlled emergency content:

**Controlled emergency content takes precedence.**

The AI should never modify or reinterpret safety-critical instructions dynamically.

---

# 14. AI Clinical Summary Safety

The AI may generate a patient history summary for doctors.

Example:

```text id="v4m9q2"
AI-GENERATED SUMMARY

Previous recorded conditions:
...

Recent diagnostic findings:
...

Previous consultations:
...

Previous prescriptions:
...

Pending referrals:
...
```

The summary must be clearly identified as AI-generated.

The doctor must be able to access the original source records.

---

# 15. No Fabrication

The AI must not invent:

* Diagnoses
* Symptoms
* Medications
* Test results
* Dates
* Consultations
* Referrals
* Patient history
* Doctor decisions

If information is missing, the AI should say that the information is unavailable.

Example:

> "No previous diagnostic report is available in the records provided."

It must not fill the gap using assumptions.

---

# 16. Source Attribution

Where practical, AI-generated summaries should maintain references to the source information.

For example:

```text id="n8c4r7"
Summary Statement
       ↓
Source:
Diagnostic Report — 24 Aug 2026
```

Doctors should be able to inspect the original information.

---

# 17. Conflicting Information

If records contain conflicting information, the AI must not silently choose one.

Example:

```text id="z5m2k8"
Prescription A:
Medication X

Prescription B:
Medication Y
```

The AI should surface the discrepancy rather than deciding which prescription is correct.

For example:

> "The available records contain different medication information. Please review the original records or consult the treating doctor."

---

# 18. Uncertainty Handling

The AI should communicate uncertainty explicitly.

Use phrases such as:

* "Based on the information provided..."
* "This may have several possible causes..."
* "The available records do not provide enough information..."
* "A healthcare professional should assess this..."

Avoid:

* "Definitely"
* "You have..."
* "This proves..."
* "You should take..."

unless referring to an explicit existing clinical instruction.

---

# 19. AI Hallucination Prevention

The AI system should use controlled prompts and structured inputs.

For medical record summaries:

```text id="r6q3w9"
Authorized Patient Data
        ↓
Structured AI Input
        ↓
AI
        ↓
Structured Output
        ↓
Validation
        ↓
Doctor
```

The AI should not have unrestricted database access.

---

# 20. AI Database Access

The AI must never have unrestricted direct access to MongoDB.

Correct:

```text id="y4n8p2"
Backend
   ↓
Authorization
   ↓
Select permitted records
   ↓
Prepare AI input
   ↓
AI
```

Incorrect:

```text id="k7m3v9"
AI
 ↓
Entire Database
```

---

# 21. Patient Data Minimization

Only information required for the current AI operation should be provided.

For example:

### Document explanation

Send:

* Selected document

Do not automatically send:

* Entire patient history

### Patient summary

Send:

* Relevant authorized patient records

Do not send:

* Unrelated users or patients

---

# 22. Role-Based AI Access

AI access must respect the requesting user's permissions.

### Patient AI

Can use:

* Patient's own permitted information

### Doctor AI

Can use:

* Patient information the doctor is authorized to access

### Healthcare Worker AI

Can use:

* Information required for their authorized workflow

The AI must not bypass backend authorization.

---

# 23. Patient Privacy

The AI should not expose:

* Another patient's information
* Unauthorized medical records
* Private doctor information
* Internal system information
* Authentication credentials
* API keys

---

# 24. Voice Assistant Safety

Voice assistance is an accessibility mechanism.

Voice interaction does not change the AI's medical permissions.

For example:

```text id="f8q2m6"
Voice Input
    ↓
AI
    ↓
Same Safety Rules
    ↓
Voice Output
```

A patient speaking in Marathi does not give the AI additional clinical authority.

---

# 25. Multilingual Safety

The application UI remains in plain English.

Voice assistance may support:

* English
* Hindi
* Marathi

Translations should preserve the intended meaning of safety-critical information.

Emergency content should preferably use predefined reviewed translations/audio rather than dynamically translating critical instructions every time.

---

# 26. Low-Literacy Safety

The AI should communicate with patients using:

* Simple vocabulary
* Short sentences
* One instruction at a time
* Minimal medical terminology
* Clear actions
* Voice guidance where available

If a medical term is necessary, the AI should explain it in simple language.

---

# 27. Financial/Access Constraints

If a patient says they cannot currently afford or access a doctor, the AI should not respond only with:

> "Consult a doctor."

Instead, it should help the patient navigate available healthcare options, such as:

* Public healthcare facilities
* PHCs
* Government hospitals
* Available teleconsultation pathways
* Emergency services when appropriate

The AI must still avoid providing unsafe autonomous treatment.

---

# 28. No False Assurance

The AI must not tell a patient that they are safe merely because no serious symptom was mentioned.

Avoid:

> "You're fine."

Prefer:

> "Based on the information you've provided, I cannot determine the cause of your symptoms. If your symptoms worsen or you develop serious symptoms, seek medical attention."

---

# 29. Emergency Override

If the user enters an obvious emergency scenario, emergency access should take priority over general conversation.

Example:

```text id="x6p3r8"
Patient:
"My father is unconscious."

AI:
"Please seek emergency medical help immediately."

[🚨 EMERGENCY]

[📞 CALL EMERGENCY SERVICES]

[🏥 FIND NEAREST SUITABLE FACILITY]
```

The application should not force the user through lengthy AI questioning before providing emergency access.

---

# 30. AI Response Structure

Where appropriate, patient-facing AI responses should use:

```text id="j4m8q2"
1. Direct answer
2. Important safety information
3. What the patient can do next
4. When to seek professional help
```

Keep responses concise for users with limited health literacy.

---

# 31. Doctor-Facing AI Response Structure

Doctor-facing summaries should prioritize:

```text id="n7c2v5"
Patient Overview
↓
Current Concern
↓
Relevant History
↓
Recent Diagnostics
↓
Previous Prescriptions
↓
Relevant Trends
↓
Pending Referrals / Follow-ups
↓
Source Records
```

The doctor should not have to read a long conversational AI response.

---

# 32. AI Logging

The system should log appropriate AI operation metadata such as:

* User/requesting role
* Operation type
* Timestamp
* AI service/model identifier where appropriate
* Source record identifiers
* Result status

Do not unnecessarily store sensitive AI conversation content.

---

# 33. AI Failure Handling

If the AI service fails:

The application should still allow:

* Emergency mode
* Emergency offline guidance
* Healthcare facility information
* Existing health record access
* Existing prescriptions
* Existing diagnostic reports
* Other non-AI functionality

Example:

> "The AI assistant is temporarily unavailable. You can still access healthcare services and emergency assistance."

AI availability must never become a single point of failure for emergency functionality.

---

# 34. AI Provider Independence

AI functionality should be accessed through a backend AI service abstraction.

Conceptually:

```text id="c8m4q1"
Application
    ↓
AI Service Interface
    ↓
Selected AI Provider
```

This allows the AI provider to be changed without redesigning the entire application.

---

# 35. Model Output Validation

Where possible, AI outputs should be validated before being shown to users or stored.

Validation may check:

* Required structure
* Missing fields
* Unsupported claims
* Medication-related outputs
* Emergency-related outputs
* Invalid data references

Safety-critical workflows should rely on deterministic application logic wherever possible.

---

# 36. AI and Clinical Records

AI must never silently modify clinical records.

For example:

```text id="w2p7n5"
AI Summary
      ↓
Doctor reviews
      ↓
Doctor decides
      ↓
Doctor explicitly records clinical information
```

Not:

```text id="r9k4m1"
AI
 ↓
Automatically changes patient diagnosis
```

---

# 37. AI and Prescriptions

The only component authorized to create a prescription is the appropriate clinical workflow performed by an authorized doctor.

AI may:

* Explain an existing prescription
* Summarize prescription history

AI may not:

* Create a prescription
* Modify a prescription
* Recommend a medication
* Change dosage
* Stop medication

---

# 38. AI and Referrals

AI may:

* Explain an existing referral
* Explain referral status
* Help the patient navigate the referral process

AI should not autonomously create or finalize a clinical referral.

A healthcare professional should make the clinical referral decision.

---

# 39. AI and Diagnostics

AI may:

* Organize diagnostic information
* Summarize a diagnostic report
* Explain terminology in a report

AI must not:

* Declare a diagnosis based solely on a report
* Prescribe treatment based on a report
* Override a doctor's interpretation

---

# 40. Human Oversight

Any AI-generated information that could influence clinical care should remain subject to professional review.

The system should encourage doctors to verify important information against source records.

---

# 41. Safety-First Priority Order

When multiple objectives conflict, the system should prioritize:

```text id="m8q2v6"
1. Immediate safety
2. Emergency access
3. Human clinical involvement
4. Accuracy
5. Patient privacy
6. Healthcare access
7. Convenience
```

Convenience must never override safety.

---

# 42. Core AI Contract

All AI components in RuralCare should follow this contract:

> **The AI is an assistant, not a doctor.**

It can:

> Understand → Explain → Summarize → Organize → Guide → Communicate

It cannot:

> Diagnose → Prescribe → Treat → Override → Make autonomous clinical decisions

This contract applies to:

* Text AI
* Voice AI
* Patient AI
* Doctor-facing AI
* Document AI
* Diagnostic summarization AI
* Any future AI functionality added to RuralCare.
