// Riverpod providers — foundational providers for the patient application
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/ai_message.dart';
import '../models/child_care.dart';
import '../models/consultation.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../models/first_aid_topic.dart';
import '../models/health_record.dart';
import '../models/lab_report.dart';
import '../models/medical_document.dart';
import '../models/patient.dart';
import '../models/pregnancy.dart';
import '../models/prescription.dart';
import '../models/referral.dart';
import '../networking/api_client.dart';
import '../repositories/ai_repository.dart';
import '../repositories/api_ai_repository.dart';
import '../repositories/api_document_repository.dart';
import '../repositories/api_facility_repository.dart';
import '../repositories/api_health_record_repository.dart';
import '../repositories/api_patient_repository.dart';
import '../repositories/child_care_repository.dart';
import '../repositories/document_repository.dart';
import '../repositories/facility_repository.dart';
import '../repositories/health_record_repository.dart';
import '../repositories/healthcare_repository.dart';
import '../repositories/mock_repositories.dart';
import '../repositories/patient_repository.dart';
import '../repositories/pregnancy_repository.dart';
import '../services/connectivity_service.dart';
import '../services/emergency_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/location_service.dart';
import '../storage/local_storage_service.dart';

// ── Configuration ──────────────────────────────────────────────────────────

/// Provides the application configuration.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.instance);

// ── Storage ────────────────────────────────────────────────────────────────

/// Provides the local storage service.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

// ── Localization ───────────────────────────────────────────────────────────

/// Notifier managing dynamic locale updates (en, hi, bn) with persistence.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._storage) : super(Locale(_storage.appLanguage));

  final LocalStorageService _storage;

  Future<void> setLocale(String languageCode) async {
    if (!['en', 'hi', 'bn'].contains(languageCode)) return;
    await _storage.setAppLanguage(languageCode);
    state = Locale(languageCode);
  }

  Future<void> setLanguage(String languageCode) => setLocale(languageCode);
}

/// Dynamic locale provider for reactive multilingual rendering.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(localStorageProvider);
  return LocaleNotifier(storage);
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

/// Async provider for all pre-loaded first aid topics in current locale.
final firstAidTopicsProvider = FutureProvider<List<FirstAidTopic>>((ref) async {
  final service = ref.watch(emergencyServiceProvider);
  final locale = ref.watch(localeProvider);
  return service.loadTopics(languageCode: locale.languageCode);
});

/// Async family provider to fetch a single first aid topic by ID in current locale.
final firstAidTopicDetailProvider =
    FutureProvider.family<FirstAidTopic?, String>((ref, id) async {
  final service = ref.watch(emergencyServiceProvider);
  final locale = ref.watch(localeProvider);
  return service.getTopicById(id, languageCode: locale.languageCode);
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

// ── Pregnancy & Maternal Care state ────────────────────────────────────────

/// Provides the [PregnancyRepository] instance.
final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiPregnancyRepository(storage);
});

/// Async provider for the active patient's pregnancy profile.
final pregnancyProfileProvider = FutureProvider<PregnancyProfile>((ref) async {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  final patientId = user?.uid ?? 'default_patient';
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getPregnancyProfile(patientId);
});

/// StateNotifier to manage updating the pregnancy profile reactively.
class PregnancyProfileController extends StateNotifier<AsyncValue<PregnancyProfile>> {
  PregnancyProfileController(this._repo, this._patientId)
      : super(const AsyncValue.loading()) {
    loadProfile();
  }

  final PregnancyRepository _repo;
  final String _patientId;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.getPregnancyProfile(_patientId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDates({DateTime? edd, DateTime? lmp}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(
      estimatedDueDate: edd,
      lastMenstrualPeriod: lmp,
      updatedAt: DateTime.now(),
    );
    await _repo.savePregnancyProfile(updated);
    await loadProfile();
  }
}

final pregnancyProfileControllerProvider =
    StateNotifierProvider<PregnancyProfileController, AsyncValue<PregnancyProfile>>((ref) {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  final patientId = user?.uid ?? 'default_patient';
  final repo = ref.watch(pregnancyRepositoryProvider);
  return PregnancyProfileController(repo, patientId);
});

/// Async provider for all 4 standard Antenatal Care visits.
final antenatalVisitsProvider = FutureProvider<List<AntenatalVisit>>((ref) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getAntenatalVisits();
});

/// Provider family for trimester-specific educational guidance.
final pregnancyGuidanceProvider =
    Provider.family<List<PregnancyGuidanceItem>, PregnancyTrimester>((ref, trimester) {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getGuidanceForTrimester(trimester);
});

/// Provider for common pregnancy symptoms.
final commonPregnancySymptomsProvider = Provider<List<PregnancySymptom>>((ref) {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getCommonSymptoms();
});

/// Provider for high-risk emergency warning signs.
final pregnancyWarningSignsProvider = Provider<List<PregnancySymptom>>((ref) {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getEmergencyWarningSigns();
});

// ── Child Care & Pediatric Immunization state ───────────────────────────────

/// Provides the [ChildCareRepository] instance.
final childCareRepositoryProvider = Provider<ChildCareRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiChildCareRepository(storage);
});

/// Async provider for Child Immunization Schedule (UIP)
final childVaccinesProvider = FutureProvider<List<ChildVaccine>>((ref) async {
  final repo = ref.watch(childCareRepositoryProvider);
  return repo.getVaccineSchedule();
});

/// Provider for developmental milestones
final childMilestonesProvider = Provider<List<ChildMilestone>>((ref) {
  final repo = ref.watch(childCareRepositoryProvider);
  return repo.getDevelopmentalMilestones();
});

/// Provider for Postnatal Care (PNC) visits
final postnatalVisitsProvider = Provider<List<PostnatalVisit>>((ref) {
  final repo = ref.watch(childCareRepositoryProvider);
  return repo.getPostnatalCareSchedule();
});

/// Async provider for Fetal Kick Counter sessions
final fetalKickSessionsProvider = FutureProvider<List<FetalKickSession>>((ref) async {
  final repo = ref.watch(childCareRepositoryProvider);
  return repo.getKickSessions();
});

// ── GPS & Healthcare Discovery state (Phase 4) ──────────────────────────────

/// Provides the singleton [LocationService] instance.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Async provider for current location permission status.
final locationPermissionStatusProvider =
    FutureProvider.autoDispose<LocationPermissionStatus>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.checkPermission();
});

/// Async provider for current device GPS location.
final userLocationProvider =
    FutureProvider.autoDispose<UserLocation?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentLocation();
});

/// Provides the [HealthcareRepository] instance.
final healthcareRepositoryProvider = Provider<HealthcareRepository>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return HealthcareRepository(locationService: locationService);
});

/// Parameters for querying healthcare facilities.
class FacilitySearchParams {
  final String category;
  final String searchQuery;
  final bool isEmergencyMode;

  const FacilitySearchParams({
    this.category = 'All',
    this.searchQuery = '',
    this.isEmergencyMode = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacilitySearchParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          searchQuery == other.searchQuery &&
          isEmergencyMode == other.isEmergencyMode;

  @override
  int get hashCode =>
      category.hashCode ^ searchQuery.hashCode ^ isEmergencyMode.hashCode;
}

/// Dynamic provider for discovering healthcare facilities with live location distance and filters.
final gpsHealthcareFacilitiesProvider = FutureProvider.autoDispose
    .family<List<HealthcareFacility>, FacilitySearchParams>((ref, params) async {
  final repo = ref.watch(healthcareRepositoryProvider);
  final userLocation = ref.watch(userLocationProvider).valueOrNull;

  return repo.getFacilities(
    userLocation: userLocation,
    category: params.category,
    searchQuery: params.searchQuery,
    isEmergencyMode: params.isEmergencyMode,
  );
});

/// Parameters for querying doctors.
class DoctorSearchParams {
  final String speciality;
  final String searchQuery;
  final bool onlyOnline;

  const DoctorSearchParams({
    this.speciality = 'All',
    this.searchQuery = '',
    this.onlyOnline = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorSearchParams &&
          runtimeType == other.runtimeType &&
          speciality == other.speciality &&
          searchQuery == other.searchQuery &&
          onlyOnline == other.onlyOnline;

  @override
  int get hashCode =>
      speciality.hashCode ^ searchQuery.hashCode ^ onlyOnline.hashCode;
}

/// Dynamic provider for discovering doctors with filter and online availability.
final gpsDoctorsProvider = FutureProvider.autoDispose
    .family<List<Doctor>, DoctorSearchParams>((ref, params) async {
  final repo = ref.watch(healthcareRepositoryProvider);
  return repo.getDoctors(
    speciality: params.speciality,
    searchQuery: params.searchQuery,
    onlyOnline: params.onlyOnline,
  );
});


