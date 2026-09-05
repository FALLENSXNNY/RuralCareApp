import 'package:flutter/material.dart';

/// AppLocalizations handles application-wide multilingual support for
/// English (en), Hindi (hi), and Bengali (bn).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
  };

  // ── Translation Dictionaries ─────────────────────────────────────────────

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General / Common
      'appName': 'RuralCare',
      'tagline': 'AI-assisted healthcare for rural communities',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'retry': 'Retry',
      'continueBtn': 'Continue',
      'submit': 'Submit',
      'back': 'Back',
      'close': 'Close',
      'search': 'Search',
      'call': 'Call',
      'directions': 'Directions',
      'getDirections': 'Get Directions',
      'viewAll': 'View All',
      'details': 'Details',
      'noInternet': 'No Internet Connection',
      'offlineBannerMsg':
          'No internet connection — Emergency guidance remains available offline',

      // Navigation
      'navHome': 'Home',
      'navEmergency': 'Emergency',
      'navAiAssistant': 'AI Health',
      'navPregnancy': 'Pregnancy',
      'navFindCare': 'Care',
      'navRecords': 'Records',
      'navProfile': 'Profile',

      // Language Selection
      'selectLanguage': 'Select Language',
      'changeLanguage': 'Change Language',
      'languageEnglish': 'English',
      'languageHindi': 'हिन्दी (Hindi)',
      'languageBengali': 'বাংলা (Bengali)',
      'languageSaved': 'Language updated successfully',

      // Onboarding & Login
      'welcomeTitle': 'Healthcare Within Your Reach',
      'welcomeSubtitle':
          'Instant first-aid, AI health assistance, and nearby doctor discovery for you and your family.',
      'getStarted': 'Get Started',
      'loginTitle': 'Enter Mobile Number',
      'loginSubtitle':
          'We will send a 6-digit verification code to your phone.',
      'phoneLabel': 'Phone Number',
      'phoneHint': '10-digit mobile number',
      'sendOtp': 'Send Verification Code',
      'enterOtp': 'Enter 6-Digit Code',
      'otpSubtitle': 'Code sent to +91 ',
      'verifyOtp': 'Verify & Login',
      'resendOtp': 'Resend Code',
      'resendIn': 'Resend in {seconds}s',

      // Home Screen
      'greeting': 'Hello, {name}',
      'homeEmergencyBanner': 'Emergency Help (Call 108)',
      'homeAiPrompt': 'Ask AI Health Assistant',
      'homeAiSubtitle': 'Describe symptoms in your language',
      'homePregnancyTitle': 'Mother & Child Care',
      'homePregnancySubtitle': 'Pregnancy tracking & postnatal advice',
      'homeNearbyCareTitle': 'Nearby Hospitals & Clinics',
      'homeNearbyCareSubtitle': 'Find doctors, clinics, and emergency care',
      'homeHealthRecords': 'My Health Records',
      'homeQuickActions': 'Quick Actions',

      // AI Health Assistant
      'aiAssistantTitle': 'AI Health Assistant',
      'aiHealthHelp': 'AI Health Help',
      'onlineAssistant': 'Online Assistant',
      'offlineKnowledge': 'Offline Knowledge',
      'clinicalNotice': 'Clinical Notice',
      'iUnderstand': 'I Understand',
      'clearChatHistory': 'Clear Chat History',
      'clearChatConfirm':
          'Are you sure you want to clear your conversation history with the AI Assistant?',
      'commonHealthTopics': 'Common Health Topics',
      'aiTopicFever': 'Fever & Cold',
      'aiTopicFeverPrompt':
          'How do I manage a fever and cold at home safely?',
      'aiTopicOrs': 'How to make ORS',
      'aiTopicOrsPrompt':
          'How do I make oral rehydration solution (ORS) at home?',
      'aiTopicFirstAid': 'First-Aid Care',
      'aiTopicFirstAidPrompt':
          'What are the first-aid steps for minor cuts, burns, or bites?',
      'aiTopicNearestPhc': 'Nearest PHC',
      'aiTopicNearestPhcPrompt':
          'How can I find my nearest Primary Health Centre (PHC)?',
      'aiTopicBp': 'Blood Pressure Tips',
      'aiTopicBpPrompt':
          'What lifestyle habits help keep blood pressure normal?',
      'messageCopied': 'Message copied to clipboard',
      'aiDisclaimer': 'AI Health Assistant — Not a Doctor',
      'aiInputPlaceholder': 'Type symptoms or ask a health question...',
      'aiEmergencyWarning':
          'If you have severe chest pain, breathing difficulty, or heavy bleeding, call 108 immediately.',
      'aiWelcomeMessage':
          'Hello! I am your RuralCare AI Health Assistant. How can I help you today? Please remember, I provide guidance, not a medical diagnosis.',
      'suggestedQuestion1': 'What should I do for a fever?',
      'suggestedQuestion2': 'When should I visit a doctor for cough?',
      'suggestedQuestion3': 'Foods to eat during pregnancy',
      'suggestedQuestion4': 'First aid for minor burns',

      // Emergency & First Aid
      'emergencyTitle': 'Emergency Assistance',
      'emergencySubtitle': 'Immediate action for life-threatening situations',
      'callAmbulance': 'Call Ambulance (108)',
      'callNationalEmergency': 'National Emergency (112)',
      'callWomenHelpline': 'Women Helpline (1091)',
      'firstAidTitle': 'Offline First Aid Guide',
      'firstAidSubtitle': 'Step-by-step guidance without internet',
      'firstAidWarning': 'Seek immediate medical care while administering first aid',

      // Pregnancy Care
      'pregnancyTitle': 'Mother & Child Care',
      'pregnancyDashboard': 'Pregnancy Dashboard',
      'currentWeek': 'Week {week}',
      'trimester1': '1st Trimester',
      'trimester2': '2nd Trimester',
      'trimester3': '3rd Trimester',
      'trimesterWeeks': 'Weeks {range}',
      'dueDate': 'Estimated Due Date',
      'daysRemaining': '{days} days remaining',
      'editDueDate': 'Edit Due Date',
      'saveDueDate': 'Save Dates',
      'enterEddOrLmp': 'Configure Pregnancy Timeline',
      'selectDueDate': 'Select Estimated Due Date (EDD)',
      'selectLmpDate': 'Select Last Menstrual Period (LMP)',
      'orCalculateFromLmp': 'Or calculate from Last Period (LMP)',
      'antenatalCare': 'Antenatal Care (ANC)',
      'nextAncVisit': 'Next ANC Visit',
      'setReminder': 'Set Reminder',
      'reminderSet': 'Reminder Set',
      'viewAncSchedule': 'View Full ANC Schedule',
      'allAncVisits': 'Antenatal Checkup Schedule',
      'ancVisitNumber': 'Visit {number}',
      'ancCompleted': 'Completed',
      'ancPending': 'Upcoming',
      'testsProcedures': 'Recommended Tests & Actions',
      'nutritionGuide': 'Nutrition & Wellness',
      'stageGuidance': 'Trimester Guidance',
      'tabNutrition': 'Nutrition',
      'tabWellness': 'Wellness',
      'tabMedical': 'Medical & Scans',
      'tabBirthPrep': 'Birth Plan',
      'warningSigns': 'Warning Signs',
      'emergencyCare': 'Emergency Care',
      'seekImmediateMedicalCare': 'Seek Immediate Medical Care',
      'findNearestHospitalOr108': 'Find Nearest Hospital / Call 108',
      'dangerSigns': 'High-Risk Danger Signs',
      'symptomsChecklist': 'Symptoms to Monitor',
      'commonSymptoms': 'Common Symptoms',
      'askPregnancyAi': 'Ask Pregnancy AI',
      'askAiPregnancySubtitle': 'Ask nutrition, symptom questions, or checkup guidance',
      'aiPregnancyDisclaimer': 'AI Health Guide · Not a Doctor · Educational only',
      'babyCare': 'Baby & Newborn Care',
      'postnatalCare': 'Postnatal Care',
      'pregnancyWarningText':
          'Seek immediate medical care for heavy bleeding, severe headache, intense abdominal pain, or sudden swelling.',
      'pregnancyProfileUpdated': 'Pregnancy timeline updated successfully',

      // Find Care / GPS
      'fetchingOsmData': 'Fetching Live Healthcare Data',
      'queryingOsmSubtitle':
          'Querying OpenStreetMap & nearby health facilities...',
      'findCareTitle': 'Nearby Healthcare Facilities',
      'findHealthcare': 'Find Healthcare',
      'findCareSubtitle': 'Hospitals, clinics, and doctors near you',
      'findADoctor': 'Find a Doctor',
      'findDoctorSubtitle': 'Search by speciality, hospital, or name',
      'doctorProfileTitle': 'Doctor Profile',
      'searchFacilitiesHint': 'Search facilities, locations, or services...',
      'searchDoctorsHint': 'Search by doctor name or speciality...',
      'filterAll': 'All',
      'hospitals': 'Hospitals',
      'clinics': 'Clinics',
      'doctors': 'Doctors',
      'pharmacies': 'Pharmacies',
      'maternalCare': 'Maternal Care',
      'emergency24x7': '24x7 Emergency',
      'emergencyTriageBanner':
          'Emergency Mode Active • Prioritizing 24x7 Emergency Hospitals',
      'call108Ambulance': 'Call 108 Ambulance',
      'priorityTriage': 'Priority Triage',
      'detectedLocation': 'Detected Location',
      'nearLocation': 'Near {location}',
      'refreshLocation': 'Refresh',
      'locationPermissionDenied': 'Location permission denied',
      'openSettings': 'Open Settings',
      'distanceKm': '{distance} km away',
      'permissionRequired': 'Location Permission Required',
      'permissionExpl':
          'We need your location to show nearby hospitals, clinics, and doctors.',
      'grantPermission': 'Grant Permission',
      'gpsDisabled': 'Location Services Disabled',
      'enableGps': 'Enable GPS',
      'noFacilitiesFound': 'No healthcare facilities found',
      'adjustFiltersHint':
          'Try adjusting your search query or category filters.',
      'noDoctorsFound': 'No doctors found',
      'adjustDoctorSearchHint':
          'Try searching for a different name or speciality.',
      'statusOpen': 'Open',
      'statusClosed': 'Closed',
      'callFacility': 'Call Facility',
      'callPhone': 'Call {phone}',
      'online': 'Online',
      'nextAvailableSlot': 'Next Available Slot',
      'onlineConsultationAvailable': 'Online Consultation Available',
      'videoCallFromPhone': 'Video call from your phone',
      'bookAppointment': 'Book Appointment',
      'startVideoConsultation': 'Start Video Consultation',
      'confirmConsultation': 'Confirm Consultation',
      'scheduleConsultationWith':
          'Schedule consultation with {name} at {facility}',
      'slotLabel': 'Slot: {slot}',
      'confirmBooking': 'Confirm Booking',
      'appointmentConfirmedMsg':
          'Appointment confirmed with {name} for {slot}',
      'nearbyHealthcare': 'Nearby Healthcare',
      'allCategories': 'All',
      'emergencyCategory': '24x7 Emergency',
      'facilitiesFound': 'facilities found',
      'showList': 'List',
      'showMap': 'Map',
      'expand': 'Expand',
      'collapse': 'Collapse',
      'gpsActive': 'GPS Active',
      'turnOnGps': 'Turn on GPS',
      'gpsDisabledHint': 'Enable device location to see nearby facilities.',
      'locationPermissionHint':
          'Location permission is needed to show accurate nearby hospitals.',
      'enable': 'Enable',
      'noHealthcareFound': 'No healthcare facilities found',
      'noHealthcareHint':
          'Try expanding your search radius or changing category filters.',
      'openNow': 'Open Now',
      'closed': 'Closed',
      'facilityDetails': 'Facility Details',
      'viewInFullMap': 'View in Full Map',
      'contactNumber': 'Contact Number',
      'timing': 'Operating Hours',
      'verifiedServices': 'Verified Services',
      'directionsTo': 'Directions to',
      'fastestRoute': 'Fastest Route',
      'startGoogleMapsNavigation': 'Start Google Maps Navigation',
      'reviews': 'reviews',
      'copiedToClipboard': 'Copied to clipboard',
      'share': 'Share',
      'sort': 'Sort',
      'address': 'Address',
      'verified': 'Verified',
      'showMap': 'Map',
      'showList': 'List',
      'expand': 'Expand',
      'collapse': 'Collapse',
      'changeArea': 'Change Area',
      'selectArea': 'Select Search Area',
      'searchAreaHint': 'Search city, town, or district...',
      'useLiveGps': 'Use Live GPS Location',
      'searchThisArea': 'Search This Area',
      'popularAreas': 'Popular Areas & Towns',

      // Health Records
      'recordsTitle': 'Health Records',
      'myHealthRecords': 'My Health Records',
      'healthTimeline': 'Health Timeline',
      'healthTimelineSubtitle': 'Your full chronological health history',
      'prescriptions': 'Prescriptions',
      'activePrescriptionsCount': '{count} active prescriptions',
      'labReports': 'Lab Reports',
      'diagnosticReportsCount': '{count} diagnostic reports',
      'referrals': 'Referrals',
      'referralTrackingCount': '{count} referral tracking records',
      'consultations': 'Consultations',
      'consultationsCount': '{count} doctor visits & clinical summaries',
      'documents': 'Documents',
      'uploadedDocuments': 'Uploaded Documents',
      'uploadedDocumentsCount': '{count} uploaded documents & scans',
      'uploadDocsSubtitle': 'Upload prescriptions, reports & scans',
      'uploadDocument': 'Upload Document',
      'emptyRecords': 'No records found',
      'searchPrescriptionsHint': 'Search by doctor or medicine...',
      'searchLabReportsHint': 'Search by test name or doctor...',
      'searchReferralsHint': 'Search referrals...',
      'searchConsultationsHint': 'Search consultations...',
      'noLabReportsFound': 'No lab reports found',
      'noReferralsFound': 'No referrals found',
      'noConsultationsFound': 'No consultations found',
      'noDocumentsFound': 'No documents found',
      'noTimelineEventsFound': 'No timeline events found',

      // Quick Action Tool Names
      'actionAskAi': 'Ask\nAI',
      'actionTalkDoctor': 'Talk to\nDoctor',
      'actionFindFacility': 'Find\nFacility',
      'actionHealthRecords': 'My Health\nRecords',
      'actionUploadDocs': 'Upload\nDocs',
      'actionFindDoctor': 'Find\nDoctor',

      // Home Screen Details
      'healthProfile': 'Health Profile',
      'recentPrescriptions': 'Recent Prescriptions',
      'activeReferrals': 'Active Referrals',
      'seeAll': 'See All',
      'noPrescriptionsFound': 'No prescriptions found',
      'medicinesCount': '{count} medicines',
      'noneRecorded': 'None recorded',
      'noKnownAllergies': 'No known allergies',
      'dontKnow': "Don't Know",
      'notSpecified': 'Not specified',
      'yearsOld': '{age} years',

      // Emergency Screen Specifics
      'emergencyHelp': 'Emergency Help',
      'emergencyHelpDesc':
          'Choose an emergency type or dial 108 directly.\nAll first-aid guidance works 100% offline.',
      'findNearestEmergencyFacility': 'Find Nearest Emergency Facility',
      'firstAidGuide': 'First Aid Guide',
      'offlineEmergencyModeAndStorage': 'Offline Emergency Mode & Storage',
      'offlineModeBanner': 'Offline Mode — Emergency content loaded on device',
      'call108Subtitle': 'Ambulance service across India · 108',
      'call108Now': 'Call 108 Ambulance NOW',
      'findEmergencyFacility': 'Find Emergency Facility Near You',
      'stepByStep': 'Step-by-Step',
      'stepNumber': 'Step {step}',
      'stepOfTotal': 'STEP {step} OF {total}',
      'previousStep': 'Previous',
      'nextStepLabel': 'Next Step ({step}/{total})',
      'dos': "DO's",
      'donts': "DON'Ts",
      'dosTitle': 'DOs (Recommended Actions)',
      'dontsTitle': "DON'Ts (Harmful Actions)",
      'highUrgency': 'HIGH URGENCY',
      'mediumUrgency': 'MEDIUM URGENCY',
      'lowUrgency': 'LOW URGENCY',
      'clearChat': 'Clear Chat',
      'medicalDisclaimer': 'Medical Disclaimer',
      'offlineAiNotice':
          'Offline Mode — General emergency and first-aid guidance available',

      // Profile & Settings
      'profileTitle': 'Patient Profile',
      'editProfile': 'Edit Profile',
      'personalDetails': 'Personal Details',
      'name': 'Name',
      'age': 'Age',
      'gender': 'Gender',
      'bloodGroup': 'Blood Group',
      'allergies': 'Allergies',
      'chronicConditions': 'Conditions',
      'emergencyContact': 'Emergency Contact',
      'settings': 'Settings',
      'appLanguage': 'App Language',
      'offlineEmergencyContent': 'Offline Emergency Content',
      'offlineEmergencySubtitle': 'Download for use without internet',
      'notifications': 'Notifications',
      'notificationsSubtitle': 'Appointments, reminders',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to log out?',

      // Appointments & Queue Management (Demo)
      'bookAppointment': 'Book Appointment',
      'confirmAppointment': 'Confirm Appointment',
      'appointmentConfirmed': 'Appointment Confirmed',
      'myAppointments': 'My Appointments',
      'myQueue': 'My Queue',
      'appointmentDetails': 'Appointment Details',
      'checkIn': 'Check In',
      'checkInNow': 'Check In Now',
      'checkedIn': 'Checked In',
      'viewLiveQueue': 'View Live Queue',
      'viewAppointment': 'View Appointment',
      'viewDetails': 'View Details',
      'selectDate': 'Select Date',
      'availableTime': 'Available Time',
      'confirmBooking': 'Confirm Booking',
      'upcoming': 'Upcoming',
      'noUpcomingAppointments': 'No upcoming appointments',
      'findHealthcare': 'Find Healthcare',
      'demoQueueControls': 'Demo Queue Controls',
      'demoMode': 'Demo Mode',
      'demoQueueNote': 'Current queue can be simulated for demonstration.',
      'simulateNextPatient': 'Simulate Next Patient',
      'yourToken': 'YOUR TOKEN',
      'currentlyServing': 'CURRENTLY SERVING',
      'patientsAhead': 'patients ahead',
      'estimatedWait': 'Estimated Wait',
      'queueActive': 'Queue Active',
      'yourTurnApproaching': 'Your turn is approaching!',
      'stayNearConsultation': 'Please stay near the consultation area.',
      'itsYourTurn': "It's your turn!",
      'proceedToConsultation': 'Please proceed to the consultation area.',
      'queueCalled': 'CALLED',
      'queueNext': 'Your turn is next',
      'specialty': 'Specialty',
      'clinic': 'Clinic',
      'date': 'Date',
      'time': 'Time',
      'doctor': 'Doctor',
      'appointmentId': 'Appointment ID',
      'status': 'Status',
      'confirmed': 'Confirmed',

      // Registration & Profile Enhancements
      'step1Of2': 'Step 1 of 2: Basic Details',
      'step2Of2': 'Step 2 of 2: Health Details',
      'preferredLanguage': 'Preferred Language',
      'genderFemale': 'Female',
      'genderMale': 'Male',
      'genderOther': 'Other',
      'areYouPregnant': 'Are you currently pregnant?',
      'yesPregnant': 'Yes, currently pregnant',
      'notPregnant': 'No',
      'pregnancyMonth': 'Pregnancy Month',
      'gestationalWeekLabel': 'Gestational Week',
      'estimatedDueDate': 'Estimated Due Date (EDD)',
      'firstTrimester': '1st Trimester (Week 1–12)',
      'secondTrimester': '2nd Trimester (Week 13–27)',
      'thirdTrimester': '3rd Trimester (Week 28–40+)',
      'emergencyContactSection': 'Emergency Contact (Recommended)',
      'emergencyContactNameLabel': 'Contact Person Name',
      'emergencyContactPhoneLabel': 'Emergency Mobile Number',
      'emergencyContactHint': 'Relative, neighbor, or ASHA worker',
      'abhaIdLabel': 'ABHA Health ID (Optional)',
      'abhaIdHint': '14-digit Ayushman Bharat number',
      'villageLabel': 'Village / Town',
      'districtLabel': 'District',
      'stateLabel': 'State',
      'pincodeLabel': 'Pincode',
      'completeRegistration': 'Complete Registration & Continue',
    },

    'hi': {
      // General / Common
      'appName': 'रूरलकेयर (RuralCare)',
      'tagline': 'ग्रामीण समुदायों के लिए AI-सहायक स्वास्थ्य सेवा',
      'loading': 'लोड हो रहा है...',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'retry': 'पुनः प्रयास करें',
      'continueBtn': 'आगे बढ़ें',
      'submit': 'जमा करें',
      'back': 'वापस',
      'close': 'बंद करें',
      'search': 'खोजें',
      'call': 'कॉल करें',
      'directions': 'दिशा-निर्देश',
      'getDirections': 'दिशा-निर्देश प्राप्त करें',
      'viewAll': 'सभी देखें',
      'details': 'विवरण',
      'noInternet': 'कोई इंटरनेट कनेक्शन नहीं',
      'offlineBannerMsg':
          'कोई इंटरनेट कनेक्शन नहीं — आपातकालीन मार्गदर्शन ऑफ़लाइन उपलब्ध है',

      // Navigation
      'navHome': 'होम',
      'navEmergency': 'आपातकालीन',
      'navAiAssistant': 'AI स्वास्थ्य',
      'navPregnancy': 'मातृ एवं शिशु',
      'navFindCare': 'अस्पताल',
      'navRecords': 'रिकॉर्ड्स',
      'navProfile': 'प्रोफ़ाइल',

      // Language Selection
      'selectLanguage': 'भाषा चुनें',
      'changeLanguage': 'भाषा बदलें',
      'languageEnglish': 'English',
      'languageHindi': 'हिन्दी (Hindi)',
      'languageBengali': 'বাংলা (Bengali)',
      'languageSaved': 'भाषा सफलतापूर्वक अपडेट की गई',

      // Onboarding & Login
      'welcomeTitle': 'स्वास्थ्य सेवा आपकी पहुंच में',
      'welcomeSubtitle':
          'आपके और आपके परिवार के लिए तत्काल प्राथमिक उपचार, AI स्वास्थ्य सहायता और नजदीकी डॉक्टर की खोज।',
      'getStarted': 'शुरू करें',
      'loginTitle': 'मोबाइल नंबर दर्ज करें',
      'loginSubtitle':
          'हम आपके फोन पर 6-अंकों का सत्यापन कोड भेजेंगे।',
      'phoneLabel': 'फ़ोन नंबर',
      'phoneHint': '10-अंकों का मोबाइल नंबर',
      'sendOtp': 'सत्यापन कोड भेजें',
      'enterOtp': '6-अंकों का कोड दर्ज करें',
      'otpSubtitle': 'कोड भेजा गया: +91 ',
      'verifyOtp': 'सत्यापित करें और लॉगिन करें',
      'resendOtp': 'कोड पुनः भेजें',
      'resendIn': '{seconds} सेकंड में पुनः भेजें',

      // Home Screen
      'greeting': 'नमस्ते, {name}',
      'homeEmergencyBanner': 'आपातकालीन सहायता (108)',
      'homeAiPrompt': 'AI स्वास्थ्य सहायक से पूछें',
      'homeAiSubtitle': 'अपनी भाषा में लक्षणों का वर्णन करें',
      'homePregnancyTitle': 'मातृ एवं शिशु देखभाल',
      'homePregnancySubtitle': 'गर्भावस्था ट्रैकिंग और प्रसवोत्तर सलाह',
      'homeNearbyCareTitle': 'नजदीकी अस्पताल और क्लीनिक',
      'homeNearbyCareSubtitle': 'डॉक्टर, क्लीनिक और आपातकालीन देखभाल खोजें',
      'homeHealthRecords': 'मेरे स्वास्थ्य रिकॉर्ड्स',
      'homeQuickActions': 'त्वरित कार्य',

      // AI Health Assistant
      'aiAssistantTitle': 'AI स्वास्थ्य सहायक',
      'aiHealthHelp': 'AI स्वास्थ्य सहायता',
      'onlineAssistant': 'ऑनलाइन सहायक',
      'offlineKnowledge': 'ऑफ़लाइन ज्ञान',
      'clinicalNotice': 'चिकित्सीय सूचना',
      'iUnderstand': 'समझ गया',
      'clearChatHistory': 'चैट इतिहास साफ़ करें',
      'clearChatConfirm':
          'क्या आप वाकई AI सहायक के साथ अपना बातचीत इतिहास साफ़ करना चाहते हैं?',
      'commonHealthTopics': 'सामान्य स्वास्थ्य विषय',
      'aiTopicFever': 'बुखार और सर्दी',
      'aiTopicFeverPrompt':
          'घर पर बुखार और सर्दी का सुरक्षित प्रबंधन कैसे करें?',
      'aiTopicOrs': 'ओआरएस (ORS) बनाना',
      'aiTopicOrsPrompt':
          'घर पर ओआरएस का घोल कैसे बनाएं?',
      'aiTopicFirstAid': 'प्राथमिक उपचार',
      'aiTopicFirstAidPrompt':
          'मामूली कटने, जलने या कीड़े के काटने पर प्राथमिक उपचार क्या है?',
      'aiTopicNearestPhc': 'नजदीकी अस्पताल',
      'aiTopicNearestPhcPrompt':
          'अपने नजदीकी प्राथमिक स्वास्थ्य केंद्र (PHC) का पता कैसे लगाएं?',
      'aiTopicBp': 'रक्तचाप (BP) टिप्स',
      'aiTopicBpPrompt':
          'रक्तचाप को सामान्य रखने के लिए क्या जीवनशैली अपनाएं?',
      'messageCopied': 'संदेश क्लिपबोर्ड पर कॉपी किया गया',
      'aiDisclaimer': 'AI स्वास्थ्य सहायक — डॉक्टर नहीं है',
      'aiInputPlaceholder': 'लक्षण लिखें या स्वास्थ्य संबंधी प्रश्न पूछें...',
      'aiEmergencyWarning':
          'यदि आपको सीने में गंभीर दर्द, सांस लेने में कठिनाई या अत्यधिक रक्तस्राव है, तो तुरंत 108 पर कॉल करें।',
      'aiWelcomeMessage':
          'नमस्ते! मैं आपका रूरलकेयर AI स्वास्थ्य सहायक हूं। आज मैं आपकी क्या मदद कर सकता हूं? कृपया याद रखें, मैं मार्गदर्शन प्रदान करता हूं, चिकित्सीय निदान नहीं।',
      'suggestedQuestion1': 'बुखार के लिए मुझे क्या करना चाहिए?',
      'suggestedQuestion2': 'खांसी के लिए मुझे डॉक्टर के पास कब जाना चाहिए?',
      'suggestedQuestion3': 'गर्भावस्था के दौरान क्या खाना चाहिए?',
      'suggestedQuestion4': 'मामूली जलने पर प्राथमिक उपचार',

      // Emergency & First Aid
      'emergencyTitle': 'आपातकालीन सहायता',
      'emergencySubtitle': 'जानलेवा स्थितियों के लिए तत्काल कार्रवाई',
      'callAmbulance': 'एम्बुलेंस कॉल करें (108)',
      'callNationalEmergency': 'राष्ट्रीय आपातकाल (112)',
      'callWomenHelpline': 'महिला हेल्पलाइन (1091)',
      'firstAidTitle': 'ऑफ़लाइन प्राथमिक उपचार गाइड',
      'firstAidSubtitle': 'बिना इंटरनेट के चरण-दर-चरण मार्गदर्शन',
      'firstAidWarning': 'प्राथमिक उपचार देते समय तुरंत चिकित्सीय सहायता लें',
      'emergencyHelp': 'आपातकालीन सहायता',
      'emergencyHelpDesc':
          'आपातकाल का प्रकार चुनें या सीधे 108 डायल करें।\nसभी प्राथमिक उपचार निर्देश 100% ऑफ़लाइन काम करते हैं।',
      'findNearestEmergencyFacility': 'निकटतम आपातकालीन अस्पताल खोजें',
      'firstAidGuide': 'प्राथमिक उपचार गाइड',
      'offlineEmergencyModeAndStorage': 'ऑफ़लाइन आपातकालीन मोड और संग्रहण',
      'offlineModeBanner': 'ऑफ़लाइन मोड — आपातकालीन सामग्री डिवाइस पर लोड है',
      'call108Subtitle': 'पूरे भारत में एम्बुलेंस सेवा · 108',
      'call108Now': 'अभी 108 एम्बुलेंस को कॉल करें',
      'findEmergencyFacility': 'अपने नजदीकी आपातकालीन अस्पताल खोजें',
      'stepByStep': 'चरणबद्ध निर्देश',
      'stepNumber': 'चरण {step}',
      'stepOfTotal': 'चरण {step} / {total}',
      'previousStep': 'पिछला चरण',
      'nextStepLabel': 'अगला चरण ({step}/{total})',
      'dos': 'क्या करें',
      'donts': 'क्या न करें',
      'dosTitle': 'क्या करें (अनुशंसित कार्य)',
      'dontsTitle': 'क्या न करें (हानिकारक कार्य)',
      'highUrgency': 'अत्यधिक गंभीर',
      'mediumUrgency': 'मध्यम गंभीर',
      'lowUrgency': 'सामान्य',
      'clearChat': 'चैट साफ़ करें',
      'medicalDisclaimer': 'चिकित्सीय अस्वीकरण',
      'offlineAiNotice':
          'ऑफ़लाइन मोड — सामान्य आपातकालीन और प्राथमिक उपचार मार्गदर्शन उपलब्ध है',

      // Pregnancy Care
      'pregnancyTitle': 'मातृ एवं शिशु देखभाल',
      'pregnancyDashboard': 'गर्भावस्था डैशबोर्ड',
      'currentWeek': 'सप्ताह {week}',
      'trimester1': 'पहली तिमाही (1st Trimester)',
      'trimester2': 'दूसरी तिमाही (2nd Trimester)',
      'trimester3': 'तीसरी तिमाही (3rd Trimester)',
      'trimesterWeeks': 'सप्ताह {range}',
      'dueDate': 'प्रसव की अनुमानित तिथि',
      'daysRemaining': '{days} दिन शेष',
      'editDueDate': 'तिथि बदलें',
      'saveDueDate': 'तिथियां सहेजें',
      'enterEddOrLmp': 'गर्भावस्था समयरेखा निर्धारित करें',
      'selectDueDate': 'प्रसव की अनुमानित तिथि (EDD) चुनें',
      'selectLmpDate': 'अंतिम माहवारी तिथि (LMP) चुनें',
      'orCalculateFromLmp': 'या अंतिम माहवारी (LMP) से गणना करें',
      'antenatalCare': 'प्रसव पूर्व जांच (ANC)',
      'nextAncVisit': 'अगली प्रसव पूर्व जांच (ANC)',
      'setReminder': 'याद दिलाएं',
      'reminderSet': 'रिमाइंडर सेट है',
      'viewAncSchedule': 'पूरी ANC जांच सूची देखें',
      'allAncVisits': 'प्रसव पूर्व जांच (ANC) कार्यक्रम',
      'ancVisitNumber': 'जांच {number}',
      'ancCompleted': 'पूर्ण',
      'ancPending': 'आगामी',
      'testsProcedures': 'अनुशंसित जांच और दवाएं',
      'nutritionGuide': 'पोषण और स्वास्थ्य',
      'stageGuidance': 'तिमाही मार्गदर्शन',
      'tabNutrition': 'पोषण',
      'tabWellness': 'स्वास्थ्य और आराम',
      'tabMedical': 'जांच और टीके',
      'tabBirthPrep': 'प्रसव तैयारी',
      'warningSigns': 'खतरे के लक्षण',
      'emergencyCare': 'आपातकालीन देखभाल',
      'seekImmediateMedicalCare': 'तत्काल चिकित्सीय सहायता लें',
      'findNearestHospitalOr108': 'नजदीकी अस्पताल खोजें / 108 डायल करें',
      'dangerSigns': 'गंभीर खतरे के संकेत',
      'symptomsChecklist': 'लक्षणों की निगरानी',
      'commonSymptoms': 'सामान्य लक्षण',
      'askPregnancyAi': 'AI गर्भावस्था सहायक से पूछें',
      'askAiPregnancySubtitle': 'पोषण, लक्षण या जांच संबंधी प्रश्न पूछें',
      'aiPregnancyDisclaimer': 'AI स्वास्थ्य सहायक · डॉक्टर नहीं है · केवल मार्गदर्शन',
      'babyCare': 'शिशु और नवजात शिशु की देखभाल',
      'postnatalCare': 'प्रसवोत्तर देखभाल',
      'pregnancyWarningText':
          'अत्यधिक रक्तस्राव, तेज सिरदर्द, पेट में गंभीर दर्द या अचानक सूजन के लिए तत्काल डॉक्टर से संपर्क करें।',
      'pregnancyProfileUpdated': 'गर्भावस्था समयरेखा सफलतापूर्वक अपडेट की गई',

      // Find Care / GPS
      'fetchingOsmData': 'स्वास्थ्य डेटा लोड हो रहा है',
      'queryingOsmSubtitle':
          'OpenStreetMap और नजदीकी सुविधाओं से डेटा प्राप्त किया जा रहा है...',
      'findCareTitle': 'नजदीकी स्वास्थ्य सुविधाएं',
      'findHealthcare': 'स्वास्थ्य सेवा खोजें',
      'findCareSubtitle': 'आपके नजदीकी अस्पताल, क्लीनिक और डॉक्टर',
      'findADoctor': 'डॉक्टर खोजें',
      'findDoctorSubtitle': 'विशेषज्ञता, अस्पताल या नाम से खोजें',
      'doctorProfileTitle': 'डॉक्टर प्रोफ़ाइल',
      'searchFacilitiesHint': 'अस्पताल, स्थान या सेवाएं खोजें...',
      'searchDoctorsHint': 'डॉक्टर के नाम या विशेषज्ञता से खोजें...',
      'filterAll': 'सभी',
      'hospitals': 'अस्पताल',
      'clinics': 'क्लीनिक',
      'doctors': 'डॉक्टर',
      'pharmacies': 'दवा की दुकानें',
      'maternalCare': 'मातृ देखभाल',
      'emergency24x7': '24x7 आपातकालीन',
      'emergencyTriageBanner':
          'आपातकालीन मोड सक्रिय • 24x7 आपातकालीन अस्पतालों को प्राथमिकता',
      'call108Ambulance': '108 एम्बुलेंस को कॉल करें',
      'priorityTriage': 'प्राथमिकता ट्राइएज',
      'detectedLocation': 'पहचाना गया स्थान',
      'nearLocation': '{location} के पास',
      'refreshLocation': 'रीफ्रेश करें',
      'locationPermissionDenied': 'स्थान अनुमति अस्वीकृत',
      'openSettings': 'सेटिंग्स खोलें',
      'distanceKm': '{distance} किमी दूर',
      'permissionRequired': 'स्थान की अनुमति आवश्यक है',
      'permissionExpl':
          'नजदीकी अस्पतालों और डॉक्टरों को खोजने के लिए स्थान की अनुमति चाहिए।',
      'grantPermission': 'अनुमति दें',
      'gpsDisabled': 'स्थान सेवाएं (GPS) बंद हैं',
      'enableGps': 'GPS चालू करें',
      'noFacilitiesFound': 'कोई स्वास्थ्य सुविधा नहीं मिली',
      'adjustFiltersHint': 'अपनी खोज या फ़िल्टर बदलकर पुनः प्रयास करें।',
      'noDoctorsFound': 'कोई डॉक्टर नहीं मिले',
      'adjustDoctorSearchHint': 'किसी अन्य नाम या विशेषज्ञता से खोजें।',
      'statusOpen': 'खुला है',
      'statusClosed': 'बंद है',
      'callFacility': 'अस्पताल को कॉल करें',
      'callPhone': '{phone} पर कॉल करें',
      'online': 'ऑनलाइन',
      'nextAvailableSlot': 'अगला उपलब्ध समय (Slot)',
      'onlineConsultationAvailable': 'ऑनलाइन परामर्श उपलब्ध है',
      'videoCallFromPhone': 'अपने फोन से वीडियो कॉल करें',
      'bookAppointment': 'अपॉइंटमेंट बुक करें',
      'startVideoConsultation': 'वीडियो परामर्श शुरू करें',
      'confirmConsultation': 'परामर्श की पुष्टि करें',
      'scheduleConsultationWith':
          '{facility} में {name} के साथ परामर्श निर्धारित करें',
      'slotLabel': 'समय (Slot): {slot}',
      'confirmBooking': 'बुकिंग की पुष्टि करें',
      'appointmentConfirmedMsg':
          '{slot} के लिए {name} के साथ अपॉइंटमेंट की पुष्टि हो गई',
      'nearbyHealthcare': 'नजदीकी स्वास्थ्य सेवा',
      'allCategories': 'सभी',
      'emergencyCategory': '24x7 आपातकालीन',
      'facilitiesFound': 'सुविधाएं मिलीं',
      'showList': 'सूची',
      'showMap': 'मानचित्र',
      'expand': 'बड़ा करें',
      'collapse': 'छोटा करें',
      'gpsActive': 'GPS सक्रिय',
      'turnOnGps': 'GPS चालू करें',
      'gpsDisabledHint': 'नजदीकी अस्पतालों को देखने के लिए लोकेशन चालू करें।',
      'locationPermissionHint':
          'सटीक नजदीकी अस्पताल दिखाने के लिए स्थान अनुमति आवश्यक है।',
      'enable': 'चालू करें',
      'noHealthcareFound': 'कोई स्वास्थ्य सुविधा नहीं मिली',
      'noHealthcareHint':
          'अपनी खोज का दायरा बढ़ाएं या श्रेणी बदलकर पुनः प्रयास करें।',
      'openNow': 'खुला है',
      'closed': 'बंद है',
      'facilityDetails': 'अस्पताल विवरण',
      'viewInFullMap': 'पूरे मानचित्र में देखें',
      'contactNumber': 'संपर्क नंबर',
      'timing': 'खुलने का समय',
      'verifiedServices': 'सत्यापित सेवाएं',
      'directionsTo': 'दिशा-निर्देश:',
      'fastestRoute': 'सबसे तेज़ रास्ता',
      'startGoogleMapsNavigation': 'Google Maps नेविगेशन शुरू करें',
      'changeArea': 'क्षेत्र बदलें',
      'selectArea': 'खोज क्षेत्र चुनें',
      'searchAreaHint': 'शहर, कस्बा या जिला खोजें...',
      'useLiveGps': 'लाइव GPS स्थान का उपयोग करें',
      'searchThisArea': 'इस क्षेत्र में खोजें',
      'popularAreas': 'प्रमुख क्षेत्र व शहर',
      'reviews': 'समीक्षाएं',
      'copiedToClipboard': 'क्लिपबोर्ड पर कॉपी किया गया',
      'share': 'शेयर करें',
      'sort': 'क्रमबद्ध करें',
      'rating': 'रेटिंग',
      'distance': 'दूरी',
      'address': 'पता',
      'verified': 'सत्यापित',
      'showMap': 'मानचित्र',
      'showList': 'सूची',
      'expand': 'विस्तार करें',
      'collapse': 'छोटा करें',

      // Health Records
      'recordsTitle': 'स्वास्थ्य रिकॉर्ड्स',
      'myHealthRecords': 'मेरे स्वास्थ्य रिकॉर्ड्स',
      'healthTimeline': 'स्वास्थ्य टाइमलाइन',
      'healthTimelineSubtitle': 'आपका पूरा कालानुक्रमिक स्वास्थ्य इतिहास',
      'prescriptions': 'दवा के पर्चे (Prescriptions)',
      'activePrescriptionsCount': '{count} सक्रिय पर्चे',
      'labReports': 'लैब रिपोर्ट्स',
      'diagnosticReportsCount': '{count} जांच रिपोर्ट्स',
      'referrals': 'रेफरल (Referrals)',
      'referralTrackingCount': '{count} रेफरल रिकॉर्ड्स',
      'consultations': 'परामर्श (Consultations)',
      'consultationsCount': '{count} डॉक्टर परामर्श व सारांश',
      'documents': 'दस्तावेज़',
      'uploadedDocuments': 'अपलोड किए गए दस्तावेज़',
      'uploadedDocumentsCount': '{count} अपलोड किए गए दस्तावेज़',
      'uploadDocsSubtitle': 'पर्चे, रिपोर्ट और स्कैन अपलोड करें',
      'uploadDocument': 'दस्तावेज़ अपलोड करें',
      'emptyRecords': 'कोई रिकॉर्ड नहीं मिला',
      'searchPrescriptionsHint': 'डॉक्टर या दवा के नाम से खोजें...',
      'searchLabReportsHint': 'जांच या डॉक्टर के नाम से खोजें...',
      'searchReferralsHint': 'रेफरल खोजें...',
      'searchConsultationsHint': 'परामर्श खोजें...',
      'noLabReportsFound': 'कोई लैब रिपोर्ट नहीं मिली',
      'noReferralsFound': 'कोई रेफरल नहीं मिला',
      'noConsultationsFound': 'कोई परामर्श नहीं मिला',
      'noDocumentsFound': 'कोई दस्तावेज़ नहीं मिला',
      'noTimelineEventsFound': 'कोई टाइमलाइन गतिविधि नहीं मिली',

      // Quick Action Tool Names
      'actionAskAi': 'AI से\nपूछें',
      'actionTalkDoctor': 'डॉक्टर से\nबात करें',
      'actionFindFacility': 'अस्पताल\nखोजें',
      'actionHealthRecords': 'स्वास्थ्य\nरिकॉर्ड्स',
      'actionUploadDocs': 'दस्तावेज़\nअपलोड',
      'actionFindDoctor': 'डॉक्टर\nखोजें',

      // Home Screen Details
      'healthProfile': 'स्वास्थ्य प्रोफ़ाइल',
      'recentPrescriptions': 'हाल के नुस्खे (Prescriptions)',
      'activeReferrals': 'सक्रिय रेफरल (Referrals)',
      'seeAll': 'सभी देखें',
      'noPrescriptionsFound': 'कोई नुस्खा नहीं मिला',
      'medicinesCount': '{count} दवाइयां',
      'noneRecorded': 'कोई दर्ज नहीं',
      'noKnownAllergies': 'कोई ज्ञात एलर्जी नहीं',
      'dontKnow': 'पता नहीं',
      'notSpecified': 'निर्दिष्ट नहीं है',
      'yearsOld': '{age} वर्ष',

      // Profile & Settings
      'profileTitle': 'मरीज प्रोफ़ाइल',
      'editProfile': 'प्रोफ़ाइल संपादित करें',
      'personalDetails': 'व्यक्तिगत विवरण',
      'name': 'नाम',
      'age': 'उम्र',
      'gender': 'लिंग',
      'bloodGroup': 'रक्त समूह (Blood Group)',
      'allergies': 'एलर्जी (Allergies)',
      'chronicConditions': 'पुरानी बीमारियां',
      'emergencyContact': 'आपातकालीन संपर्क',
      'settings': 'सेटिंग्स',
      'appLanguage': 'ऐप की भाषा',
      'offlineEmergencyContent': 'ऑफ़लाइन आपातकालीन सामग्री',
      'offlineEmergencySubtitle': 'इंटरनेट के बिना उपयोग के लिए डाउनलोड करें',
      'notifications': 'सूचनाएं (Notifications)',
      'notificationsSubtitle': 'अपॉइंटमेंट और स्वास्थ्य अनुस्मारक',
      'logout': 'लॉग आउट',
      'logoutConfirm': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',

      // Appointments & Queue Management (Demo)
      'bookAppointment': 'अपॉइंटमेंट बुक करें',
      'confirmAppointment': 'अपॉइंटमेंट की पुष्टि करें',
      'appointmentConfirmed': 'अपॉइंटमेंट की पुष्टि हो गई',
      'myAppointments': 'मेरे अपॉइंटमेंट्स',
      'myQueue': 'मेरी कतार',
      'appointmentDetails': 'अपॉइंटमेंट विवरण',
      'checkIn': 'चेक इन (Check In)',
      'checkInNow': 'अभी चेक इन करें',
      'checkedIn': 'चेक इन पूरा हुआ',
      'viewLiveQueue': 'लाइव कतार देखें',
      'viewAppointment': 'अपॉइंटमेंट देखें',
      'viewDetails': 'विवरण देखें',
      'selectDate': 'तारीख चुनें',
      'availableTime': 'उपलब्ध समय',
      'confirmBooking': 'बुकिंग की पुष्टि करें',
      'upcoming': 'आगामी',
      'noUpcomingAppointments': 'कोई आगामी अपॉइंटमेंट नहीं है',
      'findHealthcare': 'स्वास्थ्य सेवा खोजें',
      'demoQueueControls': 'डेमो कतार नियंत्रण',
      'demoMode': 'डेमो मोड',
      'demoQueueNote': 'प्रदर्शन के लिए वर्तमान कतार को सिम्युलेट किया जा सकता है।',
      'simulateNextPatient': 'अगला मरीज सिम्युलेट करें',
      'yourToken': 'आपका टोकन',
      'currentlyServing': 'वर्तमान टोकन',
      'patientsAhead': 'मरीज आगे हैं',
      'estimatedWait': 'अनुमानित प्रतीक्षा',
      'queueActive': 'कतार सक्रिय है',
      'yourTurnApproaching': 'आपकी बारी आने वाली है!',
      'stayNearConsultation': 'कृपया परामर्श क्षेत्र के निकट रहें।',
      'itsYourTurn': 'आपकी बारी आ गई है!',
      'proceedToConsultation': 'कृपया परामर्श कक्ष में प्रवेश करें।',
      'queueCalled': 'बुलाया गया (CALLED)',
      'queueNext': 'अगली बारी आपकी है',
      'specialty': 'विशेषज्ञता',
      'clinic': 'क्लीनिक',
      'date': 'तारीख',
      'time': 'समय',
      'doctor': 'डॉक्टर',
      'appointmentId': 'अपॉइंटमेंट आईडी',
      'status': 'स्थिति',
      'confirmed': 'पुष्टि की गई',

      // Registration & Profile Enhancements
      'step1Of2': 'चरण 1 का 2: बुनियादी विवरण',
      'step2Of2': 'चरण 2 का 2: स्वास्थ्य विवरण',
      'preferredLanguage': 'पसंदीदा भाषा',
      'genderFemale': 'महिला',
      'genderMale': 'पुरुष',
      'genderOther': 'अन्य',
      'areYouPregnant': 'क्या आप वर्तमान में गर्भवती हैं?',
      'yesPregnant': 'हाँ, वर्तमान में गर्भवती हूँ',
      'notPregnant': 'नहीं',
      'pregnancyMonth': 'गर्भावस्था का महीना',
      'gestationalWeekLabel': 'गर्भावस्था का सप्ताह',
      'estimatedDueDate': 'अनुमानित प्रसव तिथि (EDD)',
      'firstTrimester': 'पहली तिमाही (सप्ताह 1–12)',
      'secondTrimester': 'दूसरी तिमाही (सप्ताह 13–27)',
      'thirdTrimester': 'तीसरी तिमाही (सप्ताह 28–40+)',
      'emergencyContactSection': 'आपातकालीन संपर्क (अनुशंसित)',
      'emergencyContactNameLabel': 'संपर्क व्यक्ति का नाम',
      'emergencyContactPhoneLabel': 'आपातकालीन मोबाइल नंबर',
      'emergencyContactHint': 'रिश्तेदार, पड़ोसी या आशा कार्यकर्ता',
      'abhaIdLabel': 'आभा (ABHA) स्वास्थ्य आईडी (वैकल्पिक)',
      'abhaIdHint': '14-अंकों का आयुष्मान भारत नंबर',
      'villageLabel': 'गाँव / कस्बा',
      'districtLabel': 'जिला',
      'stateLabel': 'राज्य',
      'pincodeLabel': 'पिनकोड',
      'completeRegistration': 'पंजीकरण पूरा करें और आगे बढ़ें',
    },

    'bn': {
      // General / Common
      'appName': 'রুরালকেয়ার (RuralCare)',
      'tagline': 'গ্রামীণ জনগোষ্ঠীর জন্য এআই-সহায়তাপ্রাপ্ত স্বাস্থ্যসেবা',
      'loading': 'লোড হচ্ছে...',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল করুন',
      'edit': 'সম্পাদনা করুন',
      'delete': 'মুছে ফেলুন',
      'retry': 'পুনরায় চেষ্টা করুন',
      'continueBtn': 'এগিয়ে যান',
      'submit': 'জমা দিন',
      'back': 'ফিরে যান',
      'close': 'বন্ধ করুন',
      'search': 'অনুসন্ধান করুন',
      'call': 'কল করুন',
      'directions': 'পথনির্দেশ',
      'getDirections': 'পথনির্দেশ পান',
      'viewAll': 'সব দেখুন',
      'details': 'বিবরণ',
      'noInternet': 'কোনো ইন্টারনেট সংযোগ নেই',
      'offlineBannerMsg':
          'কোনো ইন্টারনেট সংযোগ নেই — জরুরি নির্দেশনা অফলাইনে উপলব্ধ',

      // Navigation
      'navHome': 'হোম',
      'navEmergency': 'জরুরি',
      'navAiAssistant': 'এআই স্বাস্থ্য',
      'navPregnancy': 'মাতৃ ও শিশু',
      'navFindCare': 'হাসপাতাল',
      'navRecords': 'রেকর্ড',
      'navProfile': 'প্রোফাইল',

      // Language Selection
      'selectLanguage': 'ভাষা নির্বাচন করুন',
      'changeLanguage': 'ভাষা পরিবর্তন করুন',
      'languageEnglish': 'English',
      'languageHindi': 'हिन्दी (Hindi)',
      'languageBengali': 'বাংলা (Bengali)',
      'languageSaved': 'ভাষা সফলভাবে পরিবর্তিত হয়েছে',

      // Onboarding & Login
      'welcomeTitle': 'স্বাস্থ্যসেবা আপনার হাতের নাগালে',
      'welcomeSubtitle':
          'আপনার এবং আপনার পরিবারের জন্য তাৎক্ষণিক প্রাথমিক চিকিৎসা, এআই স্বাস্থ্য সহায়তা এবং নিকটস্থ ডাক্তার খোঁজার সুবিধা।',
      'getStarted': 'শুরু করুন',
      'loginTitle': 'মোবাইল নম্বর লিখুন',
      'loginSubtitle':
          'আমরা আপনার ফোনে একটি ৬-সংখ্যার যাচাইকরণ কোড পাঠাব।',
      'phoneLabel': 'ফোন নম্বর',
      'phoneHint': '১০-সংখ্যার মোবাইল নম্বর',
      'sendOtp': 'যাচাইকরণ কোড পাঠান',
      'enterOtp': '৬-সংখ্যার কোড লিখুন',
      'otpSubtitle': 'কোড পাঠানো হয়েছে: +91 ',
      'verifyOtp': 'যাচাই করুন এবং লগইন করুন',
      'resendOtp': 'কোড পুনরায় পাঠান',
      'resendIn': '{seconds} সেকেন্ডে পুনরায় পাঠান',

      // Home Screen
      'greeting': 'নমস্কার, {name}',
      'homeEmergencyBanner': 'জরুরি সহায়তা (১০৮)',
      'homeAiPrompt': 'এআই স্বাস্থ্য সহকারীকে জিজ্ঞাসা করুন',
      'homeAiSubtitle': 'আপনার নিজের ভাষায় লক্ষণগুলি বর্ণনা করুন',
      'homePregnancyTitle': 'মাতৃ ও শিশু যত্ন',
      'homePregnancySubtitle': 'গর্ভাবস্থা পর্যবেক্ষণ ও প্রসবোত্তর পরামর্শ',
      'homeNearbyCareTitle': 'নিকটস্থ হাসপাতাল ও ক্লিনিক',
      'homeNearbyCareSubtitle': 'ডাক্তার, ক্লিনিক এবং জরুরি সেবা খুঁজুন',
      'homeHealthRecords': 'আমার স্বাস্থ্য রেকর্ড',
      'homeQuickActions': 'দ্রুত পদক্ষেপ',

      // AI Health Assistant
      'aiAssistantTitle': 'এআই স্বাস্থ্য সহকারী',
      'aiHealthHelp': 'এআই স্বাস্থ্য সাহায্য',
      'onlineAssistant': 'অনলাইন সহকারী',
      'offlineKnowledge': 'অফলাইন তথ্য',
      'clinicalNotice': 'চিকিৎসাগত বিজ্ঞপ্তি',
      'iUnderstand': 'বুঝেছি',
      'clearChatHistory': 'চ্যাট হিস্ট্রি মুছুন',
      'clearChatConfirm':
          'আপনি কি নিশ্চিত যে আপনি এআই সহকারীর সাথে আপনার কথোপকথনের ইতিহাস মুছে ফেলতে চান?',
      'commonHealthTopics': 'সাধারণ স্বাস্থ্য সংক্রান্ত বিষয়',
      'aiTopicFever': 'জ্বর ও সর্দি',
      'aiTopicFeverPrompt':
          'বাড়িতে নিরাপদে জ্বর ও সর্দির যত্ন কীভাবে নেবেন?',
      'aiTopicOrs': 'ওআরএস (ORS) তৈরি',
      'aiTopicOrsPrompt':
          'বাড়িতে ওআরএস দ্রবণ কীভাবে তৈরি করবেন?',
      'aiTopicFirstAid': 'প্রাথমিক চিকিৎসা',
      'aiTopicFirstAidPrompt':
          'কাটাছেঁড়া বা পোড়ার ক্ষেত্রে প্রাথমিক চিকিৎসা কী?',
      'aiTopicNearestPhc': 'নিকটস্থ স্বাস্থ্যকেন্দ্র',
      'aiTopicNearestPhcPrompt':
          'নিকটস্থ প্রাথমিক স্বাস্থ্যকেন্দ্র (PHC) কীভাবে খুঁজবেন?',
      'aiTopicBp': 'রক্তচাপের টিপস',
      'aiTopicBpPrompt':
          'রক্তচাপ নিয়ন্ত্রণে রাখার স্বাস্থ্যকর নিয়মাবলী কী?',
      'messageCopied': 'বার্তাটি ক্লিপবোর্ডে কপি করা হয়েছে',
      'aiDisclaimer': 'এআই স্বাস্থ্য সহকারী — কোনো ডাক্তার নয়',
      'aiInputPlaceholder': 'লক্ষণ লিখুন বা স্বাস্থ্য সম্পর্কিত প্রশ্ন জিজ্ঞাসা করুন...',
      'aiEmergencyWarning':
          'যদি আপনার তীব্র বুকে ব্যথা, শ্বাসকষ্ট বা অতিরিক্ত রক্তপাত হয়, তবে অবিলম্বে ১০৮ এ কল করুন।',
      'aiWelcomeMessage':
          'নমস্কার! আমি আপনার রুরালকেয়ার এআই স্বাস্থ্য সহকারী। আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি? মনে রাখবেন, আমি পরামর্শ প্রদান করি, কোনো চিকিৎসাগত রোগ নির্ণয় নয়।',
      'suggestedQuestion1': 'জ্বরের জন্য আমার কী করা উচিত?',
      'suggestedQuestion2': 'কাশির জন্য কখন ডাক্তারের কাছে যাওয়া উচিত?',
      'suggestedQuestion3': 'গর্ভাবস্থায় কী ধরনের খাবার খাওয়া উচিত?',
      'suggestedQuestion4': 'সামান্য পুড়ে যাওয়ার প্রাথমিক চিকিৎসা',

      // Emergency & First Aid
      'emergencyTitle': 'জরুরি সহায়তা',
      'emergencySubtitle': 'সংকটাপন্ন পরিস্থিতিতে তাৎক্ষণিক পদক্ষেপ',
      'callAmbulance': 'অ্যাম্বুলেন্স কল করুন (১০৮)',
      'callNationalEmergency': 'জাতীয় জরুরি সেবা (১১২)',
      'callWomenHelpline': 'মহিলা হেল্পলাইন (১০৯১)',
      'firstAidTitle': 'অফলাইন প্রাথমিক চিকিৎসা গাইড',
      'firstAidSubtitle': 'ইন্টারনেট ছাড়াই ধাপে ধাপে নির্দেশিকা',
      'firstAidWarning': 'প্রাথমিক চিকিৎসা দেওয়ার পাশাপাশি অবিলম্বে ডাক্তার ডাকুন',
      'emergencyHelp': 'জরুরি সাহায্য',
      'emergencyHelpDesc':
          'জরুরি চিকিৎসার ধরন বেছে নিন বা সরাসরি ১০৮ ডায়াল করুন।\nসমস্ত প্রাথমিক চিকিৎসার নির্দেশিকা ১০০% অফলাইনে কাজ করে।',
      'findNearestEmergencyFacility': 'নিকটস্থ জরুরি হাসপাতাল খুঁজুন',
      'firstAidGuide': 'ফার্স্ট এইড গাইড',
      'offlineEmergencyModeAndStorage': 'অফলাইন জরুরি মোড ও স্টোরেজ',
      'offlineModeBanner': 'অফলাইন মোড — জরুরি সামগ্রী ডিভাইসে লোড করা আছে',
      'call108Subtitle': 'সারা ভারত অ্যাম্বুলেন্স পরিষেবা · ১০৮',
      'call108Now': 'এখনই ১০৮ অ্যাম্বুলেন্সে কল করুন',
      'findEmergencyFacility': 'নিকটস্থ জরুরি হাসপাতাল খুঁজুন',
      'stepByStep': 'ধাপে ধাপে',
      'stepNumber': 'ধাপ {step}',
      'stepOfTotal': 'ধাপ {step} / {total}',
      'previousStep': 'পূর্ববর্তী ধাপ',
      'nextStepLabel': 'পরবর্তী ধাপ ({step}/{total})',
      'dos': 'করণীয়',
      'donts': 'বর্জনীয়',
      'dosTitle': 'করণীয় (প্রয়োজনীয় পদক্ষেপ)',
      'dontsTitle': 'বর্জনীয় (ক্ষতিকর কাজ)',
      'highUrgency': 'অত্যন্ত জরুরি',
      'mediumUrgency': 'জরুরি',
      'lowUrgency': 'সাধারণ',
      'clearChat': 'চ্যাট মুছুন',
      'medicalDisclaimer': 'চিকিৎসাগত সতর্কতা',
      'offlineAiNotice':
          'অফলাইন মোড — সাধারণ জরুরি ও প্রাথমিক চিকিৎসা নির্দেশিকা উপলব্ধ',

      // Pregnancy Care
      'pregnancyTitle': 'মাতৃ ও শিশু যত্ন',
      'pregnancyDashboard': 'গর্ভাবস্থা ড্যাশবোর্ড',
      'currentWeek': '{week} তম সপ্তাহ',
      'trimester1': '১ম ত্রৈমাসিক (1st Trimester)',
      'trimester2': '২য় ত্রৈমাসিক (2nd Trimester)',
      'trimester3': '৩য় ত্রৈমাসিক (3rd Trimester)',
      'trimesterWeeks': '{range} সপ্তাহ',
      'dueDate': 'প্রসবের সম্ভাব্য তারিখ',
      'daysRemaining': '{days} দিন বাকি',
      'editDueDate': 'তারিখ পরিবর্তন করুন',
      'saveDueDate': 'তারিখ সংরক্ষণ করুন',
      'enterEddOrLmp': 'গর্ভাবস্থার সময়রেখা নির্ধারণ করুন',
      'selectDueDate': 'প্রসবের সম্ভাব্য তারিখ (EDD) নির্বাচন করুন',
      'selectLmpDate': 'শেষ মাসিকের তারিখ (LMP) নির্বাচন করুন',
      'orCalculateFromLmp': 'অথবা শেষ মাসিক (LMP) থেকে গণনা করুন',
      'antenatalCare': 'গর্ভকালীন চেকআপ (ANC)',
      'nextAncVisit': 'পরবর্তী গর্ভকালীন চেকআপ (ANC)',
      'setReminder': 'রিমাইন্ডার সেট করুন',
      'reminderSet': 'রিমাইন্ডার সেট করা আছে',
      'viewAncSchedule': 'সম্পূর্ণ ANC তালিকা দেখুন',
      'allAncVisits': 'গর্ভকালীন চেকআপ (ANC) সময়সূচী',
      'ancVisitNumber': 'চেকআপ {number}',
      'ancCompleted': 'সম্পন্ন',
      'ancPending': 'আসন্ন',
      'testsProcedures': 'প্রয়োজনীয় পরীক্ষা ও ওষুধ',
      'nutritionGuide': 'পুষ্টি ও সুস্থতা',
      'stageGuidance': 'ত্রৈমাসিক ভিত্তিক পরামর্শ',
      'tabNutrition': 'পুষ্টি',
      'tabWellness': 'সুস্থতা ও বিশ্রাম',
      'tabMedical': 'পরীক্ষা ও টিকা',
      'tabBirthPrep': 'প্রসব প্রস্তুতি',
      'warningSigns': 'বিপদের লক্ষণ',
      'emergencyCare': 'জরুরি সেবা',
      'seekImmediateMedicalCare': 'অবিলম্বে জরুরি চিকিৎসা সেবা নিন',
      'findNearestHospitalOr108': 'নিকটস্থ হাসপাতাল খুঁজুন / ১০৮ কল করুন',
      'dangerSigns': 'মারাত্মক বিপদের লক্ষণ',
      'symptomsChecklist': 'লক্ষণ পর্যবেক্ষণ',
      'commonSymptoms': 'সাধারণ লক্ষণ',
      'askPregnancyAi': 'এআই গর্ভাবস্থা সহায়ককে জিজ্ঞাসা করুন',
      'askAiPregnancySubtitle': 'পুষ্টি, লক্ষণ বা চেকআপ সম্পর্কিত প্রশ্ন করুন',
      'aiPregnancyDisclaimer': 'এআই স্বাস্থ্য সহায়ক · ডাক্তার নয় · শুধুমাত্র নির্দেশনামূলক',
      'babyCare': 'নবজাতক ও শিশুর যত্ন',
      'postnatalCare': 'প্রসবোত্তর যত্ন',
      'pregnancyWarningText':
          'অতিরিক্ত রক্তপাত, তীব্র মাথাব্যথা, পেটে তীব্র ব্যথা বা হঠাৎ ফোলাভাব দেখা দিলে অবিলম্বে ডাক্তারের সাথে যোগাযোগ করুন।',
      'pregnancyProfileUpdated': 'গর্ভাবস্থার সময়রেখা সফলভাবে আপডেট হয়েছে',

      // Find Care / GPS
      'fetchingOsmData': 'লাইভ স্বাস্থ্য তথ্য লোড হচ্ছে',
      'queryingOsmSubtitle':
          'OpenStreetMap ও নিকটবর্তী স্বাস্থ্যকেন্দ্র থেকে তথ্য সংগ্রহ করা হচ্ছে...',
      'findCareTitle': 'নিকটস্থ স্বাস্থ্যসেবা প্রতিষ্ঠান',
      'findHealthcare': 'স্বাস্থ্যসেবা খুঁজুন',
      'findCareSubtitle': 'আপনার কাছাকাছি হাসপাতাল, ক্লিনিক এবং ডাক্তার',
      'findADoctor': 'ডাক্তার খুঁজুন',
      'findDoctorSubtitle': 'বিশেষজ্ঞতা, হাসপাতাল বা নাম অনুসারে খুঁজুন',
      'doctorProfileTitle': 'ডাক্তার প্রোফাইল',
      'searchFacilitiesHint': 'স্বাস্থ্যকেন্দ্র, স্থান বা সেবা খুঁজুন...',
      'searchDoctorsHint': 'ডাক্তারের নাম বা বিশেষজ্ঞতা দিয়ে খুঁজুন...',
      'filterAll': 'সব',
      'hospitals': 'হাসপাতাল',
      'clinics': 'ক্লিনিক',
      'doctors': 'ডাক্তার',
      'pharmacies': 'ওষুধের দোকান',
      'maternalCare': 'মাতৃ যত্ন',
      'emergency24x7': '২৪x৭ জরুরি',
      'emergencyTriageBanner':
          'জরুরি মোড সক্রিয় • ২৪x৭ জরুরি হাসপাতালগুলিকে অগ্রাধিকার দেওয়া হচ্ছে',
      'call108Ambulance': '১০৮ অ্যাম্বুলেন্সে কল করুন',
      'priorityTriage': 'অগ্রাধিকার ট্রায়াজ',
      'detectedLocation': 'শনাক্ত করা অবস্থান',
      'nearLocation': '{location}-এর কাছে',
      'refreshLocation': 'রিফ্রেশ করুন',
      'locationPermissionDenied': 'অবস্থানের অনুমতি প্রত্যাখ্যান করা হয়েছে',
      'openSettings': 'সেটিংস খুলুন',
      'distanceKm': '{distance} কিমি দূরে',
      'permissionRequired': 'অবস্থান অনুমতি প্রয়োজন',
      'permissionExpl':
          'কাছাকাছি হাসপাতাল এবং ডাক্তার খুঁজতে আপনার অবস্থানের অনুমতি দিন।',
      'grantPermission': 'অনুমতি দিন',
      'gpsDisabled': 'অবস্থান পরিষেবা (GPS) বন্ধ রয়েছে',
      'enableGps': 'GPS চালু করুন',
      'noFacilitiesFound': 'কোনো স্বাস্থ্যসেবা প্রতিষ্ঠান পাওয়া যায়নি',
      'adjustFiltersHint':
          'আপনার অনুসন্ধান বা ফিল্টার পরিবর্তন করে চেষ্টা করুন।',
      'noDoctorsFound': 'কোনো ডাক্তার পাওয়া যায়নি',
      'adjustDoctorSearchHint':
          'অন্য কোনো নাম বা বিশেষজ্ঞতা দিয়ে অনুসন্ধান করুন।',
      'statusOpen': 'খোলা',
      'statusClosed': 'বন্ধ',
      'callFacility': 'স্বাস্থ্যকেন্দ্রে কল করুন',
      'callPhone': '{phone}-এ কল করুন',
      'online': 'অনলাইন',
      'nextAvailableSlot': 'পরবর্তী উপলব্ধ সময় (Slot)',
      'onlineConsultationAvailable': 'অনলাইন পরামর্শ উপলব্ধ',
      'videoCallFromPhone': 'আপনার ফোন থেকে ভিডিও কল করুন',
      'bookAppointment': 'অ্যাপয়েন্টমেন্ট বুক করুন',
      'startVideoConsultation': 'ভিডিও পরামর্শ শুরু করুন',
      'confirmConsultation': 'পরামর্শ নিশ্চিত করুন',
      'scheduleConsultationWith':
          '{facility}-এ {name}-এর সাথে পরামর্শ নির্ধারণ করুন',
      'slotLabel': 'সময় (Slot): {slot}',
      'confirmBooking': 'বুকিং নিশ্চিত করুন',
      'appointmentConfirmedMsg':
          '{slot}-এর জন্য {name}-এর সাথে অ্যাপয়েন্টমেন্ট নিশ্চিত হয়েছে',
      'nearbyHealthcare': 'নিকটস্থ স্বাস্থ্যসেবা',
      'allCategories': 'সব',
      'emergencyCategory': '২৪x৭ জরুরি',
      'facilitiesFound': 'সুবিধা পাওয়া গেছে',
      'showList': 'তালিকা',
      'showMap': 'মানচিত্র',
      'expand': 'বড় করুন',
      'collapse': 'সংক্ষেপ করুন',
      'gpsActive': 'জিপিএস সক্রিয়',
      'turnOnGps': 'GPS চালু করুন',
      'gpsDisabledHint': 'নিকটস্থ স্বাস্থ্যকেন্দ্র দেখতে ডিভাইসের লোকেশন চালু করুন।',
      'locationPermissionHint':
          'সঠিক নিকটস্থ হাসপাতাল দেখাতে লোকেশন অনুমতি প্রয়োজন।',
      'enable': 'সক্রিয় করুন',
      'noHealthcareFound': 'কোনো স্বাস্থ্যসেবা পাওয়া যায়নি',
      'noHealthcareHint':
          'অনুসন্ধানের পরিধি বৃদ্ধি করুন অথবা ক্যাটাগরি ফিল্টার পরিবর্তন করুন।',
      'openNow': 'এখন খোলা',
      'closed': 'বন্ধ',
      'facilityDetails': 'স্বাস্থ্যকেন্দ্র বিবরণ',
      'viewInFullMap': 'সম্পূর্ণ মানচিত্রে দেখুন',
      'contactNumber': 'যোগাযোগের নম্বর',
      'timing': 'খোলার সময়',
      'verifiedServices': 'যাচাইকৃত সেবাসমূহ',
      'directionsTo': 'পথনির্দেশ:',
      'fastestRoute': 'সবচেয়ে দ্রুত রুট',
      'startGoogleMapsNavigation': 'গুগল ম্যাপস নেভিগেশন শুরু করুন',
      'changeArea': 'এলাকা পরিবর্তন করুন',
      'selectArea': 'অনুসন্ধান এলাকা নির্বাচন করুন',
      'searchAreaHint': 'শহর, নগর বা জেলা অনুসন্ধান করুন...',
      'useLiveGps': 'লাইভ জিপিএস অবস্থান ব্যবহার করুন',
      'searchThisArea': 'এই এলাকায় অনুসন্ধান করুন',
      'popularAreas': 'জনপ্রিয় এলাকা ও শহর',
      'reviews': 'পর্যালোচনা',
      'copiedToClipboard': 'ক্লিপবোর্ডে কপি করা হয়েছে',
      'share': 'শেয়ার করুন',
      'sort': 'সাজান',
      'rating': 'রেটিং',
      'distance': 'দূরত্ব',
      'address': 'ঠিকানা',
      'verified': 'যাচাইকৃত',
      'showMap': 'মানচিত্র',
      'showList': 'তালিকা',
      'expand': 'প্রসারিত করুন',
      'collapse': 'সংকুচিত করুন',

      // Health Records
      'recordsTitle': 'স্বাস্থ্য রেকর্ড',
      'myHealthRecords': 'আমার স্বাস্থ্য রেকর্ড',
      'healthTimeline': 'স্বাস্থ্য টাইমলাইন',
      'healthTimelineSubtitle': 'আপনার সম্পূর্ণ স্বাস্থ্য ইতিহাস',
      'prescriptions': 'প্রেসক্রিপশন',
      'activePrescriptionsCount': '{count}টি সক্রিয় প্রেসক্রিপশন',
      'labReports': 'ল্যাব রিপোর্ট',
      'diagnosticReportsCount': '{count}টি ল্যাব রিপোর্ট',
      'referrals': 'রেফারেল',
      'referralTrackingCount': '{count}টি রেফারেল রেকর্ড',
      'consultations': 'পরামর্শ বিবরণী',
      'consultationsCount': '{count}টি ডাক্তারের পরামর্শ ও সারাংশ',
      'documents': 'নথিপত্র',
      'uploadedDocuments': 'আপলোড করা নথিপত্র',
      'uploadedDocumentsCount': '{count}টি আপলোড করা নথি',
      'uploadDocsSubtitle': 'প্রেসক্রিপশন, রিপোর্ট এবং স্ক্যান আপলোড করুন',
      'uploadDocument': 'নথি আপলোড করুন',
      'emptyRecords': 'কোনো রেকর্ড পাওয়া যায়নি',
      'searchPrescriptionsHint': 'ডাক্তার বা ওষুধের নাম দিয়ে অনুসন্ধান করুন...',
      'searchLabReportsHint': 'টেস্ট বা ডাক্তারের নাম দিয়ে অনুসন্ধান করুন...',
      'searchReferralsHint': 'রেফারেল অনুসন্ধান করুন...',
      'searchConsultationsHint': 'পরামর্শ অনুসন্ধান করুন...',
      'noLabReportsFound': 'কোনো ল্যাব রিপোর্ট পাওয়া যায়নি',
      'noReferralsFound': 'কোনো রেফারেল পাওয়া যায়নি',
      'noConsultationsFound': 'কোনো পরামর্শ পাওয়া যায়নি',
      'noDocumentsFound': 'কোনো নথি পাওয়া যায়নি',
      'noTimelineEventsFound': 'কোনো টাইমলাইন তথ্য পাওয়া যায়নি',

      // Quick Action Tool Names
      'actionAskAi': 'এআই\nপরামর্শ',
      'actionTalkDoctor': 'ডাক্তারের\nপরামর্শ',
      'actionFindFacility': 'হাসপাতাল\nখুঁজুন',
      'actionHealthRecords': 'স্বাস্থ্য\nরেকর্ড',
      'actionUploadDocs': 'ডকুমেন্ট\nআপলোড',
      'actionFindDoctor': 'ডাক্তার\nখুঁজুন',

      // Home Screen Details
      'healthProfile': 'স্বাস্থ্য প্রোফাইল',
      'recentPrescriptions': 'সাম্প্রতিক প্রেসক্রিপশন',
      'activeReferrals': 'সক্রিয় রেফারেল',
      'seeAll': 'সব দেখুন',
      'noPrescriptionsFound': 'কোনো প্রেসক্রিপশন পাওয়া যায়নি',
      'medicinesCount': '{count}টি ওষুধ',
      'noneRecorded': 'কিছু নথিভুক্ত নেই',
      'noKnownAllergies': 'কোনো পরিচিত অ্যালার্জি নেই',
      'dontKnow': 'জানা নেই',
      'notSpecified': 'নির্দিষ্ট নয়',
      'yearsOld': '{age} বছর',

      // Profile & Settings
      'profileTitle': 'রোগীর প্রোফাইল',
      'editProfile': 'প্রোফাইল সম্পাদনা',
      'personalDetails': 'ব্যক্তিগত বিবরণ',
      'name': 'নাম',
      'age': 'বয়স',
      'gender': 'লিঙ্গ',
      'bloodGroup': 'রক্তের গ্রুপ',
      'allergies': 'অ্যালার্জি',
      'chronicConditions': 'দীর্ঘস্থায়ী অসুস্থতা',
      'emergencyContact': 'জরুরি যোগাযোগ',
      'settings': 'সেটিংস',
      'appLanguage': 'অ্যাপের ভাষা',
      'offlineEmergencyContent': 'অফলাইন জরুরি সামগ্রী',
      'offlineEmergencySubtitle': 'ইন্টারনেট ছাড়া ব্যবহারের জন্য ডাউনলোড করুন',
      'notifications': 'বিজ্ঞপ্তি',
      'notificationsSubtitle': 'অ্যাপয়েন্টমেন্ট ও স্বাস্থ্য অনুস্মারক',
      'logout': 'লগআউট',
      'logoutConfirm': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',

      // Appointments & Queue Management (Demo)
      'bookAppointment': 'অ্যাপয়েন্টমেন্ট বুক করুন',
      'confirmAppointment': 'অ্যাপয়েন্টমেন্ট নিশ্চিতকরণ',
      'appointmentConfirmed': 'অ্যাপয়েন্টমেন্ট নিশ্চিত হয়েছে',
      'myAppointments': 'আমার অ্যাপয়েন্টমেন্ট',
      'myQueue': 'আমার কিউ',
      'appointmentDetails': 'অ্যাপয়েন্টমেন্টের বিবরণ',
      'checkIn': 'চেক ইন (Check In)',
      'checkInNow': 'এখনই চেক ইন করুন',
      'checkedIn': 'চেক ইন সম্পন্ন',
      'viewLiveQueue': 'লাইভ কিউ দেখুন',
      'viewAppointment': 'অ্যাপয়েন্টমেন্ট দেখুন',
      'viewDetails': 'বিবরণ দেখুন',
      'selectDate': 'তারিখ নির্বাচন করুন',
      'availableTime': 'উপলব্ধ সময়',
      'confirmBooking': 'বুকিং নিশ্চিত করুন',
      'upcoming': 'আসন্ন',
      'noUpcomingAppointments': 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই',
      'findHealthcare': 'স্বাস্থ্যসেবা খুঁজুন',
      'demoQueueControls': 'ডেমো কিউ কন্ট্রোল',
      'demoMode': 'ডেমো মোড',
      'demoQueueNote': 'ডেমো প্রদর্শনের জন্য কিউ সিমুলেট করা যাবে।',
      'simulateNextPatient': 'পরবর্তী রোগী সিমুলেট করুন',
      'yourToken': 'আপনার টোকেন',
      'currentlyServing': 'বর্তমান সেবাগ্রহণকারী',
      'patientsAhead': 'জন রোগী এগিয়ে আছেন',
      'estimatedWait': 'আনুমানিক অপেক্ষার সময়',
      'queueActive': 'কিউ সক্রিয় রয়েছে',
      'yourTurnApproaching': 'আপনার পালা আসন্ন!',
      'stayNearConsultation': 'অনুগ্রহ করে পরামর্শ কক্ষের কাছেই থাকুন।',
      'itsYourTurn': 'আপনার পালা এসেছে!',
      'proceedToConsultation': 'অনুগ্রহ করে পরামর্শ কক্ষে প্রবেশ করুন।',
      'queueCalled': 'ডাকা হয়েছে (CALLED)',
      'queueNext': 'পরবর্তী পালা আপনার',
      'specialty': 'বিশেষজ্ঞতা',
      'clinic': 'ক্লিনিক',
      'date': 'তারিখ',
      'time': 'সময়',
      'doctor': 'ডাক্তার',
      'appointmentId': 'অ্যাপয়েন্টমেন্ট আইডি',
      'status': 'স্থিতি',
      'confirmed': 'নিশ্চিত',

      // Registration & Profile Enhancements
      'step1Of2': 'ধাপ ১/২: প্রাথমিক বিবরণ',
      'step2Of2': 'ধাপ ২/২: স্বাস্থ্য বিবরণ',
      'preferredLanguage': 'পছন্দের ভাষা',
      'genderFemale': 'মহিলা',
      'genderMale': 'পুরুষ',
      'genderOther': 'অন্যান্য',
      'areYouPregnant': 'আপনি কি বর্তমানে গর্ভবতী?',
      'yesPregnant': 'হ্যাঁ, বর্তমানে গর্ভবতী',
      'notPregnant': 'না',
      'pregnancyMonth': 'গর্ভাবস্থার মাস',
      'gestationalWeekLabel': 'গর্ভাবস্থার সপ্তাহ',
      'estimatedDueDate': 'প্রসবের সম্ভাব্য তারিখ (EDD)',
      'firstTrimester': 'প্রথম ট্রাইমেস্টার (১–১২ সপ্তাহ)',
      'secondTrimester': 'দ্বিতীয় ট্রাইমেস্টার (১৩–২৭ সপ্তাহ)',
      'thirdTrimester': 'তৃতীয় ট্রাইমেস্টার (২৮–৪০+ সপ্তাহ)',
      'emergencyContactSection': 'জরুরি যোগাযোগ (পরামর্শিত)',
      'emergencyContactNameLabel': 'যোগাযোগের ব্যক্তির নাম',
      'emergencyContactPhoneLabel': 'জরুরি মোবাইল নম্বর',
      'emergencyContactHint': 'আত্মীয়, প্রতিবেশী বা আশা কর্মী',
      'abhaIdLabel': 'আভা (ABHA) স্বাস্থ্য আইডি (ঐচ্ছিক)',
      'abhaIdHint': '১৪ সংখ্যার আয়ুষ্মান ভারত নম্বর',
      'villageLabel': 'গ্রাম / শহর',
      'districtLabel': 'জেলা',
      'stateLabel': 'রাজ্য',
      'pincodeLabel': 'পিনকোড',
      'completeRegistration': 'নিবন্ধন সম্পন্ন করে এগিয়ে যান',
    },
  };

  /// Translate key with fallback to English
  String translate(String key, {Map<String, String>? params}) {
    final langCode = locale.languageCode;
    String value = _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  // Common Getters
  String get appName => translate('appName');
  String get tagline => translate('tagline');
  String get loading => translate('loading');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get retry => translate('retry');
  String get continueBtn => translate('continueBtn');
  String get submit => translate('submit');
  String get back => translate('back');
  String get close => translate('close');
  String get search => translate('search');
  String get call => translate('call');
  String get directions => translate('directions');
  String get getDirections => translate('getDirections');
  String get viewAll => translate('viewAll');
  String get details => translate('details');
  String get noInternet => translate('noInternet');
  String get offlineBannerMsg => translate('offlineBannerMsg');

  // Navigation
  String get navHome => translate('navHome');
  String get navEmergency => translate('navEmergency');
  String get navAiAssistant => translate('navAiAssistant');
  String get navPregnancy => translate('navPregnancy');
  String get navFindCare => translate('navFindCare');
  String get navRecords => translate('navRecords');
  String get navProfile => translate('navProfile');

  // Language
  String get selectLanguage => translate('selectLanguage');
  String get changeLanguage => translate('changeLanguage');
  String get languageSaved => translate('languageSaved');

  // Onboarding & Login
  String get welcomeTitle => translate('welcomeTitle');
  String get welcomeSubtitle => translate('welcomeSubtitle');
  String get getStarted => translate('getStarted');
  String get loginTitle => translate('loginTitle');
  String get loginSubtitle => translate('loginSubtitle');
  String get phoneLabel => translate('phoneLabel');
  String get phoneHint => translate('phoneHint');
  String get sendOtp => translate('sendOtp');
  String get enterOtp => translate('enterOtp');
  String get otpSubtitle => translate('otpSubtitle');
  String get verifyOtp => translate('verifyOtp');
  String get resendOtp => translate('resendOtp');
  String resendIn(int seconds) =>
      translate('resendIn', params: {'seconds': '$seconds'});

  // Home
  String greeting(String name) =>
      translate('greeting', params: {'name': name});
  String get homeEmergencyBanner => translate('homeEmergencyBanner');
  String get homeAiPrompt => translate('homeAiPrompt');
  String get homeAiSubtitle => translate('homeAiSubtitle');
  String get homePregnancyTitle => translate('homePregnancyTitle');
  String get homePregnancySubtitle => translate('homePregnancySubtitle');
  String get homeNearbyCareTitle => translate('homeNearbyCareTitle');
  String get homeNearbyCareSubtitle => translate('homeNearbyCareSubtitle');
  String get homeHealthRecords => translate('homeHealthRecords');
  String get homeQuickActions => translate('homeQuickActions');

  // Quick Action Tool Names
  String get actionAskAi => translate('actionAskAi');
  String get actionTalkDoctor => translate('actionTalkDoctor');
  String get actionFindFacility => translate('actionFindFacility');
  String get actionHealthRecords => translate('actionHealthRecords');
  String get actionUploadDocs => translate('actionUploadDocs');
  String get actionFindDoctor => translate('actionFindDoctor');

  // Home Screen Details
  String get healthProfile => translate('healthProfile');
  String get recentPrescriptions => translate('recentPrescriptions');
  String get activeReferrals => translate('activeReferrals');
  String get seeAll => translate('seeAll');
  String get noPrescriptionsFound => translate('noPrescriptionsFound');
  String medicinesCount(int count) =>
      translate('medicinesCount', params: {'count': '$count'});
  String get noneRecorded => translate('noneRecorded');
  String get noKnownAllergies => translate('noKnownAllergies');
  String get dontKnow => translate('dontKnow');
  String get notSpecified => translate('notSpecified');
  String yearsOld(int age) =>
      translate('yearsOld', params: {'age': '$age'});

  // AI
  String get aiAssistantTitle => translate('aiAssistantTitle');
  String get aiHealthHelp => translate('aiHealthHelp');
  String get onlineAssistant => translate('onlineAssistant');
  String get offlineKnowledge => translate('offlineKnowledge');
  String get clinicalNotice => translate('clinicalNotice');
  String get iUnderstand => translate('iUnderstand');
  String get clearChatHistory => translate('clearChatHistory');
  String get clearChatConfirm => translate('clearChatConfirm');
  String get commonHealthTopics => translate('commonHealthTopics');
  String get aiTopicFever => translate('aiTopicFever');
  String get aiTopicFeverPrompt => translate('aiTopicFeverPrompt');
  String get aiTopicOrs => translate('aiTopicOrs');
  String get aiTopicOrsPrompt => translate('aiTopicOrsPrompt');
  String get aiTopicFirstAid => translate('aiTopicFirstAid');
  String get aiTopicFirstAidPrompt => translate('aiTopicFirstAidPrompt');
  String get aiTopicNearestPhc => translate('aiTopicNearestPhc');
  String get aiTopicNearestPhcPrompt => translate('aiTopicNearestPhcPrompt');
  String get aiTopicBp => translate('aiTopicBp');
  String get aiTopicBpPrompt => translate('aiTopicBpPrompt');
  String get messageCopied => translate('messageCopied');
  String get aiDisclaimer => translate('aiDisclaimer');
  String get aiInputPlaceholder => translate('aiInputPlaceholder');
  String get aiEmergencyWarning => translate('aiEmergencyWarning');
  String get aiWelcomeMessage => translate('aiWelcomeMessage');
  String get suggestedQuestion1 => translate('suggestedQuestion1');
  String get suggestedQuestion2 => translate('suggestedQuestion2');
  String get suggestedQuestion3 => translate('suggestedQuestion3');
  String get suggestedQuestion4 => translate('suggestedQuestion4');
  String get clearChat => translate('clearChat');
  String get medicalDisclaimer => translate('medicalDisclaimer');
  String get offlineAiNotice => translate('offlineAiNotice');

  // Emergency
  String get emergencyTitle => translate('emergencyTitle');
  String get emergencySubtitle => translate('emergencySubtitle');
  String get emergencyHelp => translate('emergencyHelp');
  String get emergencyHelpDesc => translate('emergencyHelpDesc');
  String get callAmbulance => translate('callAmbulance');
  String get callNationalEmergency => translate('callNationalEmergency');
  String get callWomenHelpline => translate('callWomenHelpline');
  String get firstAidTitle => translate('firstAidTitle');
  String get firstAidSubtitle => translate('firstAidSubtitle');
  String get firstAidWarning => translate('firstAidWarning');
  String get findNearestEmergencyFacility =>
      translate('findNearestEmergencyFacility');
  String get firstAidGuide => translate('firstAidGuide');
  String get offlineEmergencyModeAndStorage =>
      translate('offlineEmergencyModeAndStorage');
  String get offlineModeBanner => translate('offlineModeBanner');
  String get call108Subtitle => translate('call108Subtitle');
  String get call108Now => translate('call108Now');
  String get findEmergencyFacility => translate('findEmergencyFacility');
  String get stepByStep => translate('stepByStep');
  String stepNumber(int step) =>
      translate('stepNumber', params: {'step': '$step'});
  String stepOfTotal(int step, int total) =>
      translate('stepOfTotal', params: {'step': '$step', 'total': '$total'});
  String get previousStep => translate('previousStep');
  String nextStepLabel(int step, int total) => translate('nextStepLabel',
      params: {'step': '$step', 'total': '$total'});
  String get dos => translate('dos');
  String get donts => translate('donts');
  String get dosTitle => translate('dosTitle');
  String get dontsTitle => translate('dontsTitle');
  String get highUrgency => translate('highUrgency');
  String get mediumUrgency => translate('mediumUrgency');
  String get lowUrgency => translate('lowUrgency');

  // Pregnancy
  String get pregnancyTitle => translate('pregnancyTitle');
  String get pregnancyDashboard => translate('pregnancyDashboard');
  String currentWeek(int week) =>
      translate('currentWeek', params: {'week': '$week'});
  String get trimester1 => translate('trimester1');
  String get trimester2 => translate('trimester2');
  String get trimester3 => translate('trimester3');
  String trimesterWeeks(String range) =>
      translate('trimesterWeeks', params: {'range': range});
  String get dueDate => translate('dueDate');
  String daysRemaining(int days) =>
      translate('daysRemaining', params: {'days': '$days'});
  String get editDueDate => translate('editDueDate');
  String get saveDueDate => translate('saveDueDate');
  String get enterEddOrLmp => translate('enterEddOrLmp');
  String get selectDueDate => translate('selectDueDate');
  String get selectLmpDate => translate('selectLmpDate');
  String get orCalculateFromLmp => translate('orCalculateFromLmp');
  String get antenatalCare => translate('antenatalCare');
  String get nextAncVisit => translate('nextAncVisit');
  String get setReminder => translate('setReminder');
  String get reminderSet => translate('reminderSet');
  String get viewAncSchedule => translate('viewAncSchedule');
  String get allAncVisits => translate('allAncVisits');
  String ancVisitNumber(int number) =>
      translate('ancVisitNumber', params: {'number': '$number'});
  String get ancCompleted => translate('ancCompleted');
  String get ancPending => translate('ancPending');
  String get testsProcedures => translate('testsProcedures');
  String get nutritionGuide => translate('nutritionGuide');
  String get stageGuidance => translate('stageGuidance');
  String get tabNutrition => translate('tabNutrition');
  String get tabWellness => translate('tabWellness');
  String get tabMedical => translate('tabMedical');
  String get tabBirthPrep => translate('tabBirthPrep');
  String get warningSigns => translate('warningSigns');
  String get emergencyCare => translate('emergencyCare');
  String get seekImmediateMedicalCare => translate('seekImmediateMedicalCare');
  String get findNearestHospitalOr108 => translate('findNearestHospitalOr108');
  String get dangerSigns => translate('dangerSigns');
  String get symptomsChecklist => translate('symptomsChecklist');
  String get commonSymptoms => translate('commonSymptoms');
  String get askPregnancyAi => translate('askPregnancyAi');
  String get askAiPregnancySubtitle => translate('askAiPregnancySubtitle');
  String get aiPregnancyDisclaimer => translate('aiPregnancyDisclaimer');
  String get babyCare => translate('babyCare');
  String get postnatalCare => translate('postnatalCare');
  String get pregnancyWarningText => translate('pregnancyWarningText');
  String get pregnancyProfileUpdated => translate('pregnancyProfileUpdated');

  // Find Care
  String get findCareTitle => translate('findCareTitle');
  String get findHealthcare => translate('findHealthcare');
  String get findCareSubtitle => translate('findCareSubtitle');
  String get findADoctor => translate('findADoctor');
  String get findDoctorSubtitle => translate('findDoctorSubtitle');
  String get doctorProfileTitle => translate('doctorProfileTitle');
  String get searchFacilitiesHint => translate('searchFacilitiesHint');
  String get searchDoctorsHint => translate('searchDoctorsHint');
  String get filterAll => translate('filterAll');
  String get hospitals => translate('hospitals');
  String get clinics => translate('clinics');
  String get doctors => translate('doctors');
  String get pharmacies => translate('pharmacies');
  String get maternalCare => translate('maternalCare');
  String get emergency24x7 => translate('emergency24x7');
  String get emergencyTriageBanner => translate('emergencyTriageBanner');
  String get call108Ambulance => translate('call108Ambulance');
  String get priorityTriage => translate('priorityTriage');
  String get detectedLocation => translate('detectedLocation');
  String nearLocation(String location) =>
      translate('nearLocation', params: {'location': location});
  String get refreshLocation => translate('refreshLocation');
  String get locationPermissionDenied =>
      translate('locationPermissionDenied');
  String get openSettings => translate('openSettings');
  String distanceKm(String distance) =>
      translate('distanceKm', params: {'distance': distance});
  String get permissionRequired => translate('permissionRequired');
  String get permissionExpl => translate('permissionExpl');
  String get grantPermission => translate('grantPermission');
  String get gpsDisabled => translate('gpsDisabled');
  String get enableGps => translate('enableGps');
  String get noFacilitiesFound => translate('noFacilitiesFound');
  String get adjustFiltersHint => translate('adjustFiltersHint');
  String get noDoctorsFound => translate('noDoctorsFound');
  String get adjustDoctorSearchHint => translate('adjustDoctorSearchHint');
  String get statusOpen => translate('statusOpen');
  String get statusClosed => translate('statusClosed');
  String get callFacility => translate('callFacility');
  String callPhone(String phone) =>
      translate('callPhone', params: {'phone': phone});
  String get online => translate('online');
  String get nextAvailableSlot => translate('nextAvailableSlot');
  String get onlineConsultationAvailable =>
      translate('onlineConsultationAvailable');
  String get videoCallFromPhone => translate('videoCallFromPhone');
  String get bookAppointment => translate('bookAppointment');
  String get startVideoConsultation => translate('startVideoConsultation');
  String get confirmConsultation => translate('confirmConsultation');
  String scheduleConsultationWith(String name, String facility) =>
      translate('scheduleConsultationWith',
          params: {'name': name, 'facility': facility});
  String slotLabel(String slot) =>
      translate('slotLabel', params: {'slot': slot});
  String get confirmBooking => translate('confirmBooking');
  String appointmentConfirmedMsg(String name, String slot) =>
      translate('appointmentConfirmedMsg',
          params: {'name': name, 'slot': slot});

  // Health Records
  String get recordsTitle => translate('recordsTitle');
  String get myHealthRecords => translate('myHealthRecords');
  String get healthTimeline => translate('healthTimeline');
  String get healthTimelineSubtitle => translate('healthTimelineSubtitle');
  String get prescriptions => translate('prescriptions');
  String activePrescriptionsCount(int count) =>
      translate('activePrescriptionsCount', params: {'count': '$count'});
  String get labReports => translate('labReports');
  String diagnosticReportsCount(int count) =>
      translate('diagnosticReportsCount', params: {'count': '$count'});
  String get referrals => translate('referrals');
  String referralTrackingCount(int count) =>
      translate('referralTrackingCount', params: {'count': '$count'});
  String get consultations => translate('consultations');
  String consultationsCount(int count) =>
      translate('consultationsCount', params: {'count': '$count'});
  String get documents => translate('documents');
  String get uploadedDocuments => translate('uploadedDocuments');
  String uploadedDocumentsCount(int count) =>
      translate('uploadedDocumentsCount', params: {'count': '$count'});
  String get uploadDocsSubtitle => translate('uploadDocsSubtitle');
  String get uploadDocument => translate('uploadDocument');
  String get emptyRecords => translate('emptyRecords');
  String get searchPrescriptionsHint => translate('searchPrescriptionsHint');
  String get searchLabReportsHint => translate('searchLabReportsHint');
  String get searchReferralsHint => translate('searchReferralsHint');
  String get searchConsultationsHint => translate('searchConsultationsHint');
  String get noLabReportsFound => translate('noLabReportsFound');
  String get noReferralsFound => translate('noReferralsFound');
  String get noConsultationsFound => translate('noConsultationsFound');
  String get noDocumentsFound => translate('noDocumentsFound');
  String get noTimelineEventsFound => translate('noTimelineEventsFound');

  // Profile & Settings
  String get profileTitle => translate('profileTitle');
  String get editProfile => translate('editProfile');
  String get personalDetails => translate('personalDetails');
  String get name => translate('name');
  String get age => translate('age');
  String get gender => translate('gender');
  String get bloodGroup => translate('bloodGroup');
  String get allergies => translate('allergies');
  String get chronicConditions => translate('chronicConditions');
  String get emergencyContact => translate('emergencyContact');
  String get settings => translate('settings');
  String get appLanguage => translate('appLanguage');
  String get offlineEmergencyContent =>
      translate('offlineEmergencyContent');
  String get offlineEmergencySubtitle =>
      translate('offlineEmergencySubtitle');
  String get notifications => translate('notifications');
  String get notificationsSubtitle => translate('notificationsSubtitle');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logoutConfirm');

  // Registration & Onboarding
  String get step1Of2 => translate('step1Of2');
  String get step2Of2 => translate('step2Of2');
  String get preferredLanguage => translate('preferredLanguage');
  String get genderFemale => translate('genderFemale');
  String get genderMale => translate('genderMale');
  String get genderOther => translate('genderOther');
  String get areYouPregnant => translate('areYouPregnant');
  String get yesPregnant => translate('yesPregnant');
  String get notPregnant => translate('notPregnant');
  String get gestationalWeekLabel => translate('gestationalWeekLabel');
  String get estimatedDueDate => translate('estimatedDueDate');
  String get emergencyContactSection => translate('emergencyContactSection');
  String get emergencyContactNameLabel => translate('emergencyContactNameLabel');
  String get emergencyContactPhoneLabel =>
      translate('emergencyContactPhoneLabel');
  String get emergencyContactHint => translate('emergencyContactHint');
  String get abhaIdLabel => translate('abhaIdLabel');
  String get abhaIdHint => translate('abhaIdHint');
  String get villageLabel => translate('villageLabel');
  String get districtLabel => translate('districtLabel');
  String get stateLabel => translate('stateLabel');
  String get pincodeLabel => translate('pincodeLabel');
  String get completeRegistration => translate('completeRegistration');
  String get fetchingOsmData => translate('fetchingOsmData');
  String get queryingOsmSubtitle => translate('queryingOsmSubtitle');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy BuildContext access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
