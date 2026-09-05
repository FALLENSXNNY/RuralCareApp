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

      final serverPatient = Patient.fromJson(_extractPatient(response.data));
      final cached = getLocalPatient();
      final patient = cached == null
          ? serverPatient
          : cached.copyWith(
              id: serverPatient.id.isNotEmpty ? serverPatient.id : cached.id,
              name: serverPatient.name.isNotEmpty ? serverPatient.name : cached.name,
              phone: serverPatient.phone.isNotEmpty ? serverPatient.phone : cached.phone,
              age: serverPatient.age > 0 ? serverPatient.age : cached.age,
              gender: serverPatient.gender.isNotEmpty ? serverPatient.gender : cached.gender,
              isPregnant: serverPatient.isPregnant || cached.isPregnant,
              gestationalWeek: serverPatient.gestationalWeek ?? cached.gestationalWeek,
              edd: serverPatient.edd ?? cached.edd,
              village: serverPatient.village.isNotEmpty ? serverPatient.village : cached.village,
              district: serverPatient.district.isNotEmpty ? serverPatient.district : cached.district,
              state: serverPatient.state.isNotEmpty ? serverPatient.state : cached.state,
              bloodGroup: serverPatient.bloodGroup.isNotEmpty ? serverPatient.bloodGroup : cached.bloodGroup,
              emergencyContactName: serverPatient.emergencyContactName.isNotEmpty ? serverPatient.emergencyContactName : cached.emergencyContactName,
              emergencyContactPhone: serverPatient.emergencyContactPhone.isNotEmpty ? serverPatient.emergencyContactPhone : cached.emergencyContactPhone,
              abhaId: serverPatient.abhaId.isNotEmpty ? serverPatient.abhaId : cached.abhaId,
              preferredLanguage: serverPatient.preferredLanguage.isNotEmpty ? serverPatient.preferredLanguage : cached.preferredLanguage,
              allergies: serverPatient.allergies.isNotEmpty ? serverPatient.allergies : cached.allergies,
              conditions: serverPatient.conditions.isNotEmpty ? serverPatient.conditions : cached.conditions,
            );
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
    final merged = patient.copyWith(
      id: updated.id.isNotEmpty ? updated.id : patient.id,
      name: updated.name.isNotEmpty ? updated.name : patient.name,
      phone: updated.phone.isNotEmpty ? updated.phone : patient.phone,
      age: updated.age > 0 ? updated.age : patient.age,
      gender: updated.gender.isNotEmpty ? updated.gender : patient.gender,
      isPregnant: patient.isPregnant,
      gestationalWeek: patient.isPregnant
          ? (patient.gestationalWeek ?? updated.gestationalWeek)
          : null,
      edd: patient.edd ?? updated.edd,
      village: updated.village.isNotEmpty ? updated.village : patient.village,
      district: updated.district.isNotEmpty ? updated.district : patient.district,
      state: updated.state.isNotEmpty ? updated.state : patient.state,
      bloodGroup: updated.bloodGroup.isNotEmpty ? updated.bloodGroup : patient.bloodGroup,
      emergencyContactName: updated.emergencyContactName.isNotEmpty ? updated.emergencyContactName : patient.emergencyContactName,
      emergencyContactPhone: updated.emergencyContactPhone.isNotEmpty ? updated.emergencyContactPhone : patient.emergencyContactPhone,
      abhaId: updated.abhaId.isNotEmpty ? updated.abhaId : patient.abhaId,
      preferredLanguage: updated.preferredLanguage.isNotEmpty ? updated.preferredLanguage : patient.preferredLanguage,
      allergies: updated.allergies.isNotEmpty ? updated.allergies : patient.allergies,
      conditions: updated.conditions.isNotEmpty ? updated.conditions : patient.conditions,
    );
    await savePatientLocally(merged);
    return merged;
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