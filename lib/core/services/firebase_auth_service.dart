// Firebase Phone Authentication service for RuralCare.
//
// Flow:
//   1. sendOtp(phone)            → triggers Firebase SMS OTP
//   2. verifyOtp(id, code)       → signs in with credential, returns UserCredential
//   3. exchangeTokenForSession() → sends Firebase ID token to backend /auth/session
//   4. signOut()                 → Firebase sign-out + clears local session cache
//
// All secrets (Gemini key, MongoDB creds) live ONLY on the backend.
// The Flutter app never contacts Gemini or MongoDB directly.

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../models/patient.dart';
import '../storage/local_storage_service.dart';

/// Result returned after a successful OTP verification + backend session exchange.
class AuthResult {
  const AuthResult({
    required this.patientId,
    required this.firebaseUid,
    required this.phone,
    required this.isNewUser,
  });

  /// The backend-assigned MongoDB patient `_id` (null if the patient is new
  /// and has not yet completed registration).
  final String? patientId;

  /// Firebase UID for this user.
  final String firebaseUid;

  /// Phone number used to authenticate.
  final String phone;

  /// True if the backend did not yet have a patient record for this phone.
  /// The app should route new users to the registration flow.
  final bool isNewUser;
}

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    http.Client? httpClient,
  })  : _auth = auth, // ignore: prefer_initializing_formals
        _httpClient = httpClient ?? http.Client();

  final FirebaseAuth? _auth;
  final http.Client _httpClient;

  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  /// Sends an SMS OTP to [phoneNumber].
  ///
  /// [phoneNumber] must be in E.164 format, e.g. `+919876543210`.
  /// [onCodeSent] is called when Firebase sends the verification code and
  ///   provides the [verificationId] that must be passed to [verifyOtp].
  /// [onError] is called on any failure.
  /// [onAutoVerified] is called on Android when Firebase auto-reads the SMS
  ///   and completes verification without user input.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(AppException error) onError,
    void Function(AuthResult result)? onAutoVerified,
  }) async {
    try {
      await _authInstance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // Normal path — user types the OTP manually
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },

        // Android SMS auto-retrieval success
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onAutoVerified == null) return;
          try {
            final result = await _signInAndExchange(
              credential,
              phoneNumber,
              bestEffortBackend: true,
            );
            onAutoVerified(result);
          } on AppException catch (e) {
            onError(e);
          }
        },

        // Firebase rejected the request
        verificationFailed: (FirebaseAuthException e) {
          onError(_mapFirebaseError(e));
        },

        // Timeout — user must request a resend; surface the id via onCodeSent again.
        codeAutoRetrievalTimeout: (String verificationId) {
          onCodeSent(verificationId);
        },

        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      onError(_mapFirebaseError(e));
    } catch (e) {
      onError(AppException.unknown('Failed to send OTP: $e', e));
    }
  }

  /// Verifies the OTP entered by the user.
  ///
  /// [verificationId] is the ID received in [sendOtp]'s `onCodeSent` callback.
  /// [smsCode] is the 6-digit code typed by the user.
  ///
  /// On success, returns an [AuthResult] and persists the session to
  /// [LocalStorageService].
  ///
  /// Throws [AppException] on failure.
  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _signInAndExchange(credential, phoneNumber);
  }

  /// Signs the user out of Firebase and clears the local session cache.
  Future<void> signOut() async {
    await _authInstance.signOut();
    final storage = LocalStorageService.instance;
    await storage.setLoggedIn(false);
    await storage.clearPatientProfile();
    await storage.clearAll();
  }

  /// Returns the currently signed-in [User], or null if not signed in.
  User? get currentUser => _auth?.currentUser ?? (_auth != null ? null : (_authInstanceSafe?.currentUser));

  FirebaseAuth? get _authInstanceSafe {
    try {
      return _authInstance;
    } catch (_) {
      return null;
    }
  }

  /// Stream of Firebase auth state changes — emit null when signed out.
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? (_authInstanceSafe?.authStateChanges() ?? const Stream.empty());

  // ── Internal helpers ───────────────────────────────────────────────────

  Future<AuthResult> _signInAndExchange(
    AuthCredential credential,
    String phoneNumber, {
    bool bestEffortBackend = false,
  }) async {
    try {
      final userCredential = await _authInstance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw AppException.authentication('Firebase sign-in returned no user.');
      }

      // Get the Firebase ID token to send to our backend.
      // Use cached token first (valid ~1h) to avoid redundant TLS refresh calls.
      String? idToken = await user.getIdToken(false);
      if (idToken == null || idToken.isEmpty) {
        idToken = await user.getIdToken(true);
      }
      if (idToken == null) {
        throw AppException.authentication('Could not obtain Firebase ID token.');
      }

      // Exchange the Firebase ID token for a backend session.
      // When [bestEffortBackend] is true (Android SMS auto-verification), a
      // temporarily unavailable backend must NOT block a valid Firebase sign-in:
      // the local session completes and syncs on the next app launch.
      Map<String, dynamic> sessionData;
      try {
        sessionData = await _callBackendSession(idToken);
      } on AppException {
        if (!bestEffortBackend) rethrow;
        sessionData = const {};
      }

      // Persist the session locally (for GoRouter guard + cold start).
      final storage = LocalStorageService.instance;
      await storage.setLoggedIn(true);
      await storage.setFirebaseUid(user.uid);
      await storage.setPatientPhone(phoneNumber);
      if (sessionData['patientId'] != null) {
        await storage.setPatientId(sessionData['patientId'] as String);
      }
      final isNew = sessionData['isNewUser'] as bool? ?? false;
      await storage.setIsNewUser(isNew);

      if (sessionData['patient'] != null && sessionData['patient'] is Map<String, dynamic>) {
        final pMap = sessionData['patient'] as Map<String, dynamic>;
        try {
          final patient = Patient.fromJson(pMap);
          if (patient.name.isNotEmpty) {
            await storage.savePatientProfile(patient);
            await storage.setPatientName(patient.name);
          }
        } catch (_) {}
      }

      return AuthResult(
        patientId: sessionData['patientId'] as String?,
        firebaseUid: user.uid,
        phone: phoneNumber,
        isNewUser: isNew,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown('Authentication failed: $e', e);
    }
  }

  /// Calls `POST /api/v1/auth/session` on the RuralCare backend.
  ///
  /// The backend verifies the Firebase ID token, looks up or creates the
  /// patient record in MongoDB, and returns session metadata.
  Future<Map<String, dynamic>> _callBackendSession(String idToken) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/session');
    try {
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        // Backend derives identity from the token — no sensitive data in body.
        body: jsonEncode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        // Normalize the backend response so downstream code always reads
        // `patientId` + `isNewUser`. Supports the canonical backend shape
        // { isNewUser, patient: { id, ... } }, plus wrapped { data: {...} }
        // and flat { patientId: ... } responses.
        final raw = (body['data'] as Map<String, dynamic>?) ?? body;
        final patient = (raw['patient'] as Map<String, dynamic>?) ?? const {};
        return {
          ...raw,
          'patientId':
              patient['id'] ?? patient['patientId'] ?? raw['patientId'],
          'isNewUser': raw['isNewUser'] ?? false,
        };
      }

      // Backend returned an error
      String message;
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = err['message'] as String? ?? 'Server error ${response.statusCode}';
      } catch (_) {
        message = 'Server error ${response.statusCode}';
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AppException.authentication(message);
      }
      throw AppException.server(message);
    } on AppException {
      rethrow;
    } on http.ClientException catch (e) {
      throw AppException.network('Cannot reach server: ${e.message}', e);
    } catch (e) {
      throw AppException.unknown('Backend session exchange failed: $e', e);
    }
  }

  /// Maps Firebase error codes to user-friendly [AppException]s.
  ///
  /// Messages here are shown verbatim in the UI, so Android-specific codes are
  /// mapped to actionable guidance (SHA fingerprint, Phone provider, Play
  /// Services) instead of a generic "please try again".
  AppException _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return AppException.validation('Please enter a valid phone number.');
      case 'too-many-requests':
        return AppException.authentication(
            'Too many attempts. Please wait a few minutes and try again.');
      case 'invalid-verification-code':
        return AppException.validation('The OTP you entered is incorrect. Please try again.');
      case 'invalid-verification-id':
      case 'session-expired':
        return AppException.authentication('The OTP has expired. Please request a new one.');
      case 'quota-exceeded':
      case 'sms-quota-exceeded':
      case 'billing-not-enabled':
        return AppException.server(
            'SMS quota reached or billing not enabled for SMS delivery on Firebase project. Add number to test numbers or enable Blaze plan.');
      case 'operation-not-allowed':
        return AppException.authentication(
            'Phone sign-in is not enabled for this app. Enable the Phone provider in Firebase Console → Authentication → Sign-in method.');
      case 'invalid-app-credential':
      case 'app-not-authorized':
        return AppException.authentication(
            "This app is not authorized for phone sign-in. Add the app's SHA-1 and SHA-256 fingerprints in Firebase Console → Project settings → Your apps.");
      case 'missing-client-identifier':
      case 'invalid-client-identifier':
        return AppException.authentication(
            'Google Play Services could not verify this device. Use an emulator/device with Google Play installed.');
      case 'captcha-check-failed':
        return AppException.authentication(
            'Verification was blocked. Please try again.');
      case 'network-request-failed':
        return AppException.network('No internet connection. Please check your network.');
      case 'internal-error':
        return AppException.authentication(
            'Phone verification failed on this device. ${e.message ?? ''}'.trim());
      default:
        return AppException.authentication(
            'Authentication failed. Please try again. [${e.code}] ${e.message ?? ''}'
                .trim());
    }
  }
}
