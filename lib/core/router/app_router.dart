// GoRouter configuration for RuralCare patient app
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Onboarding
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/otp_login_screen.dart';
import '../../features/onboarding/screens/registration_contact_screen.dart';
import '../../features/onboarding/screens/registration_health_screen.dart';

// Home shell
import '../../features/home/screens/home_shell.dart';
import '../../features/home/screens/patient_home_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/patient_profile_screen.dart';

// Emergency
import '../../features/emergency/screens/emergency_landing_screen.dart';
import '../../features/emergency/screens/first_aid_steps_screen.dart';
import '../../features/emergency/screens/offline_emergency_screen.dart';
import '../../features/emergency/screens/offline_content_settings_screen.dart';

// AI Assistant
import '../../features/ai_assistant/screens/ai_chat_screen.dart';

// Find Care
import '../../features/find_care/screens/facility_finder_screen.dart';
import '../../features/find_care/screens/find_doctor_screen.dart';
import '../../features/find_care/screens/doctor_profile_screen.dart';

// Health Records
import '../../features/health_records/screens/health_records_hub_screen.dart';
import '../../features/health_records/screens/health_timeline_screen.dart';
import '../../features/health_records/screens/prescriptions_list_screen.dart';
import '../../features/health_records/screens/lab_reports_list_screen.dart';
import '../../features/health_records/screens/referrals_list_screen.dart';
import '../../features/health_records/screens/consultations_list_screen.dart';
import '../../features/health_records/screens/consultation_summary_screen.dart';
import '../../features/health_records/screens/prescription_view_screen.dart';
import '../../features/health_records/screens/lab_report_screen.dart';
import '../../features/health_records/screens/referral_tracking_screen.dart';

// Documents
import '../../features/documents/screens/documents_list_screen.dart';
import '../../features/documents/screens/document_upload_screen.dart';
import '../../features/documents/screens/document_viewer_screen.dart';
import '../models/medical_document.dart';

// Consultation
import '../../features/consultation/screens/video_consultation_screen.dart';

// Auth
import '../providers/app_providers.dart';
import '../storage/local_storage_service.dart';

/// Named route constants — prevents magic string typos
class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String registerContact = '/register/contact';
  static const String registerHealth = '/register/health';

  // Shell routes
  static const String home = '/home';
  static const String profile = '/home/profile';
  static const String editProfile = '/home/profile/edit';

  // Emergency — full screen, no bottom nav
  static const String emergency = '/emergency';
  static const String firstAid = '/emergency/first-aid/:type';
  static const String offlineEmergency = '/emergency/offline';
  static const String offlineSettings = '/emergency/offline-settings';

  // AI
  static const String aiChat = '/ai-chat';

  // Find Care
  static const String facilityFinder = '/find-care';
  static const String findDoctor = '/find-care/doctors';
  static const String doctorProfile = '/find-care/doctors/:id';

  // Health Records
  static const String recordsHub = '/records';
  static const String recordsTimeline = '/records/timeline';
  static const String prescriptionsList = '/records/prescriptions';
  static const String labReportsList = '/records/lab-reports';
  static const String referralsList = '/records/referrals';
  static const String consultationsList = '/records/consultations';
  static const String consultationSummary = '/records/consultation/:id';
  static const String prescription = '/records/prescription/:id';
  static const String labReport = '/records/lab/:id';
  static const String referral = '/records/referral/:id';

  // Documents
  static const String documentsList = '/records/documents';
  static const String documentUpload = '/upload';
  static const String documentView = '/documents/view/:id';

  // Consultation
  static const String videoConsultation = '/consultation';

  static bool isEmergencyRoute(String location) =>
      location.startsWith('/emergency');
}

/// Creates the app router. Accepts a [WidgetRef] so it can read auth state.
///
/// The [refreshListenable] is the [AuthNotifier] which notifies GoRouter
/// whenever the Firebase auth state changes — this triggers re-evaluation
/// of the [redirect] callback without any extra wiring.
GoRouter createAppRouter(WidgetRef ref) {
  final authNotifier = ref.read(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: authNotifier,

    // ── Auth redirect guard ────────────────────────────────────────────────
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Emergency routes are always allowed — no auth required.
      if (AppRoutes.isEmergencyRoute(location)) return null;

      // Check login state synchronously (Firebase stream + local cache).
      final isLoggedIn = LocalStorageService.instance.isLoggedIn;
      final isNewUser = LocalStorageService.instance.isNewUser;
      final hasCompletedProfile =
          LocalStorageService.instance.patientProfile?.name.trim().isNotEmpty == true;

      final isOnWelcomeOrLogin = location == AppRoutes.welcome ||
          location == AppRoutes.login;
      final isOnRegistration = location.startsWith('/register');

      if (!isLoggedIn) {
        // Not authenticated — redirect to welcome if trying to access guarded routes.
        if (!isOnWelcomeOrLogin && !isOnRegistration) {
          return AppRoutes.welcome;
        }
        return null; // Allow welcome / login / register pages
      }

      // Authenticated user:
      if (isNewUser && !hasCompletedProfile && !isOnRegistration) {
        // Only redirect to registration if the user has NOT completed their profile.
        return AppRoutes.registerContact;
      }

      if (isOnWelcomeOrLogin) {
        // Already logged in — skip the auth screens.
        return (isNewUser && !hasCompletedProfile)
            ? AppRoutes.registerContact
            : AppRoutes.home;
      }

      return null; // No redirect needed
    },

    routes: [
      // ── Onboarding (no shell) ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const OtpLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerContact,
        builder: (context, state) => const RegistrationContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerHealth,
        builder: (context, state) => const RegistrationHealthScreen(),
      ),

      // ── Home Shell (bottom nav) ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const PatientHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const PatientProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            builder: (context, state) => const AiChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.facilityFinder,
            builder: (context, state) => const FacilityFinderScreen(),
            routes: [
              GoRoute(
                path: 'doctors',
                builder: (context, state) => const FindDoctorScreen(),
              ),
              GoRoute(
                path: 'doctors/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return DoctorProfileScreen(doctorId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.recordsHub,
            builder: (context, state) => const HealthRecordsHubScreen(),
            routes: [
              GoRoute(
                path: 'timeline',
                builder: (context, state) => const HealthTimelineScreen(),
              ),
              GoRoute(
                path: 'prescriptions',
                builder: (context, state) => const PrescriptionsListScreen(),
              ),
              GoRoute(
                path: 'lab-reports',
                builder: (context, state) => const LabReportsListScreen(),
              ),
              GoRoute(
                path: 'referrals',
                builder: (context, state) => const ReferralsListScreen(),
              ),
              GoRoute(
                path: 'consultations',
                builder: (context, state) => const ConsultationsListScreen(),
              ),
              GoRoute(
                path: 'documents',
                builder: (context, state) => const DocumentsListScreen(),
              ),
              GoRoute(
                path: 'consultation/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ConsultationSummaryScreen(consultationId: id);
                },
              ),
              GoRoute(
                path: 'prescription/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return PrescriptionViewScreen(prescriptionId: id);
                },
              ),
              GoRoute(
                path: 'lab/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return LabReportScreen(reportId: id);
                },
              ),
              GoRoute(
                path: 'referral/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ReferralTrackingScreen(referralId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.documentUpload,
            builder: (context, state) => const DocumentUploadScreen(),
          ),
          GoRoute(
            path: AppRoutes.documentView,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra;
              final doc = extra is MedicalDocument ? extra : null;
              return DocumentViewerScreen(documentId: id, document: doc);
            },
          ),
          GoRoute(
            path: AppRoutes.videoConsultation,
            builder: (context, state) => const VideoConsultationScreen(),
          ),
        ],
      ),

      // ── Emergency — full screen, NO bottom nav ───────────────────────────
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyLandingScreen(),
      ),
      GoRoute(
        path: '/emergency/first-aid/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'snake_bite';
          return FirstAidStepsScreen(emergencyType: type);
        },
      ),
      GoRoute(
        path: AppRoutes.offlineEmergency,
        builder: (context, state) => const OfflineEmergencyScreen(),
      ),
      GoRoute(
        path: AppRoutes.offlineSettings,
        builder: (context, state) => const OfflineContentSettingsScreen(),
      ),
    ],
  );
}
