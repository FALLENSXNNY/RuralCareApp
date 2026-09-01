// Real API-backed PatientRepository implementation for Phase 3.
//
// All patient data is fetched from / updated on the RuralCare backend via
// [ApiClient]. Authentication is handled by sending the verified Firebase
// ID token as `Authorization: Bearer <id-token>`. The backend derives
// identity from the token — it NEVER trusts patientId/phone sent in the
// request body, so we do not rely on them for identity.
import '../error/app_exception.dart';
import '../models/patient.dart';
import '../networking/api_client.dart';
import '../services/firebase_auth_service.dart';
import '../storage/local_storage_service.dart';
import 'patient_repository.dart';

/// Real implementation of [PatientRepository] backed by the RuralCare API.
class ApiPatientRepository implements PatientRepository {
  ApiPatientRepository(ApiClient apiClient, FirebaseAuthService authService)
    : _apiClient = apiClient,
      _authService = authService;

  final ApiClient _apiClient;
  final FirebaseAuthService _authService;

  @override
  Future<Patient> getCurrentPatient() async {
    try {
      final response = await _apiClient.request(
        '/patients/me',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess) {
        throw _mapResponseError(
            response.statusCode, 'Could not load your profile.');
      }

      final patient = Patient.fromJson(_extractPatient(response.data));
      await savePatientLocally(patient);
      return patient;
    } on AppException catch (e) {
      if (e.type == AppErrorType.network) {
        final cached = getLocalPatient();
        if (cached != null) return cached;
      }
      rethrow;
    } catch (_) {
      final cached = getLocalPatient();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    final response = await _apiClient.request(
      '/patients/me',
      method: ApiMethod.put,
      body: patient.toJson(),
      authToken: await _getIdToken(),
    );

    if (!response.isSuccess) {
      throw _mapResponseError(response.statusCode, 'Could not save your profile.');
    }

    final updated = Patient.fromJson(_extractPatient(response.data));
    await savePatientLocally(updated);
    return updated;
  }

  @override
  Future<void> savePatientLocally(Patient patient) async {
    await LocalStorageService.instance.savePatientProfile(patient);
  }

  @override
  Patient? getLocalPatient() {
    return LocalStorageService.instance.patientProfile;
  }

  /// Resolves the current Firebase user's ID token for backend requests.
  /// Throws [AppException.authentication] if the user is not signed in or the
  /// token cannot be obtained.
  Future<String> _getIdToken() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw AppException.authentication('You are not signed in.');
    }

    // Prefer the cached token (valid ~1h) to avoid redundant TLS refresh
    // calls. Same fix applied in FirebaseAuthService._signInAndExchange.
    String? token = await user.getIdToken(false);
    if (token == null || token.isEmpty) {
      token = await user.getIdToken(true);
    }
    if (token == null || token.isEmpty) {
      throw AppException.authentication('Could not obtain your session token.');
    }
    return token;
  }

  /// Pulls the `patient` object from the API response. Supports both the
  /// canonical `{ patient: {...} }` shape and the wrapped `{ data: {...} }`.
  Map<String, dynamic> _extractPatient(Map<String, dynamic>? data) {
    final raw = (data?['data'] as Map<String, dynamic>?) ?? data ?? const {};
    return (raw['patient'] as Map<String, dynamic>?) ?? raw;
  }

  AppException _mapResponseError(int statusCode, String fallbackMessage) {
    if (statusCode == 401 || statusCode == 403) {
      return AppException.authentication(
          'Your session has expired. Please sign in again.');
    }
    return AppException.server(fallbackMessage);
  }
}