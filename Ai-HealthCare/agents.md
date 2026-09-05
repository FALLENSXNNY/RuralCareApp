# RuralCare — AI Development Agent Instructions

## 1. PURPOSE

This is the master instruction file for all AI coding agents working on the RuralCare project.

The agent MUST read this file before making significant changes.

This file defines:

- Project scope
- V1/V2 relationship
- Documentation hierarchy
- Development workflow
- Stitch/MCP design workflow
- Architecture rules
- UI/UX rules
- AI requirements
- Healthcare safety requirements
- Multilingual requirements
- Pregnancy-care requirements
- GPS healthcare requirements
- Security requirements
- Testing requirements
- Progress tracking
- Development memory

The agent must follow these instructions throughout the project.

---

# 2. PROJECT STRUCTURE

The documentation structure is:

docs/
│
├── agents.md
│
├── v1/
│   ├── database.md
│   ├── developmentWorkflow.md
│   ├── feature.md
│   ├── projectOverview.md
│   ├── uiUx.md
│   ├── v1aiSafety.md
│   ├── v1architecture.md
│   ├── v1memory.md
│   ├── v1progress.md
│   └── v1userRoles.md
│
└── v2/
    ├── V2_ARCHITECTURE.md
    ├── V2_GPS_HEALTHCARE.md
    ├── V2_MULTILANGUAGE.md
    ├── V2_PREGNANCY_CARE.md
    ├── v2.memory.md
    └── v2progress.md

Do NOT create additional documentation files unless explicitly requested.

Do NOT create duplicate documentation such as:

- V2 UI/UX documentation
- Duplicate architecture documentation
- Duplicate AI safety documentation
- Duplicate progress files
- Duplicate memory files

Existing V1 documentation must be reused whenever it remains applicable.

---

# 3. DOCUMENTATION HIERARCHY

There are three documentation levels.

## Level 1 — agents.md

This file contains the global development rules.

It must always be considered first.

## Level 2 — V1 Documentation

The `docs/v1/` directory describes the existing RuralCare system.

It is the reference for existing:

- Product requirements
- Features
- Architecture
- Database
- UI/UX
- AI safety
- User roles
- Development workflow
- Historical decisions
- Progress
- Memory

## Level 3 — V2 Documentation

The `docs/v2/` directory describes new V2 requirements.

V2 currently introduces:

1. Multilingual Support
2. Pregnancy Care
3. GPS Healthcare Finder

When V2 explicitly changes V1 behavior, the V2 requirement takes priority.

Otherwise, preserve V1 behavior.

---

# 4. REQUIRED DOCUMENTATION READING

Before significant V2 implementation, read:

1. `docs/agents.md`

Then inspect the relevant V1 documentation:

- `docs/v1/projectOverview.md`
- `docs/v1/v1architecture.md`
- `docs/v1/feature.md`
- `docs/v1/database.md`
- `docs/v1/developmentWorkflow.md`
- `docs/v1/uiUx.md`
- `docs/v1/v1aiSafety.md`
- `docs/v1/v1userRoles.md`
- `docs/v1/v1memory.md`
- `docs/v1/v1progress.md`

Then inspect the relevant V2 documentation:

- `docs/v2/V2_ARCHITECTURE.md`
- `docs/v2/V2_MULTILANGUAGE.md`
- `docs/v2/V2_PREGNANCY_CARE.md`
- `docs/v2/V2_GPS_HEALTHCARE.md`
- `docs/v2/v2.memory.md`
- `docs/v2/v2progress.md`

The agent must read all documentation relevant to the feature it is implementing.

---

# 5. V1 IS THE FOUNDATION

RuralCare V2 is an extension of RuralCare V1.

V2 is NOT a completely separate application.

Before creating a new system, inspect the existing V1 implementation.

Use:

Need functionality
        ↓
Inspect V1
        ↓
Equivalent functionality exists?
        ↓
YES → Reuse / extend
NO  → Implement new functionality

Do not rebuild working V1 systems unnecessarily.

---

# 6. DO NOT DUPLICATE EXISTING SYSTEMS

Before creating a new:

- Service
- Repository
- API client
- Model
- Widget
- Navigation system
- Storage system
- Authentication system
- AI client
- Localization system
- Theme
- Networking layer

the agent MUST inspect the existing project.

If an equivalent implementation exists, extend or reuse it.

Do not create competing systems.

---

# 7. DO NOT REWRITE V1 WITHOUT A REASON

Do not rewrite functioning V1 code simply because V2 is being developed.

A V1 system may be replaced only when:

1. It is broken.
2. It cannot support a required V2 feature.
3. V2 explicitly requires different behavior.
4. Keeping it would create a significant technical or security problem.

Before replacing an existing system, determine whether it can be extended.

Avoid destructive refactoring.

---

# 8. CURRENT V2 SCOPE

The current V2 scope is:

RuralCare V2
│
├── Multilingual
│   ├── English
│   ├── Hindi
│   └── Bengali
│
├── Pregnancy Care
│
└── GPS Healthcare Finder
    ├── Hospitals
    ├── Clinics
    └── Doctors

These are the three major V2 requirements.

Do not expand the product scope unnecessarily.

---

# 9. PATIENT-SIDE PRIORITY

The current V2 development focus is the patient-side application.

Prioritize:

- Patient experience
- Patient profile
- AI health support
- Pregnancy Care
- Emergency assistance
- Healthcare discovery
- Multilingual accessibility

Do not implement a complete doctor/admin platform unless explicitly requested.

---

# 10. V2 DEVELOPMENT ORDER

The recommended development order is:

## Phase 1

Inspect V1 and establish V2 architecture.

## Phase 2

Implement multilingual foundation.

## Phase 3

Design and implement Pregnancy Care.

## Phase 4

Design and implement GPS Healthcare Finder.

## Phase 5

Integrate:

Pregnancy
+
Emergency
+
GPS Healthcare Finder

## Phase 6

Validate AI language synchronization.

## Phase 7

Perform reliability, security and regression testing.

Do not attempt to implement all major V2 systems simultaneously without their foundations.

---

# 11. STITCH + MCP DESIGN-FIRST REQUIREMENT

Stitch is the required design environment for new or substantially changed V2 UI.

When a Stitch MCP integration is available/configured in the development environment, the agent MUST use it for V2 screen design before implementing those screens in Flutter.

The required workflow is:

Requirements
        ↓
Read documentation
        ↓
Inspect existing V1 UI
        ↓
Define screen requirements
        ↓
Design in Stitch using MCP
        ↓
Review Stitch design
        ↓
Validate against V1 UI/UX and V2 requirements
        ↓
Implement approved design in Flutter
        ↓
Run/test Flutter implementation
        ↓
Compare implementation against Stitch design
        ↓
Fix visual/functional differences

Do NOT skip the Stitch design stage for a new V2 screen when the Stitch MCP is available.

---

# 12. STITCH MUST COME BEFORE FLUTTER UI

For every new or substantially redesigned V2 screen:

1. Understand the requirements.
2. Inspect the existing V1 UI/UX system.
3. Create the screen design in Stitch using the configured MCP.
4. Review the design.
5. Ensure the design satisfies the V2 requirements.
6. Ensure the design remains visually consistent with RuralCare.
7. Only then implement the screen in Flutter.

Do not immediately build a Flutter screen and use Stitch afterward merely to document it.

The intended process is:

Stitch → Flutter

not:

Flutter → Stitch.

---

# 13. REUSE V1 DESIGN LANGUAGE IN STITCH

Stitch designs for V2 must be based on the existing RuralCare V1 design language.

Reuse where appropriate:

- Typography
- Color system
- Spacing
- Component style
- Button style
- Card style
- Input style
- Navigation style
- Icon treatment
- Visual hierarchy
- Accessibility patterns

Do not redesign the entire application simply because V2 introduces new functionality.

V2 should feel like the same RuralCare product.

---

# 14. STITCH DESIGN SCOPE

Use Stitch for:

- New V2 screens
- New V2 flows
- Major V2 UI changes
- Pregnancy Care UI
- Healthcare Finder UI
- Emergency UI
- Language selection UI
- Other substantial patient-facing V2 interfaces

Do not create unnecessary Stitch designs for tiny implementation changes such as:

- Minor bug fixes
- Small spacing corrections
- Internal service changes
- Backend changes
- Data-model changes
- Non-visual refactoring

---

# 15. STITCH DESIGN VALIDATION

Before implementing a Stitch design in Flutter, verify:

- Required user flow exists.
- Required actions exist.
- Emergency actions are clearly visible.
- Multilingual requirements are considered.
- Hindi text can fit.
- Bengali text can fit.
- Long AI responses can fit.
- Loading states are considered.
- Empty states are considered.
- Error states are considered.
- Accessibility is considered.
- The design is consistent with V1.
- The design does not introduce unnecessary screens.

---

# 16. STITCH TO FLUTTER FIDELITY

The Flutter implementation should faithfully reproduce the approved Stitch design.

Match where applicable:

- Layout
- Hierarchy
- Spacing
- Typography
- Components
- Buttons
- Cards
- Navigation
- States
- Interaction flow

Do not intentionally create a significantly different Flutter UI after designing the screen in Stitch.

If implementation limitations require a change:

1. Identify the limitation.
2. Choose the smallest reasonable change.
3. Preserve the original design intent.
4. Record significant architectural decisions in `v2.memory.md`.

---

# 17. STITCH IS NOT THE PRODUCTION UI

Stitch is the design stage.

Flutter remains the production application UI.

The agent must not treat a Stitch design as a substitute for:

- Flutter implementation
- Business logic
- Backend integration
- API integration
- Testing
- Accessibility implementation

The final product must be implemented in the project's actual Flutter codebase.

---

# 18. MULTILINGUAL REQUIREMENT

RuralCare V2 MUST support:

English → `en`

Hindi → `hi`

Bengali → `bn`

IMPORTANT:

`bn` = Bengali

`be` = Belarusian

NEVER use `be` as the Bengali locale.

---

# 19. LANGUAGE SELECTION

The patient must be able to select:

- English
- हिन्दी
- বাংলা

The selected language must persist between sessions.

If no language has previously been selected:

1. Detect the device language where appropriate.
2. Map supported languages.
3. Fall back to English if unsupported.

Supported mappings:

en-* → English

hi-* → Hindi

bn-* → Bengali

---

# 20. AI RESPONSE LANGUAGE — MANDATORY

The AI MUST respond according to the user's selected application language.

The selected application language is the authoritative AI response language.

Required:

Selected language = `en`
→ AI responds in English

Selected language = `hi`
→ AI responds in Hindi

Selected language = `bn`
→ AI responds in Bengali

The language used in the user's message does NOT override the selected application language by default.

Example:

Selected application language:
Hindi

User message:
"I have stomach pain."

Required AI response:
Hindi.

---

# 21. AI LANGUAGE SYNCHRONIZATION

The current application locale MUST be passed to every AI request.

Do NOT rely on the AI remembering the language from previous messages.

Conceptually:

User
 ↓
Current locale
 ↓
AI request
 ↓
Explicit language instruction
 ↓
AI
 ↓
Response in selected language

If the user changes:

English → Hindi

the next AI response must be Hindi.

If the user changes:

Hindi → Bengali

the next AI response must be Bengali.

---

# 22. AI CONVERSATION CONTINUITY

Changing the application language must NOT unnecessarily delete the existing conversation.

Example:

Conversation in English
        ↓
User changes to Hindi
        ↓
Conversation context remains
        ↓
New response is in Hindi

Preserve relevant conversation context where the existing architecture supports conversation history.

---

# 23. AI LANGUAGE CONSISTENCY

The AI should:

- Follow the selected language.
- Avoid unnecessary language mixing.
- Use natural language.
- Preserve medical meaning.
- Preserve numbers.
- Preserve units.
- Preserve urgency.
- Preserve important medical terminology where appropriate.

Do not produce unnecessary mixed-language responses.

---

# 24. AI MARKDOWN

AI responses may contain Markdown.

The application must correctly render:

- Headings
- Bullet lists
- Numbered lists
- Bold text
- Paragraphs
- Line breaks

Markdown must work in:

- English
- Hindi
- Bengali

Reuse the existing V1 Markdown renderer if suitable.

Do not create multiple Markdown rendering systems.

---

# 25. AI HEALTHCARE SAFETY

RuralCare AI is a healthcare-support system.

The AI must NOT:

- Claim to be a doctor.
- Claim certainty about diagnosis.
- Pretend to examine a patient.
- Invent medical information.
- Invent hospitals.
- Invent clinics.
- Invent doctors.
- Invent phone numbers.
- Give false reassurance.
- Delay emergency care unnecessarily.

The AI must communicate uncertainty where appropriate.

---

# 26. EMERGENCY PRINCIPLE

Emergency situations have priority over normal conversational behavior.

When a potentially serious situation is identified:

Potential emergency
        ↓
Clear immediate guidance
        ↓
Recommend appropriate medical care
        ↓
Find nearby healthcare
        ↓
Call / Directions

Do not bury emergency instructions beneath long explanations.

---

# 27. EMERGENCY MUST NOT DEPEND ENTIRELY ON AI

Critical emergency functionality must remain usable if the AI is unavailable.

For example:

Emergency
   ↓
Emergency guidance
   ↓
Healthcare Finder

must remain possible without requiring a successful AI response.

AI is an enhancement, not the single point of failure.

---

# 28. PREGNANCY CARE

Pregnancy Care is a dedicated V2 feature.

It must NOT simply be:

"Pregnancy" → generic AI prompt.

It should conceptually contain:

Pregnancy Care
│
├── Pregnancy Profile
├── Pregnancy Dashboard
├── Pregnancy Progress
├── Antenatal Care
├── Nutrition & Wellbeing
├── Symptoms
├── Warning Signs
├── Reminders
├── Pregnancy AI
└── Emergency Care

Follow:

`docs/v2/V2_PREGNANCY_CARE.md`

for detailed requirements.

---

# 29. PREGNANCY SAFETY

Pregnancy information must be treated as healthcare information.

The application must:

- Avoid false reassurance.
- Avoid diagnostic certainty.
- Distinguish routine information from concerning symptoms.
- Clearly identify potential emergencies.
- Encourage appropriate professional care.
- Provide emergency escalation when appropriate.

Pregnancy warning-sign content should be medically reviewed before production release.

---

# 30. PREGNANCY + AI

Pregnancy AI must:

- Understand relevant pregnancy context.
- Follow the selected application language.
- Provide structured responses.
- Avoid unsupported diagnosis.
- Escalate potential emergencies.
- Preserve Markdown formatting.

---

# 31. PREGNANCY + GPS

Pregnancy emergency handling must integrate directly with the Healthcare Finder.

Required flow:

Pregnancy Care
      ↓
Potential Emergency
      ↓
Emergency Guidance
      ↓
Find Nearby Healthcare
      ↓
Nearby Hospitals / Clinics / Doctors
      ↓
Facility Details
      ↓
Call / Directions

The selected language must remain active throughout this flow.

---

# 32. GPS HEALTHCARE FINDER

V2 must allow the patient to find nearby:

- Hospitals
- Clinics
- Doctors

The architecture should allow future expansion to:

- Pharmacies
- Diagnostic centers
- Ambulance services
- Maternal-care facilities

Do not implement future categories unless explicitly requested.

---

# 33. LOCATION PERMISSION

Location permission must only be requested when required.

Do not request GPS permission unnecessarily.

Handle separately:

1. Permission granted
2. Permission denied
3. Permanently denied
4. Location services disabled
5. Location unavailable
6. Low accuracy
7. Location timeout

Each state must have appropriate user guidance.

---

# 34. GPS ARCHITECTURE

Low-level GPS logic must be isolated from UI widgets.

Conceptually:

Healthcare Finder
      ↓
Location Service
      ↓
Current coordinates
      ↓
Healthcare Search Service
      ↓
Healthcare results

Do not place complex GPS logic directly inside screen widgets.

---

# 35. HEALTHCARE DATA INTEGRITY

The Healthcare Finder MUST use legitimate healthcare/location data.

Never fabricate:

- Hospital names
- Clinic names
- Doctor names
- Addresses
- Phone numbers
- Services
- Opening hours
- Emergency capabilities
- Ratings

If information is unavailable, display it as unavailable.

Never make fake healthcare data appear real.

---

# 36. HEALTHCARE PROVIDER ABSTRACTION

The Healthcare Finder must not be tightly coupled to one external provider.

Conceptually:

Flutter UI
   ↓
Healthcare Service
   ↓
Provider Adapter
   ↓
External Provider

Normalize provider responses into internal application models.

Do not spread provider-specific response formats throughout the UI.

---

# 37. FACILITY DETAILS

Where available, a healthcare facility may contain:

- ID
- Name
- Type
- Latitude
- Longitude
- Address
- Phone
- Distance
- Opening information
- Verified services

Unavailable information must remain unavailable.

Do not invent missing values.

---

# 38. DIRECTIONS

The user must be able to get directions from their current location to a selected facility.

Conceptually:

Current location
      ↓
Selected facility
      ↓
Get Directions
      ↓
Supported navigation experience

Navigation provider code must be isolated.

---

# 39. CALL FACILITY

If a valid phone number exists:

Provide a call action.

If no valid phone number exists:

Do not fabricate one.

---

# 40. GPS PRIVACY

The Healthcare Finder does NOT require continuous background GPS tracking.

Do not implement unnecessary background location tracking.

Location should be accessed when needed for the requested healthcare functionality.

Do not unnecessarily store precise location history.

---

# 41. RURAL CONNECTIVITY

RuralCare must account for unreliable connectivity.

Handle:

- Slow internet
- No internet
- API timeout
- Backend failure
- AI failure
- GPS failure
- Healthcare provider failure

Do not leave the application indefinitely stuck in a loading state.

---

# 42. OFFLINE PRINCIPLE

Real-time healthcare discovery may require internet connectivity.

When offline:

- Explain that real-time discovery is unavailable.
- Provide retry functionality.
- Preserve locally available critical information.
- Do not present stale data as current.

Critical emergency guidance should be available locally where practical.

---

# 43. UI/UX

V2 must remain visually consistent with the V1 RuralCare design system.

Reuse:

- Typography
- Colors
- Spacing
- Buttons
- Cards
- Forms
- Navigation
- Components

unless V2 explicitly requires a change.

New V2 screens must be designed in Stitch before Flutter implementation when the Stitch MCP is available.

Do not create a separate V2 UI/UX documentation file.

Reuse:

`docs/v1/uiUx.md`

as the common design foundation.

---

# 44. MULTILINGUAL UI

All major patient-facing UI must support:

- English
- Hindi
- Bengali

Avoid hard-coded user-facing strings.

The UI must tolerate different text lengths.

Test for:

- Text overflow
- Text clipping
- Long translations
- Devanagari rendering
- Bengali rendering
- Unicode issues

---

# 45. ACCESSIBILITY

Patient-facing screens should prioritize:

- Readable text
- Large touch targets
- Clear labels
- Simple language
- Strong visual hierarchy
- Clear emergency actions
- Localized accessibility labels
- Responsive layouts

Icons must not be the only way to communicate important actions.

---

# 46. ERROR STATES

Every major feature must have appropriate:

- Loading state
- Success state
- Empty state
- Error state
- Retry state

Where relevant also provide:

- Permission state
- Offline state
- Unavailable state

Never leave users with:

- Blank screens
- Infinite loading
- Unclear errors
- Silent failures

These states must also be considered during Stitch design for new V2 screens.

---

# 47. DEPENDENCY DISCIPLINE

Before adding a package:

1. Check whether Flutter/Dart already supports the requirement.
2. Check whether an existing dependency supports it.
3. Check whether an existing internal service can be extended.
4. Add a new dependency only when justified.

Do not add packages simply for convenience.

---

# 48. SECURITY

Never commit or expose:

- API secrets
- Database credentials
- Firebase private keys
- Service-account credentials
- Backend secrets
- Private tokens

Never place private credentials in Markdown documentation.

Do not expose server-side secrets through Flutter client code.

Reuse the existing V1 security architecture where appropriate.

---

# 49. HEALTHCARE DATA PRIVACY

Sensitive patient information must be protected.

This includes:

- Pregnancy information
- Health information
- Location-related information

The application must:

- Collect only necessary information.
- Secure data in transit.
- Secure data at rest where appropriate.
- Avoid unnecessary logging.
- Avoid exposing sensitive information in errors.
- Avoid unnecessary location storage.
- Never commit patient data to Git.

---

# 50. NO FAKE FUNCTIONALITY

The following are NOT considered completed functionality:

- Fake GPS
- Fake hospital results
- Fake doctors
- Fake clinics
- Hard-coded production healthcare data
- Simulated AI responses
- Placeholder API responses presented as real
- Static data presented as real-time data

Mock data may be used during development/testing only if clearly isolated from production behavior.

---

# 51. MVP DISCIPLINE

Do NOT automatically add unrelated features.

Do NOT add without explicit requirements:

- Payment systems
- Social networking
- Doctor marketplace
- Hospital management
- Full appointment marketplace
- Admin dashboards
- Advanced analytics
- Unrequested telemedicine systems
- Unrequested medical-record systems

Additional functionality requires explicit approval or a necessary technical dependency.

---

# 52. CODE QUALITY

Prefer:

- Clear naming
- Small focused classes
- Reusable services
- Testable logic
- Separation of UI and business logic
- Strong typing
- Clear error handling
- Minimal duplication

Avoid:

- Giant widgets
- Hard-coded business logic in UI
- Duplicate services
- Duplicate models
- Unnecessary abstraction
- Dead code
- Unused dependencies
- Temporary hacks left in production

---

# 53. ARCHITECTURAL CHANGES

Do not perform large architectural refactors without necessity.

Before a major refactor:

1. Understand the existing architecture.
2. Identify the exact problem.
3. Determine whether a smaller change solves it.
4. Consider V1 compatibility.
5. Consider V2 requirements.
6. Consider regression risk.
7. Document significant decisions in `v2.memory.md`.

---

# 54. DEVELOPMENT WORKFLOW

For every significant V2 feature:

1. Read relevant documentation.
2. Inspect existing implementation.
3. Identify reusable V1 systems.
4. Define requirements.
5. Determine whether UI changes are required.
6. If a new/substantially changed screen is required, design it in Stitch using MCP.
7. Review the Stitch design.
8. Validate design against V1 UI/UX and V2 requirements.
9. Implement approved design in Flutter.
10. Integrate business logic.
11. Integrate backend/API functionality.
12. Test.
13. Fix errors.
14. Compare Flutter UI against Stitch.
15. Check V1 regressions.
16. Update `v2progress.md`.
17. Update `v2.memory.md` when important decisions were made.

Do not skip codebase inspection.

Do not skip Stitch for new V2 screens when the MCP integration is available.

---

# 55. STITCH DESIGN REVIEW BEFORE IMPLEMENTATION

Before converting a Stitch design into Flutter, verify:

- The screen serves a defined requirement.
- No unnecessary screen has been introduced.
- Navigation is consistent with V1.
- Emergency actions are obvious.
- Language selection is considered.
- Hindi and Bengali text fit.
- AI response areas support long content.
- Loading/error/empty states are defined.
- Accessibility is considered.
- The design does not duplicate an existing V1 screen unnecessarily.

---

# 56. V2 PROGRESS TRACKER

The authoritative V2 progress file is:

`docs/v2/v2progress.md`

Use:

[ ] Not Started
[~] In Progress
[x] Completed
[!] Blocked
[-] Not Required

Update it after meaningful development milestones.

Do not mark a feature `[x]` merely because its UI exists.

A feature is complete only when intended functionality has been implemented and reasonably tested.

---

# 57. V2 MEMORY

The authoritative V2 memory file is:

`docs/v2/v2.memory.md`

Use it for:

- Architectural decisions
- Important corrections
- Provider decisions
- Constraints
- Lessons learned
- Implementation rules
- Decisions that must persist across sessions

Do not use it as a replacement for `v2progress.md`.

---

# 58. V1 PROGRESS AND MEMORY

For V1 historical/project state use:

`docs/v1/v1progress.md`

and:

`docs/v1/v1memory.md`

Do not overwrite V1 historical information merely to simplify V2.

---

# 59. SESSION STARTUP

At the beginning of every significant development session:

1. Read `docs/agents.md`.
2. Read relevant V1 documentation.
3. Read relevant V2 documentation.
4. Read `docs/v2/v2progress.md`.
5. Read `docs/v2/v2.memory.md`.
6. Inspect the current codebase.
7. Determine what is actually implemented.
8. Continue from the existing implementation.

Do not assume previous work is incomplete without checking.

Do not rebuild existing functionality simply because another AI session created it.

---

# 60. SESSION COMPLETION

At the end of every meaningful development session:

1. Update `docs/v2/v2progress.md`.
2. Record important decisions in `docs/v2/v2.memory.md`.
3. Record blockers.
4. Record known issues.
5. Record the next recommended task.
6. Ensure documentation reflects the actual implementation.

Never mark unfinished work as complete.

---

# 61. CONFLICT RESOLUTION

When documentation conflicts:

1. Follow the newest explicit requirement.
2. Preserve V1 behavior unless V2 explicitly changes it.
3. Prefer the safer implementation for healthcare functionality.
4. Avoid unnecessary duplication.
5. Record the final decision in `v2.memory.md`.

If a conflict cannot be safely resolved, do not make a destructive change based on assumptions.

---

# 62. TESTING

Every major feature must be tested before being marked complete.

Testing must include, where relevant:

- Functional testing
- UI testing
- Localization testing
- AI testing
- Error handling
- Network failure
- Security
- Regression testing

---

# 63. MULTILINGUAL TESTING

Test:

English
Hindi
Bengali

Verify:

- UI text
- Navigation
- Buttons
- Error messages
- Pregnancy content
- Emergency messages
- Healthcare Finder
- AI responses
- Markdown
- Unicode rendering
- Long translations
- Text overflow

---

# 64. AI TESTING

Test at minimum:

1. English selected + English prompt.
2. English selected + Hindi prompt.
3. English selected + Bengali prompt.
4. Hindi selected + English prompt.
5. Hindi selected + Hindi prompt.
6. Hindi selected + Bengali prompt.
7. Bengali selected + English prompt.
8. Bengali selected + Hindi prompt.
9. Bengali selected + Bengali prompt.

Expected result:

The AI responds in the selected application language.

Also test:

- Language switching
- Conversation continuity
- AI failure
- AI timeout
- Malformed AI response
- Markdown rendering
- Emergency prompts
- Pregnancy prompts

---

# 65. GPS TESTING

Test:

- Permission granted
- Permission denied
- Permanently denied
- GPS disabled
- Location unavailable
- Low accuracy
- Timeout
- No network
- Slow network
- Provider failure
- No results
- Hospitals
- Clinics
- Doctors
- Facility details
- Call
- Directions

---

# 66. PREGNANCY TESTING

Test:

- Pregnancy profile
- Due date
- Pregnancy week
- Trimester
- Dashboard
- Guidance
- Symptoms
- Warning signs
- Reminders
- Pregnancy AI
- Emergency escalation
- GPS integration
- English
- Hindi
- Bengali

---

# 67. V1 REGRESSION TESTING

Before V2 is considered complete, verify V1 still works.

At minimum test:

- Authentication
- Patient profile
- Existing AI
- Navigation
- Backend communication
- Database functionality
- Existing patient features

Any unintended V1 regression must be fixed before release.

---

# 68. HEALTHCARE SAFETY REVIEW

Before release, review:

- AI responses
- Pregnancy content
- Warning signs
- Emergency messaging
- Medical translations
- Healthcare facility data
- GPS behavior
- Location privacy
- Patient data privacy
- API security

AI-generated medical content must not be treated as automatically clinically validated.

Pregnancy and emergency content should receive qualified medical review before production use.

---

# 69. NO UNNECESSARY SCREENS

The agent must not create screens simply to make the project appear more complete.

Every new screen must have:

1. A defined requirement.
2. A clear user purpose.
3. A defined navigation path.
4. A reason it cannot be handled by an existing screen.

Before creating a new screen, inspect existing screens.

If the requirement can be handled by extending an existing screen, prefer extending it.

This rule is especially important during Stitch design.

---

# 70. NO UNNECESSARY DOCUMENTATION

Do not create new `.md` files simply to document every feature.

The current documentation structure is intentional.

Use existing files:

V1:
`docs/v1/`

V2:
`docs/v2/`

Global:
`docs/agents.md`

Only create another documentation file if explicitly requested.

---

# 71. FINAL V2 GOAL

RuralCare V2 should provide:

Patient
   ↓
Selects preferred language
   ↓
Uses RuralCare AI in that language
   ↓
Accesses Pregnancy Care when needed
   ↓
Receives structured and safe support
   ↓
Potential emergency identified
   ↓
Nearby healthcare located using GPS
   ↓
Hospital / Clinic / Doctor selected
   ↓
Facility information
   ↓
Call / Directions

The three core V2 capabilities are:

LANGUAGE ACCESSIBILITY
        +
PREGNANCY & MATERNAL CARE
        +
LOCATION-AWARE HEALTHCARE ACCESS

The design and development process is:

Requirements
      ↓
Documentation
      ↓
V1 inspection
      ↓
V2 architecture
      ↓
Stitch design via MCP
      ↓
Design validation
      ↓
Flutter implementation
      ↓
Backend/API integration
      ↓
Testing
      ↓
Regression testing
      ↓
Progress + memory update

The agent must keep the implementation focused on this goal while:

- Preserving V1 stability
- Reusing existing architecture
- Avoiding unnecessary duplication
- Avoiding unnecessary screens
- Avoiding unnecessary documentation
- Protecting patient data
- Maintaining healthcare safety
- Ensuring AI language synchronization
- Ensuring reliable emergency access
- Ensuring multilingual accessibility
- Ensuring GPS healthcare discovery