// Real API-backed implementation of FacilityRepository for Phase 5.
// Communicates with backend endpoints (/facilities, /doctors) using bearer auth
// and automatically falls back to MockFacilityRepository on network errors.
import '../error/app_exception.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../networking/api_client.dart';
import '../repositories/mock_repositories.dart';
import '../services/firebase_auth_service.dart';
import 'facility_repository.dart';

class ApiFacilityRepository implements FacilityRepository {
  ApiFacilityRepository(ApiClient apiClient, FirebaseAuthService authService)
      : _apiClient = apiClient,
        _authService = authService,
        _fallback = MockFacilityRepository();

  final ApiClient _apiClient;
  final FirebaseAuthService _authService;
  final MockFacilityRepository _fallback;

  Future<String> _getIdToken() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw AppException.authentication('You are not signed in.');
    }
    String? token = await user.getIdToken(false);
    if (token == null || token.isEmpty) {
      token = await user.getIdToken(true);
    }
    if (token == null || token.isEmpty) {
      throw AppException.authentication('Could not obtain session token.');
    }
    return token;
  }

  @override
  Future<List<HealthcareFacility>> getFacilities() async {
    try {
      final response = await _apiClient.request(
        '/facilities',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getFacilities();
      }

      final list = (response.data!['facilities'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => HealthcareFacility.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getFacilities();
    }
  }

  @override
  Future<List<HealthcareFacility>> searchFacilities(String query) async {
    try {
      final response = await _apiClient.request(
        '/facilities?search=${Uri.encodeQueryComponent(query)}',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.searchFacilities(query);
      }

      final list = (response.data!['facilities'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => HealthcareFacility.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.searchFacilities(query);
    }
  }

  @override
  Future<List<HealthcareFacility>> getFacilitiesByType(String type) async {
    try {
      final response = await _apiClient.request(
        '/facilities?type=${Uri.encodeQueryComponent(type)}',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getFacilitiesByType(type);
      }

      final list = (response.data!['facilities'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => HealthcareFacility.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getFacilitiesByType(type);
    }
  }

  @override
  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _apiClient.request(
        '/doctors',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getDoctors();
      }

      final list = (response.data!['doctors'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => Doctor.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getDoctors();
    }
  }

  @override
  Future<Doctor> getDoctor(String id) async {
    try {
      final response = await _apiClient.request(
        '/doctors/$id',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getDoctor(id);
      }

      final data = (response.data!['doctor'] as Map<String, dynamic>?) ??
          response.data!;
      return Doctor.fromJson(data);
    } catch (_) {
      return await _fallback.getDoctor(id);
    }
  }
}
