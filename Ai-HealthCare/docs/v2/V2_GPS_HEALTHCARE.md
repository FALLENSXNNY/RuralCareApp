# RuralCare V2 — GPS Healthcare Finder Specification

## 1. Purpose

RuralCare V2 must provide a location-aware healthcare discovery feature that helps patients find nearby:

* Hospitals
* Clinics
* Doctors

The feature must use the patient's current location when permission is granted and present useful healthcare facilities in a simple, patient-friendly interface.

The Healthcare Finder must also integrate directly with Pregnancy Care and emergency workflows.

---

# 2. Core User Goal

The primary goal is:

```text
Patient needs healthcare
        ↓
RuralCare determines current location
        ↓
Find nearby healthcare facilities
        ↓
Patient selects a facility
        ↓
View facility information
        ↓
Call / Get Directions
```

The experience must minimize unnecessary steps.

---

# 3. Healthcare Categories

The initial V2 implementation must support:

```text
🏥 Hospitals
🏨 Clinics
👨‍⚕️ Doctors
```

The architecture should allow future categories such as:

* Pharmacies
* Diagnostic centers
* Ambulance services
* Maternal-care facilities

to be added without rewriting the Healthcare Finder.

---

# 4. Location Permission

Location permission must be requested only when required.

The application must not request GPS permission unnecessarily during onboarding or unrelated screens.

Recommended flow:

```text
User opens Healthcare Finder
        ↓
Check location permission
        ↓
Permission available?
       / \
     YES  NO
      ↓    ↓
Get GPS   Explain need
location  for permission
```

---

# 5. Permission States

The application must explicitly handle:

### Permission Granted

Proceed to obtain the current location.

### Permission Denied

Explain that location access is required to find nearby healthcare facilities.

Provide a clear retry/request-permission action.

### Permission Permanently Denied

Explain that location access must be enabled from device settings.

Provide an appropriate action to open system settings where supported.

### Location Services Disabled

Inform the user that device location services need to be enabled.

Do not repeatedly request permission when the actual problem is disabled location services.

---

# 6. Location Acquisition

The location service must obtain the user's current latitude and longitude when permission is available.

The architecture should isolate location functionality behind a dedicated service.

Conceptually:

```text
Healthcare Finder
       ↓
Location Service
       ↓
Current Position
       ↓
Healthcare Search Service
```

UI components must not contain low-level GPS implementation.

---

# 7. Location Accuracy

The application should request an appropriate level of location accuracy for healthcare discovery.

The application must handle inaccurate or unavailable location results gracefully.

Possible states:

```text
Accurate location
↓
Search nearby facilities

Low accuracy
↓
Inform user / retry if necessary

Location unavailable
↓
Show error + retry
```

Do not present an inaccurate location as exact.

---

# 8. Search Radius

Healthcare discovery should use a configurable search radius.

The initial radius should be chosen based on practical rural healthcare availability and the capabilities of the selected healthcare/location provider.

The implementation must allow the radius to be changed later without redesigning the feature.

Example conceptual behavior:

```text
Current location
       ↓
Search nearby facilities
       ↓
No suitable results?
       ↓
Expand search radius
       ↓
Search again
```

Do not automatically search indefinitely.

---

# 9. Healthcare Data Provider

The application must use a legitimate healthcare/location data source.

Antigravity must inspect the existing V1/V2 backend architecture before selecting or integrating a provider.

The provider must support, where possible:

* Hospitals
* Clinics
* Doctors
* Geographic coordinates
* Names
* Addresses
* Phone numbers where available

Do not invent healthcare facility data.

Do not hard-code fake hospitals, clinics, or doctors as production data.

---

# 10. API Key and Credential Security

If the selected location provider requires an API key:

* Do not expose private server-side credentials in the Flutter application.
* Do not commit secrets to GitHub.
* Reuse the existing secure V1 secret-management approach where applicable.
* Keep sensitive credentials on the backend when required.
* Use environment configuration appropriately.

Public client-side map keys, if technically required by a provider, must still follow that provider's security restrictions and allowed-domain/package restrictions.

---

# 11. Healthcare Search Architecture

Conceptually:

```text
Flutter App
    ↓
Healthcare Finder
    ↓
Location Service
    ↓
Current Coordinates
    ↓
Backend / Healthcare Search Service
    ↓
Healthcare Data Provider
    ↓
Normalized Healthcare Results
    ↓
Flutter UI
```

The Flutter UI should not depend directly on provider-specific response formats.

Normalize healthcare data into the application's own model.

---

# 12. Healthcare Facility Model

The application should use a normalized facility model.

Conceptually:

```text
HealthcareFacility
│
├── id
├── name
├── type
├── latitude
├── longitude
├── address
├── phone
├── distance
├── openingStatus
└── availableInformation
```

Fields that are unavailable must remain unavailable.

Do not fabricate missing values.

The exact model must match the project's existing architecture.

---

# 13. Search Screen

The Healthcare Finder should provide a clear search interface.

Recommended conceptual layout:

```text
Nearby Healthcare

[ Hospitals ] [ Clinics ] [ Doctors ]

Your Location
Current location / location status

Nearby Results

Hospital A
2.4 km
Address
[Directions]

Clinic B
3.1 km
Address
[Directions]
```

The final UI must follow the established RuralCare design system.

---

# 14. Map View

If a map is included, it should provide visual context for nearby facilities.

Conceptually:

```text
       MAP
  📍 Patient

       🏥
    Hospital

            🏨
           Clinic
```

The map must not be the only way to access healthcare results.

A list view must also be available because some users may have:

* Small screens
* Poor map performance
* Limited connectivity
* Difficulty interpreting maps

---

# 15. Facility List

Results should be ordered in a useful way.

The default ordering should generally prioritize:

1. Relevance
2. Distance
3. Healthcare type

The exact ranking may depend on the healthcare provider and available metadata.

Do not claim that the nearest facility is necessarily the best facility.

---

# 16. Distance Display

Distance must be calculated or obtained reliably.

Example:

```text
1.2 km
850 m
5.6 km
```

Use locale-aware number formatting where appropriate.

Distance must not be fabricated.

If distance cannot be determined reliably, do not display a misleading exact distance.

---

# 17. Facility Details

Selecting a healthcare facility should open a details screen.

Conceptually:

```text
Hospital Name

Hospital

Distance: 2.4 km

Address
...

Phone
...

Services
...

[Call]
[Get Directions]
```

Only verified/available information should be displayed.

Do not invent:

* Services
* Doctors
* Emergency facilities
* Opening hours
* Phone numbers
* Ratings
* Reviews

---

# 18. Calling a Facility

Where a valid phone number is available, provide a call action.

Example:

```text
[Call Hospital]
```

The application should use the device's supported phone functionality.

If no valid phone number is available:

```text
Call unavailable
```

Do not display a fabricated number.

---

# 19. Directions

The user must be able to request directions to a selected healthcare facility.

Conceptual flow:

```text
Current Location
        ↓
Selected Facility
        ↓
Get Directions
        ↓
Supported navigation experience
```

The exact navigation provider must be determined during implementation.

The navigation integration must be isolated so that the provider can be changed later.

---

# 20. External Navigation

If directions open an external mapping/navigation application:

* Confirm that the target coordinates are valid.
* Use the facility's coordinates where available.
* Use the current location as the origin where supported.
* Handle the case where no compatible navigation application is available.

Do not silently fail.

---

# 21. Search Filters

The initial version should keep filtering simple.

Minimum filters:

```text
Hospitals
Clinics
Doctors
```

Additional filters may be added later.

Do not overload the MVP with excessive filtering options.

---

# 22. Search States

The Healthcare Finder must support:

### Loading

```text
Finding nearby healthcare...
```

### Results

Display available healthcare facilities.

### No Results

```text
No nearby healthcare facilities found.
Try expanding your search.
```

### Location Error

```text
Unable to determine your location.
Please check location services and try again.
```

### Network Error

```text
Unable to search for healthcare facilities.
Please check your internet connection and try again.
```

### Provider Error

Show a user-friendly error without exposing internal API/provider details.

---

# 23. Poor Connectivity

RuralCare targets rural environments where network connectivity may be unreliable.

The Healthcare Finder must gracefully handle:

* Slow network
* Temporary network failure
* API timeout
* Provider failure
* GPS failure

The UI must not freeze while waiting indefinitely for results.

Use appropriate:

* Timeouts
* Loading states
* Retry actions
* Error states

---

# 24. Offline Behavior

Full real-time healthcare discovery requires current location/data access and may require internet connectivity.

When offline:

```text
No network
    ↓
Clearly explain that nearby healthcare search is unavailable
    ↓
Provide any locally available emergency information
```

Do not display stale healthcare information as if it were current unless the application explicitly identifies it as cached/stale data.

---

# 25. Multilingual Healthcare Finder

The Healthcare Finder must follow the application's selected language.

Required languages:

```text
en → English
hi → Hindi
bn → Bengali
```

Examples:

```text
Nearby Hospitals
→ localized

Nearby Clinics
→ localized

Nearby Doctors
→ localized

Get Directions
→ localized

Call
→ localized
```

The facility's official name should generally remain unchanged unless the data source provides a verified localized name.

---

# 26. Pregnancy Integration

Pregnancy Care must be able to launch the Healthcare Finder.

Required flow:

```text
Pregnancy Care
      ↓
Warning / Emergency
      ↓
Find Nearby Healthcare
      ↓
Healthcare Finder
      ↓
Hospitals / Clinics / Doctors
```

The selected application language must remain unchanged during this transition.

---

# 27. Emergency Integration

The emergency pathway must prioritize hospitals and other appropriate urgent-care facilities.

Conceptually:

```text
Emergency
    ↓
Find Nearby Hospital
    ↓
Display nearby hospitals
    ↓
Select facility
    ↓
Call / Directions
```

The system must not guarantee that a listed facility can treat a specific emergency unless that capability is verified.

---

# 28. Emergency Facility Ranking

When launched from an emergency flow, the search should prioritize facilities that are most relevant to urgent care based on available verified data.

Potential ranking signals include:

* Facility type
* Distance
* Available emergency information
* Available maternal-care information for pregnancy emergencies

Do not infer capabilities that are not supported by reliable facility data.

---

# 29. Location Privacy

Location access must follow the principle of minimum necessary use.

The application should:

* Request permission only when needed.
* Use location for the requested healthcare discovery purpose.
* Avoid unnecessary continuous background location tracking.
* Avoid storing precise location permanently unless there is a clearly justified product requirement.
* Protect location-related data appropriately.

The Healthcare Finder does not require continuous background GPS tracking for its basic functionality.

---

# 30. Security

The Healthcare Finder must:

* Validate backend requests.
* Secure network communication.
* Protect provider credentials.
* Avoid exposing internal errors.
* Avoid logging unnecessary precise location information.
* Avoid storing sensitive location history without a justified requirement.

---

# 31. Performance

Healthcare search should feel responsive.

The application should:

* Avoid repeated unnecessary location requests.
* Avoid repeated duplicate API calls.
* Debounce repeated search actions where applicable.
* Cache appropriate non-sensitive temporary data where useful.
* Provide immediate feedback when loading.

Do not sacrifice correctness for perceived speed.

---

# 32. Accessibility

The Healthcare Finder must be usable by patients with different levels of technical literacy.

Requirements:

* Large touch targets
* Clear labels
* Simple language
* Readable text
* Strong visual hierarchy
* Clear emergency actions
* No reliance solely on map symbols
* Localized accessibility labels

Icons must not be the only way to communicate important actions.

---

# 33. Testing Requirements

## Location

* [ ] Permission granted
* [ ] Permission denied
* [ ] Permission permanently denied
* [ ] GPS disabled
* [ ] GPS unavailable
* [ ] Low accuracy
* [ ] Location timeout

## Search

* [ ] Hospitals
* [ ] Clinics
* [ ] Doctors
* [ ] Results available
* [ ] No results
* [ ] API failure
* [ ] Network failure
* [ ] Slow network

## Facility

* [ ] Facility details
* [ ] Valid phone number
* [ ] Missing phone number
* [ ] Valid coordinates
* [ ] Missing coordinates
* [ ] Directions
* [ ] External navigation unavailable

## Languages

* [ ] English
* [ ] Hindi
* [ ] Bengali

## Pregnancy

* [ ] Pregnancy emergency launches Healthcare Finder
* [ ] Correct language is maintained
* [ ] Nearby hospitals are displayed
* [ ] Directions work

---

# 34. Definition of Done

The GPS Healthcare Finder is complete only when:

* [ ] Location permission flow works.
* [ ] Permission denial is handled.
* [ ] GPS-disabled state is handled.
* [ ] Current location can be obtained.
* [ ] Hospitals can be discovered.
* [ ] Clinics can be discovered.
* [ ] Doctors can be discovered.
* [ ] Results display accurate available information.
* [ ] Facility details work.
* [ ] Distance works.
* [ ] Call functionality works where a valid number exists.
* [ ] Directions work where supported.
* [ ] No fake healthcare facilities are used.
* [ ] No fake phone numbers or services are displayed.
* [ ] Network failures are handled.
* [ ] Poor connectivity is handled.
* [ ] English works.
* [ ] Hindi works.
* [ ] Bengali works.
* [ ] Pregnancy emergency can launch healthcare discovery.
* [ ] Emergency flow prioritizes appropriate nearby care.
* [ ] Location is not unnecessarily tracked in the background.
* [ ] Provider credentials remain secure.

---

# 35. Implementation Rule for Antigravity

Before implementing the Healthcare Finder:

1. Read `AGENTS.md`.
2. Read `V2_ARCHITECTURE.md`.
3. Read `V2_MULTILANGUAGE.md`.
4. Read `V2_PREGNANCY_CARE.md`.
5. Inspect the existing V1 backend.
6. Inspect existing networking/API services.
7. Inspect existing authentication/security architecture.
8. Inspect existing navigation and design system.
9. Determine whether V1 already contains a map/location capability.
10. Reuse compatible V1 infrastructure.
11. Select an appropriate healthcare/location data provider.
12. Implement the location service.
13. Implement permission handling.
14. Implement healthcare search.
15. Implement normalized healthcare models.
16. Implement facility details.
17. Implement calling.
18. Implement directions/navigation.
19. Integrate with Pregnancy Care emergency flow.
20. Integrate localization.
21. Test all failure states before considering the feature complete.

Do not use fake healthcare data as a substitute for the real healthcare discovery implementation.

Do not expose private API credentials in the Flutter application or repository.

Do not implement continuous background location tracking for the basic Healthcare Finder.

The final feature must provide a reliable path from:

```text
Patient location
      ↓
Nearby healthcare
      ↓
Facility information
      ↓
Call / Directions
```

with a direct integration from pregnancy and emergency workflows.
