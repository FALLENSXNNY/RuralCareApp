# RuralCare V2 — Multilingual Specification

## 1. Purpose

RuralCare V2 must support three languages across the patient application:

* English
* Hindi
* Bengali

The multilingual system must be implemented as a proper application-wide localization architecture, not as manually translated text inside individual screens.

The system must also integrate with the RuralCare AI so that AI responses follow the user's selected language.

---

# 2. Supported Languages

| Language | Locale Code | Display Name |
| -------- | ----------- | ------------ |
| English  | `en`        | English      |
| Hindi    | `hi`        | हिन्दी       |
| Bengali  | `bn`        | বাংলা        |

Important:

Use `bn` for Bengali.

Do not use `be`.

`be` represents Belarusian, while `bn` represents Bengali.

---

# 3. Language Selection

The patient must be able to select the application language.

The language selector should display:

```text
English
हिन्दी
বাংলা
```

The selected language must be visually identifiable.

Changing the language must update the application's localized interface without requiring the user to create a new account.

---

# 4. Initial Language

When the application is launched for the first time:

1. Check whether the user has previously selected a language.
2. If a saved language exists, use it.
3. Otherwise, detect the device language when appropriate.
4. If the device language is not supported, default to English.

Supported automatic mappings:

```text
en-* → English
hi-* → Hindi
bn-* → Bengali
```

Unsupported languages:

```text
→ English fallback
```

---

# 5. Language Persistence

The selected language must persist between application sessions.

Example:

```text
User selects Bengali
        ↓
Application stores `bn`
        ↓
User closes application
        ↓
User opens application again
        ↓
Application starts in Bengali
```

The exact persistence mechanism must follow the existing V1 architecture where appropriate.

Do not introduce a second persistence system if V1 already has a suitable application settings/preferences service.

---

# 6. Flutter Localization Architecture

Antigravity must inspect the existing Flutter project's localization architecture before implementation.

If V1 already has localization infrastructure, extend it.

If V1 does not have localization infrastructure, implement Flutter's standard localization approach.

The architecture should conceptually provide:

```text
Localization
│
├── English resources
├── Hindi resources
└── Bengali resources
```

All user-facing strings must resolve through the localization layer.

---

# 7. String Management

Do not write user-facing strings directly inside widgets when the text requires localization.

Avoid:

```dart
Text("Find Nearby Hospitals")
```

Prefer the project's localization mechanism, conceptually:

```dart
Text(l10n.findNearbyHospitals)
```

The exact implementation must match the project's chosen localization framework.

---

# 8. Translation Keys

Translation keys must be stable and descriptive.

Good:

```text
home_title
nearby_healthcare
find_hospitals
find_clinics
find_doctors
emergency_help
pregnancy_care
select_language
```

Avoid:

```text
text1
text2
button3
screen_string_7
```

Keys should describe their semantic purpose rather than their visual position.

---

# 9. Required Translation Coverage

The following areas must be localized.

## Application

* App navigation
* Home screen
* Profile
* Settings
* Login/signup
* Forms
* Buttons
* Dialogs
* Error messages
* Loading messages
* Empty states

## AI

* AI interface
* Input guidance
* Suggested questions
* Error messages
* Safety messages
* Emergency messages

## Pregnancy

* Pregnancy dashboard
* Pregnancy stages
* Pregnancy guidance
* Symptoms
* Warning signs
* Emergency guidance
* Reminders
* Actions

## Healthcare Finder

* Hospitals
* Clinics
* Doctors
* Search
* Distance
* Directions
* Call
* Location permission
* GPS errors
* No-result states

---

# 10. Translation Quality

Translations must be natural and understandable to ordinary users.

Do not perform literal word-for-word translation when it produces unnatural language.

The target audience may include users with limited medical or technical literacy.

Therefore:

* Prefer simple language.
* Avoid unnecessary medical jargon.
* Explain unavoidable medical terminology.
* Keep emergency instructions direct.
* Preserve the meaning of the English source text.

---

# 11. Medical Translation Safety

Medical terminology must be translated carefully.

The translated version must not change:

* Severity
* Dosage information
* Timing
* Warning signs
* Emergency recommendations
* Contraindications
* Instructions to seek care

If a medical term has no clear everyday equivalent, use a commonly understood medical term and provide a simple explanation where appropriate.

Do not invent translations for medical terminology.

---

# 12. AI Language Architecture

The AI layer must receive the user's selected language as explicit context.

Conceptually:

```text
User
 ↓
Selected Language
 ↓
AI Request
 ↓
Language Instruction
 ↓
AI
 ↓
Response in Selected Language
```

Example:

```text
selectedLanguage = "hi"
```

The AI request should explicitly communicate that the response must be in Hindi.

Likewise:

```text
selectedLanguage = "bn"
```

must result in Bengali.

---

# 13. AI Language Rules

The AI must follow these rules:

1. Respond in the currently selected application language by default.
2. Do not randomly switch languages.
3. Do not mix English, Hindi, and Bengali unnecessarily.
4. Preserve important medical terms when translation could reduce clarity.
5. Keep emergency instructions clear and unambiguous.
6. Follow the user's explicit request if they intentionally ask for another supported language.
7. Do not translate structured data incorrectly.
8. Preserve numerical values and units accurately.

# 13A. Mandatory AI Response Language Synchronization

The selected application language is the authoritative language for AI responses.

The AI response language must always be determined by the user's currently selected application language.

## Required Behavior

```text
User selects language
        ↓
Application stores selected locale
        ↓
AI request reads selected locale
        ↓
Locale is explicitly passed to AI layer
        ↓
AI receives mandatory response-language instruction
        ↓
AI responds in that language
```

The AI must NOT independently decide the response language based only on the language of the user's message.

---

## Language Mapping

```text
en → English
hi → Hindi
bn → Bengali
```

Therefore:

| Selected App Language | User Input Language | Required AI Response |
| --------------------- | ------------------- | -------------------- |
| English               | English             | English              |
| English               | Hindi               | English              |
| English               | Bengali             | English              |
| Hindi                 | English             | Hindi                |
| Hindi                 | Hindi               | Hindi                |
| Hindi                 | Bengali             | Hindi                |
| Bengali               | English             | Bengali              |
| Bengali               | Hindi               | Bengali              |
| Bengali               | Bengali             | Bengali              |

The selected application language takes priority over the input language unless the user explicitly requests a different supported response language.

---

## AI Request Contract

Every AI request must contain the current application locale.

Conceptually:

```text
AI Request
{
    userMessage: "...",
    language: "hi"
}
```

or:

```text
AI Request
{
    userMessage: "...",
    language: "bn"
}
```

The exact request structure must follow the existing V1 backend/API architecture.

Do not create a second AI communication system if V1 already provides one.

---

## Mandatory System Instruction

The AI layer must receive an explicit instruction equivalent to:

```text
Respond in the user's selected application language.
The selected language is authoritative.

Selected language:
{LANGUAGE}

Do not switch languages based on the language of the user's message.

Use clear, natural, easy-to-understand language appropriate for the patient.

Preserve medical accuracy, urgency, numbers, units, and important medical terminology.

If the selected language is Hindi, respond in Hindi.
If the selected language is Bengali, respond in Bengali.
If the selected language is English, respond in English.
```

The exact wording may be adapted to the existing AI architecture, but the behavior must remain mandatory.

---

## Language Must Be Passed on Every Request

Do not assume that the AI remembers the user's selected language from a previous request.

The current locale must be available to every AI request.

```text
Request 1 → language = hi
Request 2 → language = hi
Request 3 → language = hi
```

If the user changes the language:

```text
English
   ↓
User selects Hindi
   ↓
Next AI request → language = hi
   ↓
AI response → Hindi
```

The change must take effect immediately for subsequent AI interactions.

---

## Conversation Continuity

Changing the application language must not unintentionally delete or corrupt the existing conversation.

Example:

```text
Conversation:
User: "I have stomach pain."
AI: English response

User changes application language → Hindi

User: "What should I do now?"
AI: Hindi response
```

The conversation context may remain intact while the response language changes.

---

## AI Language Validation

The application should validate the AI response language when practical.

If:

```text
selectedLanguage = hi
```

but the AI unexpectedly returns a predominantly English response, the application should have a controlled fallback/retry strategy where technically appropriate.

The system must never silently present a clearly incorrect-language response as if localization succeeded.

Do not create an infinite retry loop.

---

## Mixed-Language Responses

The AI should avoid unnecessary language mixing.

For example, when Hindi is selected, do not produce:

```text
आपको doctor से मिलना चाहिए क्योंकि you may need further evaluation.
```

Prefer natural Hindi while retaining medically important terms when necessary.

Similarly, Bengali responses should not unnecessarily alternate between Bengali and English.

Some commonly understood medical or technical terms may remain in English when translating them would reduce clarity.

---

## Medical Safety Across Languages

Translation must never alter the clinical meaning of the AI response.

The following must remain accurate across English, Hindi, and Bengali:

* Emergency warnings
* Severity
* Timing
* Dosage information when applicable
* Units
* Pregnancy warning signs
* Instructions to seek medical care
* Contraindications
* Safety warnings

If a response contains an emergency recommendation, that recommendation must be clearly understandable in the selected language.

---

## AI Markdown Across Languages

AI responses must preserve the same structural formatting regardless of language.

For example:

```markdown
## Warning Signs

- Severe abdominal pain
- Heavy bleeding
- Difficulty breathing

**Seek immediate medical care.**
```

When Hindi or Bengali is selected, the translated response must retain:

* Headings
* Bullet points
* Numbered lists
* Bold text
* Paragraph separation
* Other supported Markdown structures

The Flutter UI must render the resulting Markdown correctly.

---

## Pregnancy AI

The same language synchronization must apply to the pregnancy-care AI.

Example:

```text
Selected language = Hindi
        ↓
Pregnancy question
        ↓
Pregnancy AI
        ↓
Hindi response
```

and:

```text
Selected language = Bengali
        ↓
Pregnancy question
        ↓
Pregnancy AI
        ↓
Bengali response
```

Pregnancy emergency guidance must follow the selected language as well.

---

## Emergency AI

During an emergency:

```text
Selected language
        ↓
Emergency AI response
        ↓
Same selected language
```

The application must not switch to English simply because the situation is classified as an emergency.

However, critical emergency UI messages must also be available locally so that an emergency instruction does not depend entirely on an AI response.

---

## Definition of Done — AI Language

The AI language implementation is complete only when:

* [ ] Selected `en` produces English AI responses.
* [ ] Selected `hi` produces Hindi AI responses.
* [ ] Selected `bn` produces Bengali AI responses.
* [ ] AI response language is independent of the input language.
* [ ] Current locale is sent with every AI request.
* [ ] Changing language affects the next AI response.
* [ ] Existing conversation context is preserved when language changes.
* [ ] AI does not unnecessarily mix languages.
* [ ] Medical meaning is preserved across languages.
* [ ] Emergency responses follow the selected language.
* [ ] Pregnancy AI responses follow the selected language.
* [ ] AI Markdown renders correctly in all supported languages.
* [ ] Unexpected language mismatch is handled safely.


---

# 14. AI Response Examples

### English

```text
Please contact a healthcare professional if your symptoms become severe.
```

### Hindi

```text
यदि आपके लक्षण गंभीर हो जाते हैं, तो कृपया किसी स्वास्थ्य पेशेवर से संपर्क करें।
```

### Bengali

```text
আপনার উপসর্গ গুরুতর হলে একজন স্বাস্থ্যসেবা পেশাদারের সঙ্গে যোগাযোগ করুন।
```

The actual production translations must be reviewed for medical accuracy and natural language quality.

---

# 15. Markdown Preservation in AI Responses

AI responses may contain Markdown.

The localization system must not break Markdown formatting.

For example, an AI response may contain:

```markdown
## Warning Signs

- Severe pain
- Heavy bleeding
- Difficulty breathing

**Seek immediate medical care.**
```

The application must render this correctly in all supported languages.

Do not manually manipulate translated AI Markdown in a way that breaks:

* Headings
* Bullet lists
* Numbered lists
* Bold text
* Links
* Line breaks

---

# 16. Right-to-Left Consideration

English, Hindi, and Bengali are all left-to-right languages.

The V2 multilingual implementation therefore does not currently require RTL layout support.

However, localization architecture should not make future RTL support impossible.

---

# 17. Text Expansion

The UI must tolerate differences in text length between languages.

Do not assume that an English string will have the same width in Hindi or Bengali.

Avoid:

* Fixed-width text containers
* Hard-coded text positions
* Excessively small buttons
* Text clipping
* Overflowing labels

Use responsive layouts.

---

# 18. Font and Unicode Support

The application must correctly render:

* English characters
* Devanagari characters
* Bengali characters

Test for:

```text
English
Hindi: हिन्दी
Bengali: বাংলা
```

No language should display:

* Missing glyphs
* Boxes
* Incorrect character rendering
* Broken punctuation
* Unexpected replacement characters

Use a font strategy compatible with all supported scripts.

---

# 19. Date, Number and Unit Formatting

Localized interfaces must correctly handle:

* Dates
* Times
* Numbers
* Distances
* Pregnancy weeks
* Other displayed measurements

Do not manually concatenate localized strings with numbers when a proper localization formatter can be used.

Example concept:

```text
Week 24
24 सप्ताह
২৪ সপ্তাহ
```

The exact localized presentation should follow the selected locale and product design.

---

# 20. Emergency Language Requirements

Emergency communication requires special attention.

Emergency messages must:

* Use simple language.
* Avoid unnecessary explanation.
* Clearly communicate urgency.
* Clearly state the recommended action.
* Remain understandable even if the AI service is unavailable.

The application must have locally available emergency UI strings for the supported languages.

Emergency guidance must not depend entirely on real-time AI translation.

---

# 21. Location Feature Localization

Healthcare finder text must be localized.

Examples include:

```text
Nearby Hospitals
Nearby Clinics
Nearby Doctors
Get Directions
Call
Current Location
Location Permission Required
Unable to determine your location
No healthcare facilities found
```

Distance values should use appropriate locale-aware formatting where applicable.

Facility names and official addresses should generally remain as provided by the healthcare/location data source unless there is a verified localized representation.

Do not translate proper names incorrectly.

---

# 22. Language Selection in Emergency Situations

If the user has already selected a language:

```text
Emergency flow
      ↓
Use selected language
```

Do not unexpectedly switch to English during an emergency.

If the application is unable to load a remote translation resource, use the locally bundled translation resources.

---

# 23. Missing Translation Handling

There must be no blank UI text because of a missing translation.

If a translation key is unavailable:

```text
Selected language
      ↓
Missing translation
      ↓
Fallback to English
```

Missing translations must also be identifiable during development/testing.

Do not silently ship large sets of missing translations.

---

# 24. Translation File Organization

The exact directory structure must follow the existing project conventions.

Conceptually:

```text
localization/
│
├── en
├── hi
└── bn
```

Do not create multiple competing localization systems.

There must be one clear source of truth for application translations.

---

# 25. Testing Requirements

Every major V2 screen must be tested in all three languages.

Minimum test matrix:

| Feature           | English | Hindi | Bengali |
| ----------------- | ------: | ----: | ------: |
| Onboarding        |       ✓ |     ✓ |       ✓ |
| Home              |       ✓ |     ✓ |       ✓ |
| AI                |       ✓ |     ✓ |       ✓ |
| Pregnancy         |       ✓ |     ✓ |       ✓ |
| Emergency         |       ✓ |     ✓ |       ✓ |
| Healthcare Finder |       ✓ |     ✓ |       ✓ |
| Settings          |       ✓ |     ✓ |       ✓ |

Test for:

* Text overflow
* Clipping
* Incorrect translations
* Missing translations
* Broken Markdown
* Incorrect numbers
* Incorrect units
* Incorrect medical meaning
* Navigation labels
* Error messages

---

# 26. Definition of Done

The multilingual system is complete only when:

* [ ] English is fully supported.
* [ ] Hindi is fully supported.
* [ ] Bengali is fully supported.
* [ ] Bengali uses locale code `bn`.
* [ ] Language selection works.
* [ ] Selected language persists.
* [ ] Device language fallback works.
* [ ] Application strings are localized.
* [ ] Pregnancy content is localized.
* [ ] Emergency messages are localized.
* [ ] Healthcare finder is localized.
* [ ] AI follows the selected language.
* [ ] AI Markdown renders correctly in all languages.
* [ ] Hindi text renders correctly.
* [ ] Bengali text renders correctly.
* [ ] No major UI overflow occurs because of translation.
* [ ] Missing translations have a safe fallback.
* [ ] Emergency instructions remain available without relying entirely on AI.

---

# 27. Implementation Rule for Antigravity

Before implementing multilingual support:

1. Read `AGENTS.md`.
2. Read `V2_ARCHITECTURE.md`.
3. Inspect the existing V1 localization implementation, if any.
4. Inspect the existing Flutter dependency structure.
5. Reuse compatible V1 localization infrastructure.
6. Do not introduce unnecessary packages.
7. Implement the localization foundation before translating individual V2 screens.
8. Implement English first as the source language.
9. Add Hindi.
10. Add Bengali.
11. Integrate the selected locale with the AI service.
12. Test every major V2 screen in all three languages.

Do not proceed to pregnancy-specific UI implementation until the localization foundation is stable enough to support the new screens.
