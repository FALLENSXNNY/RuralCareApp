// Application configuration — environment, API base URL, feature flags
// NEVER place secrets (API keys, credentials) in this file or any Flutter source.
import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  AppConfig._();

  /// Singleton instance.
  static final AppConfig instance = AppConfig._();

  /// Current environment. Set to production for Demo v1 builds connecting to Railway.
  /// Switch to AppEnvironment.development for local localhost/emulator testing.
  static const AppEnvironment environment = AppEnvironment.development;

  /// Whether the app is running in debug/demo mode.
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// Whether to use mock data instead of real API calls.
  /// Set to false now that the backend is live on Railway.
  static const bool useMockData = false;

  /// The LAN IP of the development machine running the backend.
  /// Used when running in development mode on a physical device connected to the same Wi-Fi.
  /// Change this to your machine's local IP address (e.g. 192.168.1.5).
  static const String _devLanIp = '192.168.1.5';

  /// Custom backend URL provided at build/runtime via `--dart-define=BACKEND_URL=...`
  static const String _customBackendUrl = String.fromEnvironment('BACKEND_URL');

  /// Production / Railway deployed backend API URL for RuralCare Demo v1.
  static const String railwayProductionUrl =
      'https://ruralcareapp-production.up.railway.app/api/v1';

  /// Resolves the backend API base URL at runtime based on platform.
  ///
  /// - If --dart-define=BACKEND_URL was supplied, uses that directly.
  /// - Production           → railwayProductionUrl
  /// - Web (Chrome dev)     → http://localhost:3000/api/v1
  /// - Android emulator     → http://10.0.2.2:3000/api/v1 (loopback to host)
  /// - iOS simulator        → http://127.0.0.1:3000/api/v1
  /// - Physical device      → http://<_devLanIp>:3000/api/v1 (LAN IP)
  static String get apiBaseUrl {
    if (_customBackendUrl.isNotEmpty) {
      return _customBackendUrl;
    }

    if (environment == AppEnvironment.production) {
      return railwayProductionUrl;
    }

    // Web — Chrome dev server; backend runs on the same machine.
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }

    // Mobile — use defaultTargetPlatform (works on all non-web targets).
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator loopback to the host machine.
        return 'http://10.0.2.2:3000/api/v1';
      case TargetPlatform.iOS:
        // iOS simulator shares the host network stack.
        return 'http://127.0.0.1:3000/api/v1';
      default:
        // Physical device on the same LAN as the dev machine.
        return 'http://$_devLanIp:3000/api/v1';
    }
  }

  /// Feature flags — enable/disable features during development.
  static const Map<String, bool> featureFlags = {
    'enable_ai_chat': true,
    'enable_emergency': true,
    'enable_facility_finder': true,
    'enable_document_upload': true,
    'enable_teleconsultation': true,
  };

  static bool isFeatureEnabled(String feature) {
    return featureFlags[feature] ?? false;
  }
}
