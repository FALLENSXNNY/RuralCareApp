// Riverpod providers — foundational providers for the patient application
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/ai_message.dart';
import '../models/consultation.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../models/first_aid_topic.dart';
import '../models/health_record.dart';
import '../models/lab_report.dart';
import '../models/medical_document.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/referral.dart';
import '../networking/api_client.dart';
import '../repositories/ai_repository.dart';
import '../repositories/api_ai_repository.dart';
import '../repositories/api_document_repository.dart';
import '../repositories/api_facility_repository.dart';
import '../repositories/api_health_record_repository.dart';
import '../repositories/api_patient_repository.dart';
import '../repositories/document_repository.dart';
import '../repositories/facility_repository.dart';
import '../repositories/health_record_repository.dart';
import '../repositories/mock_repositories.dart';
import '../repositories/patient_repository.dart';
import '../services/connectivity_service.dart';
import '../services/emergency_service.dart';
import '../services/firebase_auth_service.dart';
import '../storage/local_storage_service.dart';

// ── Configuration ──────────────────────────────────────────────────────────

/// Provides the application configuration.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.instance);

// ── Storage ────────────────────────────────────────────────────────────────

/// Provides the local storage service.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

// ── Connectivity ───────────────────────────────────────────────────────────

/// Provides the connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Streams connectivity status changes.
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Current connectivity status (online/offline).
final isOnlineProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);
  return statusAsync.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () =>
        ref.watch(connectivityServiceProvider).currentStatus ==
        ConnectivityStatus.online,
    error: (_, _) => true,
  );
});

// ── Repositories ───────────────────────────────────────────────────────────

/// Provides the patient repository.
/// Uses the real API-backed implementation (Phase 3) unless mock data is
/// explicitly enabled via [AppConfig.useMockData].
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockPatientRepository();
  }
  final authService = ref.watch(firebaseAuthServiceProvider);
  final apiClient = ApiClient();
  ref.onDispose(apiClient.dispose);
  return ApiPatientRepository(apiClient, authService);
});

/// Provides the health record repository.
final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockHealthRecordRepository();
  }
  final authService = ref.watch(firebaseAuthServiceProvider);
  final apiClient = ApiClient();
  ref.onDispose(apiClient.dispose);
  return ApiHealthRecordRepository(apiClient, authService);
});

/// Provides the facility repository.
final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockFacilityRepository();
  }
  final authService = ref.watch(firebaseAuthServiceProvider);
  final apiClient = ApiClient();
  ref.onDispose(apiClient.dispose);
  return ApiFacilityRepository(apiClient, authService);
});

/// Provides the document repository.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockDocumentRepository();
  }
  final authService = ref.watch(firebaseAuthServiceProvider);
  final apiClient = ApiClient();
  ref.onDispose(apiClient.dispose);
  return ApiDocumentRepository(apiClient, authService);
});

/// Async provider for all medical documents of the current patient.
final patientDocumentsProvider =
    FutureProvider.family<List<MedicalDocument>, String?>((ref, type) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getDocuments(type: type);
});

/// Provides the AI repository.
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockAIRepository();
  }
  final authService = ref.watch(firebaseAuthServiceProvider);
  final apiClient = ApiClient();
  ref.onDispose(apiClient.dispose);
  return ApiAIRepository(apiClient, authService);
});

/// Async provider for AI assistant chat history.
final aiConversationHistoryProvider =
    FutureProvider<List<AiMessage>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getConversationHistory();
});

// ── Patient state ──────────────────────────────────────────────────────────

/// Async provider for the current patient profile.
/// Watching [firebaseUserProvider] ensures this provider automatically reloads
/// when a user signs in, signs out, or switches accounts.
final currentPatientProvider = FutureProvider<Patient>((ref) async {
  final firebaseUser = ref.watch(firebaseUserProvider).valueOrNull;
  if (firebaseUser == null) {
    final cached = ref.read(localStorageProvider).patientProfile;
    if (cached != null) return cached;
  }
  final repo = ref.watch(patientRepositoryProvider);
  return repo.getCurrentPatient();
});

// ── Facility & Doctor state ────────────────────────────────────────────────

/// Async provider for all healthcare facilities.
final facilitiesProvider = FutureProvider<List<HealthcareFacility>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(facilityRepositoryProvider);
  return repo.getFacilities();
});

/// Async provider for all doctors.
final doctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(facilityRepositoryProvider);
  return repo.getDoctors();
});

/// Async family provider to fetch a single doctor by ID.
final doctorDetailProvider = FutureProvider.family<Doctor, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(facilityRepositoryProvider);
  return repo.getDoctor(id);
});

// ── Health Records state ───────────────────────────────────────────────────

/// Async provider for the patient's health timeline.
final healthTimelineProvider = FutureProvider<List<HealthRecord>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getHealthTimeline();
});

/// Async provider for all prescriptions.
final prescriptionsProvider = FutureProvider<List<Prescription>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getPrescriptions();
});

/// Async family provider to fetch a single prescription by ID.
final prescriptionDetailProvider =
    FutureProvider.family<Prescription, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getPrescription(id);
});

/// Async provider for all lab reports.
final labReportsProvider = FutureProvider<List<LabReport>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getLabReports();
});

/// Async family provider to fetch a single lab report by ID.
final labReportDetailProvider =
    FutureProvider.family<LabReport, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getLabReport(id);
});

/// Async provider for all referrals.
final referralsProvider = FutureProvider<List<Referral>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getReferrals();
});

/// Async family provider to fetch a single referral by ID.
final referralDetailProvider =
    FutureProvider.family<Referral, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getReferral(id);
});

/// Async provider for all consultations.
final consultationsProvider = FutureProvider<List<Consultation>>((ref) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getConsultations();
});

/// Async family provider to fetch a single consultation by ID.
final consultationDetailProvider =
    FutureProvider.family<Consultation, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(healthRecordRepositoryProvider);
  return repo.getConsultation(id);
});

/// Async family provider to fetch a single medical document by ID.
final documentDetailProvider =
    FutureProvider.family<MedicalDocument, String>((ref, id) async {
  ref.watch(firebaseUserProvider);
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getDocument(id);
});

// ── Emergency & First Aid state ────────────────────────────────────────────

/// Provides the [EmergencyService] instance.
final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService.instance;
});

/// Async provider for all pre-loaded first aid topics.
final firstAidTopicsProvider = FutureProvider<List<FirstAidTopic>>((ref) async {
  final service = ref.watch(emergencyServiceProvider);
  return service.loadTopics();
});

/// Async family provider to fetch a single first aid topic by ID.
final firstAidTopicDetailProvider =
    FutureProvider.family<FirstAidTopic?, String>((ref, id) async {
  final service = ref.watch(emergencyServiceProvider);
  return service.getTopicById(id);
});

// ── Auth state ─────────────────────────────────────────────────────────────

/// Provides the [FirebaseAuthService] singleton.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Streams Firebase [User] changes (null = signed out).
/// Used by the GoRouter redirect to reactively guard routes.
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

/// Whether the user is currently signed in (derived from Firebase stream).
/// Falls back to the cached [LocalStorageService.isLoggedIn] while the stream
/// is loading (e.g. on cold start before Firebase resolves).
final isLoggedInProvider = Provider<bool>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider);
  return firebaseUser.when(
    data: (user) => user != null,
    loading: () => LocalStorageService.instance.isLoggedIn,
    error: (err, stack) => false,
  );
});

/// A [ChangeNotifier] that notifies GoRouter whenever the Firebase auth state
/// changes so the router re-evaluates its [redirect] callback.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(FirebaseAuthService authService) {
    _sub = authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _sub;

  void notify() => notifyListeners();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Provider for [AuthNotifier] — used as GoRouter's [refreshListenable].
final authNotifierProvider = Provider<AuthNotifier>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  final notifier = AuthNotifier(authService);
  ref.onDispose(notifier.dispose);
  return notifier;
});
