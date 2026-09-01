// App-wide constants for RuralCare
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'RuralCare';
  static const String appTagline = 'Your Health, Our Care';

  // Emergency
  static const String emergencyNumber = '108'; // Ambulance India
  static const String emergencyNumberLabel = 'Call Ambulance (108)';

  // Touch targets (dp) — enforced by agents.md
  static const double minTouchTarget = 48.0;
  static const double minButtonHeight = 56.0;
  static const double minEmergencyButtonHeight = 80.0;

  // Border radius
  static const double borderRadius = 12.0;

  // Keys for shared_preferences
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyPatientPhone = 'patient_phone';
  static const String keyPatientName = 'patient_name';
  static const String keyOfflineContentDownloaded = 'offline_content_downloaded';

  // AI disclaimer — must appear on every AI output
  static const String aiDisclaimerShort = 'AI Health Assistant — Not a Doctor';
  static const String aiDisclaimerFull =
      'This assistant provides general health information only. '
      'It is not a substitute for professional medical advice, diagnosis, or treatment. '
      'Always seek the advice of a qualified healthcare professional.';

  // Page sizes
  static const int pageSize = 20;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Padding/spacing
  static const double screenPadding = 16.0;
  static const double cardSpacing = 12.0;
}
