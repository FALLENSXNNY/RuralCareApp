# RuralCare V2 — Pregnancy Care Specification

## 1. Purpose

RuralCare V2 must provide a dedicated pregnancy and maternal-care experience for patients.

Pregnancy care must not be implemented as a generic AI chatbot category.

It must be a structured patient-care module that combines:

* Pregnancy information
* Pregnancy progress
* Antenatal care guidance
* Symptoms and warning signs
* Reminders
* AI assistance
* Emergency escalation
* GPS-based access to nearby healthcare

The pregnancy module must remain simple enough for rural patients and users with limited medical knowledge.

---

# 2. Safety Principle

RuralCare provides healthcare support and information.

It must not claim to replace:

* Doctors
* Nurses
* Midwives
* Hospitals
* Emergency medical services

The application must not diagnose pregnancy complications with certainty.

When symptoms may indicate a serious or emergency condition, the application must prioritize professional medical care.

---

# 3. Pregnancy Module Structure

The pregnancy feature should conceptually contain:

```text
Pregnancy Care
│
├── Pregnancy Profile
│
├── Pregnancy Dashboard
│
├── Pregnancy Progress
│
├── Antenatal Care
│
├── Nutrition & Wellbeing
│
├── Symptoms
│
├── Warning Signs
│
├── Reminders
│
├── AI Pregnancy Support
│
└── Emergency Care
```

The exact Flutter folder structure must follow the existing V1 architecture.

Do not blindly create a new architecture without inspecting V1.

---

# 4. Pregnancy Entry Point

The patient should be able to access Pregnancy Care from the main patient experience.

The entry point should be clearly understandable.

Example:

```text
Home
│
├── AI Health Support
├── Pregnancy Care
└── Nearby Healthcare
```

If the existing V1 navigation structure is different, preserve the established design unless V2 requirements require modification.

---

# 5. Pregnancy Profile

The pregnancy profile stores information necessary for the pregnancy-care experience.

Potential information:

* Pregnancy status
* Pregnancy week
* Estimated due date
* Relevant pregnancy information
* Important appointments
* Reminders

Only collect information that is actually required.

Do not introduce unnecessary medical data collection.

---

# 6. Pregnancy Week and Due Date

The system should support pregnancy progress using pregnancy week and/or estimated due date.

The application must not blindly trust manually entered values when a calculation is possible.

Where appropriate:

```text
Estimated Due Date
        ↓
Pregnancy Progress Calculation
        ↓
Current Pregnancy Week
        ↓
Pregnancy Stage
```

The application must handle:

* Missing due date
* Invalid date
* Future/inconsistent dates
* User corrections

Calculations must be deterministic and testable.

---

# 7. Pregnancy Stages

The pregnancy experience should organize information into:

```text
First Trimester
Second Trimester
Third Trimester
```

The UI should clearly communicate the current stage.

The application should avoid overwhelming the user with information unrelated to the current pregnancy stage.

---

# 8. Pregnancy Dashboard

The pregnancy dashboard should provide a concise overview.

Recommended structure:

```text
Pregnancy Care

Current Week
Week XX

Pregnancy Stage
First / Second / Third Trimester

Estimated Due Date
DD/MM/YYYY

Upcoming Care
Next appointment/reminder

Important Guidance
Relevant current-stage information

Warning Signs
Know when to seek help

Emergency Care
Find nearby healthcare
```

The exact visual design must follow the V1/V2 design system.

---

# 9. Pregnancy Guidance

Pregnancy guidance should be structured by stage.

Possible topics:

### First Trimester

* Early pregnancy changes
* Antenatal care
* Nutrition
* Rest
* Common symptoms
* Warning signs

### Second Trimester

* Routine antenatal care
* Nutrition
* Physical wellbeing
* Common symptoms
* Warning signs

### Third Trimester

* Antenatal care
* Birth preparation
* Warning signs
* When to seek urgent care
* Preparing for delivery

Content must remain general educational guidance unless the application has a clinically validated basis for personalization.

---

# 10. Antenatal Care

The module should encourage appropriate antenatal care.

Potential functionality:

* Upcoming checkups
* Reminder support
* General checkup guidance
* Important questions to discuss with healthcare professionals

The app must not invent appointment schedules for an individual patient.

If a schedule is provided, it must come from an appropriate source or user-entered information.

---

# 11. Nutrition and Wellbeing

Pregnancy Care may provide general educational guidance on:

* Balanced nutrition
* Hydration
* Rest
* General wellbeing
* Healthy habits

The AI must avoid making unsafe personalized nutritional or medication recommendations without sufficient context.

The application must not encourage users to stop prescribed treatment or replace professional advice.

---

# 12. Symptoms

The application may help the user understand common pregnancy symptoms.

Symptoms should be categorized clearly.

Conceptually:

```text
Common / Usually Expected
        ↓
General information

Concerning
        ↓
Contact healthcare professional

Emergency Warning Sign
        ↓
Seek immediate medical care
```

The app should not imply that a symptom is harmless solely because it can occur during pregnancy.

---

# 13. Pregnancy Warning Signs

The application must maintain a clearly visible warning-sign section.

Examples of potentially serious symptoms include:

* Heavy vaginal bleeding
* Severe abdominal or pelvic pain
* Severe difficulty breathing
* Loss of consciousness
* Seizures
* Severe headache with concerning symptoms
* Sudden severe swelling or other concerning changes
* Fluid leakage that may indicate an urgent pregnancy-related issue
* Markedly reduced or absent fetal movement when fetal movement is expected

This list must be medically reviewed before production release.

The AI must not treat the list as a diagnostic checklist.

---

# 14. Emergency Classification

Pregnancy-related user input should be evaluated for urgency.

Conceptually:

```text
User describes symptom
        ↓
AI / safety logic evaluates urgency
        ↓
┌───────────────┬────────────────┬─────────────────┐
│ Routine       │ Concerning     │ Emergency       │
│ information   │ medical review │ immediate care  │
└───────────────┴────────────────┴─────────────────┘
```

The system must favor safety when the available information is insufficient.

It must not provide false reassurance.

---

# 15. Emergency Experience

When a potentially serious pregnancy emergency is identified, the application should provide a dedicated emergency experience.

Example:

```text
Possible Emergency

You may need urgent medical care.

[Find Nearby Hospital]

[Call Healthcare Facility]

[Emergency Information]
```

The exact emergency actions depend on available services and the user's location.

The application should not delay emergency action by requiring a lengthy AI conversation.

---

# 16. Pregnancy Emergency → GPS

The pregnancy module must integrate directly with the Healthcare Finder.

Required flow:

```text
Pregnancy Care
      ↓
Potential Emergency
      ↓
Emergency Guidance
      ↓
Find Nearby Healthcare
      ↓
Hospitals / Clinics / Doctors
      ↓
Select Facility
      ↓
Call / Directions
```

This is a core V2 integration requirement.

---

# 17. Pregnancy AI

The existing RuralCare AI should be extended to support pregnancy-related questions.

Examples:

```text
"What foods are generally recommended during pregnancy?"

"I am 24 weeks pregnant. What routine care should I discuss with my doctor?"

"I have severe abdominal pain during pregnancy."
```

The AI must provide:

* Clear structure
* Appropriate caution
* Relevant pregnancy context
* Appropriate escalation
* Selected-language response

The AI must never claim to have examined the patient.

---

# 18. AI Language Integration

Pregnancy AI must follow the application's selected language.

```text
Selected language = English
→ English pregnancy response

Selected language = Hindi
→ Hindi pregnancy response

Selected language = Bengali
→ Bengali pregnancy response
```

The language synchronization requirements in `V2_MULTILANGUAGE.md` apply fully to Pregnancy AI.

---

# 19. AI Emergency Behavior

If a user describes potentially dangerous pregnancy symptoms, the AI should:

1. Clearly identify that the situation may require urgent medical attention.
2. Avoid giving false reassurance.
3. Give concise immediate guidance.
4. Encourage contacting/going to appropriate healthcare.
5. Provide the option to locate nearby healthcare when GPS is available.
6. Avoid unnecessary lengthy explanations.
7. Respond in the selected application language.

---

# 20. Emergency Information Must Not Depend on AI

Critical emergency UI content must be available without an AI response.

For example:

```text
Emergency
↓
Immediate safety message
↓
Find nearby hospital
```

must still function if:

* AI API fails
* Internet is unavailable
* AI request times out
* Backend is unavailable

AI should enhance the experience, not become the single point of failure for emergency access.

---

# 21. Pregnancy Reminders

The application may support reminders for user-entered or application-supported pregnancy-care tasks.

Potential examples:

* Appointment reminders
* Medication reminders where appropriate
* General care reminders

The system must clearly distinguish between:

```text
User-created reminder
```

and:

```text
Clinically recommended schedule
```

Do not present an automatically generated reminder as a medical prescription or mandatory clinical schedule.

---

# 22. Pregnancy Data Privacy

Pregnancy information is sensitive healthcare information.

The application must:

* Store only necessary information.
* Secure data in transit.
* Secure data at rest where applicable.
* Avoid exposing pregnancy information through logs.
* Avoid exposing sensitive data in error messages.
* Never commit patient data to the repository.
* Never expose private backend credentials.

The existing V1 security architecture should be reused and extended.

---

# 23. Offline Considerations

Basic pregnancy-care information should not depend entirely on an active internet connection.

At minimum, the application should preserve access to:

* Basic pregnancy UI
* Core emergency guidance
* Locally bundled translations
* Previously available pregnancy information where appropriate

AI-powered functionality may require internet connectivity.

If AI is unavailable, the application must clearly indicate that AI assistance is unavailable rather than pretending to provide a generated response.

---

# 24. Pregnancy UI Requirements

The pregnancy interface should prioritize:

* Large readable text
* Clear hierarchy
* Simple language
* High-visibility emergency actions
* Minimal unnecessary navigation
* Accessible buttons
* Responsive layouts
* Support for English, Hindi, and Bengali

Do not overload the dashboard with too many cards or statistics.

The primary actions should be immediately understandable.

---

# 25. Pregnancy Navigation

A user should be able to reach important functions with minimal steps.

Recommended conceptual flow:

```text
Pregnancy Care
│
├── Dashboard
├── Progress
├── Guidance
├── Symptoms
├── Reminders
├── Ask AI
└── Emergency Help
```

The final navigation must integrate naturally with the existing V1 navigation.

---

# 26. Loading, Error and Empty States

Every pregnancy feature requiring data or network access must have proper states.

### Loading

Show a clear loading state.

### Empty

Example:

```text
No upcoming reminders
```

### Error

Example:

```text
Unable to load pregnancy information.
Please try again.
```

### AI Error

Example:

```text
AI assistance is temporarily unavailable.

For urgent symptoms, seek appropriate medical care.
```

Do not show fake or placeholder medical information.

---

# 27. Testing Requirements

Test pregnancy functionality across:

### Pregnancy Data

* [ ] Valid due date
* [ ] Invalid due date
* [ ] Missing due date
* [ ] Pregnancy week calculation
* [ ] Stage calculation
* [ ] User correction

### Languages

* [ ] English
* [ ] Hindi
* [ ] Bengali

### AI

* [ ] General pregnancy question
* [ ] Common symptom
* [ ] Concerning symptom
* [ ] Emergency symptom
* [ ] Language synchronization
* [ ] Markdown rendering

### Emergency

* [ ] Emergency guidance appears clearly
* [ ] AI failure does not remove emergency access
* [ ] GPS healthcare finder can be launched
* [ ] User can access facility details
* [ ] Directions can be initiated

### UI

* [ ] Small screen
* [ ] Large text
* [ ] Hindi text
* [ ] Bengali text
* [ ] Long translations
* [ ] Long AI responses

---

# 28. Definition of Done

Pregnancy Care V2 is complete only when:

* [ ] Pregnancy Care is accessible from the patient application.
* [ ] Pregnancy profile works.
* [ ] Pregnancy progress works.
* [ ] Pregnancy week/stage is represented correctly.
* [ ] Due-date handling is implemented safely.
* [ ] Pregnancy guidance is structured by stage.
* [ ] Symptoms are presented clearly.
* [ ] Warning signs are clearly identified.
* [ ] Emergency escalation works.
* [ ] Pregnancy AI works.
* [ ] Pregnancy AI follows the selected language.
* [ ] Emergency guidance is available without AI.
* [ ] Emergency flow can connect to GPS healthcare discovery.
* [ ] English works.
* [ ] Hindi works.
* [ ] Bengali works.
* [ ] Error and loading states work.
* [ ] Pregnancy data is handled securely.
* [ ] The feature works appropriately under poor connectivity.
* [ ] No medical claims are presented with unjustified certainty.

---

# 29. Implementation Rule for Antigravity

Before implementing Pregnancy Care:

1. Read `AGENTS.md`.
2. Read `V2_ARCHITECTURE.md`.
3. Read `V2_MULTILANGUAGE.md`.
4. Inspect the existing V1 patient profile.
5. Inspect the existing V1 AI architecture.
6. Inspect existing navigation.
7. Inspect existing data models and backend APIs.
8. Reuse compatible V1 infrastructure.
9. Implement the pregnancy data model.
10. Implement the pregnancy dashboard.
11. Implement pregnancy guidance.
12. Implement warning signs and emergency escalation.
13. Connect Pregnancy AI to the multilingual system.
14. Prepare the emergency pathway for integration with the V2 Healthcare Finder.
15. Test before moving to the next V2 module.

Do not implement the GPS healthcare finder inside this module.

The Pregnancy Care module must expose a clean integration point that can launch the V2 Healthcare Finder when urgent care is required.
