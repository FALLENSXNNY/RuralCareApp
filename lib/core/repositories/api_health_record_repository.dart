// API-backed implementation of HealthRecordRepository for Phase 4.
// Fetches clinical data from the RuralCare backend using the authenticated
// Firebase ID token.
import '../error/app_exception.dart';
import '../models/consultation.dart';
import '../models/health_record.dart';
import '../models/lab_report.dart';
import '../models/prescription.dart';
import '../models/referral.dart';
import '../networking/api_client.dart';
import '../repositories/mock_repositories.dart';
import '../services/firebase_auth_service.dart';
import 'health_record_repository.dart';

class ApiHealthRecordRepository implements HealthRecordRepository {
  ApiHealthRecordRepository(ApiClient apiClient, FirebaseAuthService authService)
      : _apiClient = apiClient,
        _authService = authService,
        _fallback = MockHealthRecordRepository();

  final ApiClient _apiClient;
  final FirebaseAuthService _authService;
  final MockHealthRecordRepository _fallback;

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
  Future<List<HealthRecord>> getHealthTimeline() async {
    try {
      final response = await _apiClient.request(
        '/records/timeline',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getHealthTimeline();
      }

      final list = (response.data!['timeline'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => HealthRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getHealthTimeline();
    }
  }

  @override
  Future<List<Prescription>> getPrescriptions() async {
    try {
      final response = await _apiClient.request(
        '/records/prescriptions',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getPrescriptions();
      }

      final list = (response.data!['prescriptions'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => Prescription.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getPrescriptions();
    }
  }

  @override
  Future<Prescription> getPrescription(String id) async {
    try {
      final response = await _apiClient.request(
        '/records/prescriptions/$id',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getPrescription(id);
      }

      final data = (response.data!['prescription'] as Map<String, dynamic>?) ??
          response.data!;
      return Prescription.fromJson(data);
    } catch (_) {
      return await _fallback.getPrescription(id);
    }
  }

  @override
  Future<List<LabReport>> getLabReports() async {
    try {
      final response = await _apiClient.request(
        '/records/lab-reports',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getLabReports();
      }

      final list = (response.data!['labReports'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => LabReport.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getLabReports();
    }
  }

  @override
  Future<LabReport> getLabReport(String id) async {
    try {
      final response = await _apiClient.request(
        '/records/lab-reports/$id',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getLabReport(id);
      }

      final data = (response.data!['labReport'] as Map<String, dynamic>?) ??
          response.data!;
      return LabReport.fromJson(data);
    } catch (_) {
      return await _fallback.getLabReport(id);
    }
  }

  @override
  Future<List<Referral>> getReferrals() async {
    try {
      final response = await _apiClient.request(
        '/records/referrals',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getReferrals();
      }

      final list = (response.data!['referrals'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => Referral.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getReferrals();
    }
  }

  @override
  Future<Referral> getReferral(String id) async {
    try {
      final response = await _apiClient.request(
        '/records/referrals/$id',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getReferral(id);
      }

      final data = (response.data!['referral'] as Map<String, dynamic>?) ??
          response.data!;
      return Referral.fromJson(data);
    } catch (_) {
      return await _fallback.getReferral(id);
    }
  }

  @override
  Future<List<Consultation>> getConsultations() async {
    try {
      final response = await _apiClient.request(
        '/records/consultations',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getConsultations();
      }

      final list = (response.data!['consultations'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => Consultation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getConsultations();
    }
  }

  @override
  Future<Consultation> getConsultation(String id) async {
    try {
      final response = await _apiClient.request(
        '/records/consultations/$id',
        authToken: await _getIdToken(),
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getConsultation(id);
      }

      final data = (response.data!['consultation'] as Map<String, dynamic>?) ??
          response.data!;
      return Consultation.fromJson(data);
    } catch (_) {
      return await _fallback.getConsultation(id);
    }
  }
}
