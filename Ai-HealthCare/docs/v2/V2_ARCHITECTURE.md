# RuralCare V2 — Architecture Specification

## 1. Purpose

RuralCare V2 extends the existing RuralCare V1 patient application with three major capabilities:

1. Multilingual support for English, Hindi, and Bengali.
2. A dedicated pregnancy and maternal-care experience.
3. GPS-powered discovery of nearby hospitals, clinics, and doctors.

V2 must build on the existing V1 foundation rather than unnecessarily rebuilding existing functionality.

The primary target remains the **patient-side application**.

---

# 2. Core V2 Principles

## 2.1 Extend V1, Do Not Rebuild V1

V1 is the existing foundation of the application.

V2 must:

* Reuse existing authentication.
* Reuse existing patient profile functionality where appropriate.
* Reuse existing AI consultation functionality where appropriate.
* Reuse existing UI components when they remain compatible.
* Reuse existing backend infrastructure where possible.
* Reuse existing documentation when it still applies.

Do not create duplicate implementations of existing V1 functionality.

If a V2 requirement changes existing V1 behavior, modify the existing implementation rather than creating a parallel implementation.

---

## 2.2 Patient-First Development

V2 is currently focused on the patient experience.

Do not implement doctor/admin functionality unless it is required to support a patient-side V2 feature.

---

## 2.3 Safety-First Healthcare Design

RuralCare is a healthcare-support application.

The AI and application must not present itself as a replacement for a qualified healthcare professional.

V2 must clearly distinguish between:

* General health information
* Routine care
* Situations requiring professional medical attention
* Emergency situations

Emergency scenarios must prioritize immediate access to appropriate healthcare facilities over lengthy AI conversations.

---

# 3. V2 Major Feature Modules

V2 consists of three primary feature modules.

```text
RuralCare V2
│
├── Multilingual System
│
├── Pregnancy Care
│
└── Healthcare Finder
```

These modules must also be able to interact with each other.

Example:

```text
Pregnancy emergency
        ↓
Emergency guidance
        ↓
Healthcare Finder
        ↓
Nearby hospital
        ↓
Directions / call facility
```

---

# 4. Multilingual Architecture

## 4.1 Supported Languages

RuralCare V2 must support:

| Language | Code |
| -------- | ---- |
| English  | en   |
| Hindi    | hi   |
| Bengali  | bn   |

Important:

`bn` must be used as the Bengali language code.

`be` must NOT be used for Bengali because `be` represents Belarusian.

---

## 4.2 Localization Requirements

All user-facing static text must use the localization system.

Do not hard-code user-facing strings directly into widgets/screens when a localized equivalent is required.

Localization must cover:

* Navigation
* Buttons
* Labels
* Forms
* Validation messages
* Error messages
* Empty states
* Settings
* Pregnancy content
* Emergency instructions
* Healthcare finder
* Notifications
* Accessibility labels
* AI-related interface text

---

## 4.3 Language Selection

The user must be able to select:

* English
* Hindi
* Bengali

The selected language should persist across application sessions.

Changing the language should update the application without requiring unnecessary reinstallation or account recreation.

---

## 4.4 AI Language Behavior

The selected application language must be passed to the AI layer as context.

Expected behavior:

```text
App Language = English
        ↓
AI response = English

App Language = Hindi
        ↓
AI response = Hindi

App Language = Bengali
        ↓
AI response = Bengali
```

The AI must not randomly switch languages unless the user explicitly requests another language.

If the user writes in another supported language, the system may adapt to the user's explicit request, but the selected application language remains the default response language.

---

# 5. Pregnancy Care Architecture

Pregnancy care must be implemented as a dedicated feature module.

It must not simply be a collection of generic AI prompts.

```text
Pregnancy Care
│
├── Pregnancy Profile
├── Pregnancy Dashboard
├── Pregnancy Progress
├── Antenatal Care
├── Nutrition Guidance
├── Common Symptoms
├── Warning Signs
├── Reminders
└── Emergency Escalation
```

---

## 5.1 Pregnancy Profile

The pregnancy profile should store only information necessary for providing the intended patient experience.

Potential data includes:

* Pregnancy status
* Pregnancy week/stage
* Estimated due date
* Relevant care information
* Important appointments/reminders

Sensitive healthcare information must be handled securely.

---

## 5.2 Pregnancy Dashboard

The dashboard should provide a simple overview of the pregnancy journey.

Possible sections:

* Current pregnancy week
* Pregnancy stage
* Estimated due date
* Upcoming care/reminders
* Important guidance
* Warning signs
* Emergency access

The dashboard must remain understandable for users with limited medical knowledge.

---

## 5.3 Pregnancy Guidance

Pregnancy information should be organized by pregnancy stage.

```text
First Trimester
Second Trimester
Third Trimester
```

Content should cover appropriate general guidance such as:

* Antenatal care
* Nutrition
* Rest and wellbeing
* Routine checkups
* Common pregnancy symptoms
* When to contact a healthcare professional

The application must avoid presenting generalized information as personalized medical diagnosis.

---

# 6. Pregnancy Emergency Architecture

Pregnancy-related danger signs require a dedicated emergency pathway.

The application must distinguish:

```text
NORMAL
↓
Monitor / general guidance

CONCERNING
↓
Contact healthcare professional

EMERGENCY
↓
Seek immediate medical care
↓
Find nearby healthcare facility
```

The emergency pathway should be highly visible.

When a situation appears potentially urgent, the application must not bury the emergency recommendation underneath a long AI response.

---

## 6.1 Emergency Escalation

A pregnancy emergency can initiate:

```text
Emergency Detection
        ↓
Clear Emergency Message
        ↓
Recommend Immediate Medical Care
        ↓
Find Nearby Hospital
        ↓
Display Distance
        ↓
Call / Directions
```

The AI must not claim certainty about a diagnosis.

The emergency system should use clear, direct language.

---

# 7. GPS Healthcare Finder

V2 must provide a dedicated healthcare discovery feature.

The user should be able to find:

* Hospitals
* Clinics
* Doctors

The architecture should allow additional healthcare categories to be added later without redesigning the entire feature.

Possible future categories:

* Pharmacies
* Diagnostic centers
* Ambulance services
* Maternal-care facilities

---

# 8. Location Architecture

The application must request location permission only when location functionality is required.

Expected flow:

```text
User opens Healthcare Finder
        ↓
Check location permission
        ↓
Permission available?
       / \
     YES  NO
      ↓    ↓
Get GPS  Explain why
location  permission is needed
      ↓
Search nearby facilities
```

The application must gracefully handle:

* Permission granted
* Permission denied
* Permission permanently denied
* GPS disabled
* Location unavailable
* Poor accuracy
* Network unavailable

The application must never assume that GPS permission is automatically available.

---

# 9. Healthcare Search

Once the user's location is available, the healthcare finder should search for relevant nearby facilities.

Each result should support information such as:

* Facility name
* Facility type
* Distance
* Address
* Contact information when available
* Available services when available
* Operating status when available
* Directions

Data must be presented clearly and should not overwhelm the user.

---

# 10. Healthcare Facility Details

Selecting a healthcare result should open a facility details view.

Example:

```text
Hospital Name

Hospital
Distance: X km

Address
Phone

Available information/services

[Call]
[Get Directions]
```

Only information actually available from the healthcare data provider should be displayed.

Do not invent:

* Doctors
* Services
* Opening hours
* Phone numbers
* Ratings
* Emergency capabilities

---

# 11. Directions

The application should provide a straightforward route from the user's current location to the selected healthcare facility.

Expected flow:

```text
Current Location
       ↓
Selected Facility
       ↓
Get Directions
       ↓
External navigation / supported map experience
```

The architecture must keep navigation provider-specific implementation isolated so the mapping provider can be changed later without rewriting the healthcare finder.

---

# 12. GPS + Pregnancy Integration

Pregnancy care and GPS must be integrated.

For example:

```text
Pregnancy Care
      ↓
Emergency / Warning Sign
      ↓
Find Healthcare
      ↓
Nearby Hospitals
      ↓
Hospital Details
      ↓
Call / Directions
```

This integration is a major V2 requirement.

The user should not have to manually navigate through unrelated parts of the application during an emergency.

---

# 13. Backend Architecture

V2 should extend the existing backend.

Do not create a separate backend unless the existing architecture cannot support the new requirements.

Potential backend responsibilities:

```text
Backend
│
├── Existing V1 APIs
├── Patient data
├── Pregnancy data
├── AI services
├── Healthcare/location-related services
└── Security / validation
```

Sensitive data must not be exposed directly to the client when it should be handled server-side.

API keys and private credentials must never be committed to the repository.

---

# 14. Flutter Architecture

V2 should maintain a modular Flutter architecture.

Recommended conceptual structure:

```text
lib/
│
├── core/
│   ├── localization/
│   ├── location/
│   ├── networking/
│   ├── theme/
│   └── utilities/
│
├── features/
│   ├── authentication/
│   ├── patient/
│   ├── ai/
│   ├── pregnancy/
│   └── healthcare_finder/
│
└── shared/
    ├── widgets/
    ├── models/
    └── services/
```

This is a conceptual architecture.

Antigravity must inspect the actual V1 project before creating or moving files.

Do not blindly restructure the existing V1 codebase.

---

# 15. Navigation Architecture

V2 navigation should make the three major capabilities easy to reach.

The exact navigation structure must follow the existing V1 design system unless a V2 requirement requires a change.

At minimum, users should have clear access to:

* AI Health Support
* Pregnancy Care
* Nearby Healthcare

Emergency actions should be accessible from relevant screens without requiring excessive navigation.

---

# 16. Offline and Poor Connectivity Considerations

RuralCare targets users who may experience unreliable internet connectivity.

V2 should therefore minimize unnecessary network dependencies.

The application should gracefully handle:

* Slow network
* Temporary network loss
* Failed API requests
* Location service failure
* Healthcare search failure

Static localization resources should be available locally.

Critical UI and emergency instructions should not depend entirely on a successful AI request.

---

# 17. Security and Privacy

V2 must preserve the security standards of V1 and extend them to new healthcare information.

Requirements include:

* Secure authentication
* Secure API communication
* No secrets in source code
* No API keys in public repositories
* Appropriate protection of pregnancy information
* Minimal collection of personal data
* Proper permission handling
* Safe error messages that do not expose sensitive information

Location data must only be accessed when necessary for the requested functionality.

---

# 18. Error Handling

Every V2 feature must have explicit failure states.

Examples:

### Language

```text
Translation unavailable
→ Fall back to the default supported language/resource
```

### GPS

```text
Location unavailable
→ Explain the problem
→ Allow retry
→ Provide appropriate fallback
```

### Healthcare Search

```text
No facilities found
→ Clearly inform user
→ Allow search retry / adjustment
```

### AI

```text
AI unavailable
→ Show a clear error
→ Preserve emergency guidance
→ Do not pretend the AI responded
```

---

# 19. AI Safety Requirements

The AI must:

* Avoid diagnosing with certainty.
* Avoid pretending to be a doctor.
* Clearly communicate uncertainty.
* Recommend professional care when appropriate.
* Escalate potential emergencies.
* Use the selected application language.
* Format responses consistently.
* Avoid repetitive generic responses.
* Never invent healthcare facilities or medical resources.

For emergency situations, the application should prioritize actionable safety guidance over conversational interaction.

---

# 20. V2 Development Phases

Development must occur incrementally.

## Phase 1 — Architecture

* Inspect V1.
* Identify reusable components/services.
* Establish V2 integration points.
* Do not unnecessarily restructure V1.

## Phase 2 — Multilingual

* Implement localization architecture.
* Add English.
* Add Hindi.
* Add Bengali.
* Persist language selection.
* Integrate selected language with AI.

## Phase 3 — Pregnancy Care

* Pregnancy profile.
* Pregnancy dashboard.
* Pregnancy progression.
* Pregnancy guidance.
* Warning signs.
* Emergency pathway.

## Phase 4 — Healthcare Finder

* Location permission.
* GPS acquisition.
* Healthcare search.
* Hospital results.
* Clinic results.
* Doctor results.
* Facility details.
* Directions.

## Phase 5 — Integration

Connect:

```text
AI
↕
Pregnancy Care
↕
Emergency System
↕
Healthcare Finder
↕
GPS / Directions
```

## Phase 6 — Testing

Test:

* English
* Hindi
* Bengali
* Pregnancy workflows
* Emergency workflows
* GPS permission states
* GPS disabled
* No healthcare results
* Poor connectivity
* AI failure
* Backend failure
* Small-screen usability

---

# 21. Definition of Done

RuralCare V2 should not be considered complete until:

### Multilingual

* [ ] English works.
* [ ] Hindi works.
* [ ] Bengali works.
* [ ] Language selection persists.
* [ ] Major UI text is localized.
* [ ] AI follows the selected language.

### Pregnancy

* [ ] Pregnancy profile works.
* [ ] Pregnancy dashboard works.
* [ ] Pregnancy stage/week is represented correctly.
* [ ] Pregnancy guidance is available.
* [ ] Warning signs are clearly separated from routine information.
* [ ] Emergency pathway works.

### GPS

* [ ] Location permission works.
* [ ] Permission denial is handled.
* [ ] GPS failure is handled.
* [ ] Nearby hospitals can be discovered.
* [ ] Nearby clinics can be discovered.
* [ ] Nearby doctors can be discovered.
* [ ] Facility details are displayed.
* [ ] Directions can be initiated.

### Integration

* [ ] Pregnancy emergency can lead directly to nearby healthcare.
* [ ] Healthcare finder works with the selected language.
* [ ] AI respects the selected language.
* [ ] Emergency information remains available even if AI/network services fail.

---

# 22. Implementation Rule for Antigravity

Before modifying the codebase:

1. Read `AGENTS.md`.
2. Read all applicable V1 documentation.
3. Inspect the existing Flutter structure.
4. Identify existing reusable services/components.
5. Identify the existing backend architecture.
6. Identify existing AI integration.
7. Identify existing navigation.
8. Only then implement V2.

Do not create unnecessary documentation.

Do not duplicate existing V1 documentation.

Do not replace working V1 functionality without a V2 requirement.

Do not create mock functionality and present it as complete functionality.

Every V2 feature must be implemented as a production-oriented feature with appropriate loading, error, empty, permission, and failure states.

---

# 23. V2 Product Goal

The goal of RuralCare V2 is to make the application significantly more useful for rural patients by combining:

```text
Language Accessibility
        +
Pregnancy & Maternal Care
        +
Location-Aware Healthcare Access
```

The final experience should allow a patient to communicate with the application in their preferred language, receive structured pregnancy-related support, and quickly locate appropriate nearby healthcare when professional or emergency care is required.
