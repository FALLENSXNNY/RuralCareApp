// GoRouter configuration for RuralCare patient app
import 'package:flutter/material.dart';
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

// Pregnancy Care
import '../../features/pregnancy/screens/pregnancy_dashboard_screen.dart';
import '../../features/pregnancy/screens/antenatal_schedule_screen.dart';
import '../../features/pregnancy/screens/pregnancy_warning_signs_screen.dart';

// Find Care & Healthcare Finder
import '../../features/healthcare_finder/presentation/healthcare_map_screen.dart';
import '../../features/healthcare_finder/presentation/healthcare_details_screen.dart';
import '../../features/healthcare_finder/presentation/directions_screen.dart';
import '../../features/healthcare_finder/models/healthcare_place.dart';
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

// Appointments & Queue (Demo)
import '../../features/appointments/models/demo_appointment.dart';
import '../../features/appointments/screens/book_appointment_screen.dart';
import '../../features/appointments/screens/confirm_appointment_screen.dart';
import '../../features/appointments/screens/appointment_confirmed_screen.dart';
import '../../features/appointments/screens/my_appointments_screen.dart';
import '../../features/appointments/screens/appointment_details_screen.dart';
import '../../features/appointments/screens/check_in_screen.dart';
import '../../features/appointments/screens/live_queue_screen.dart';

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

  // Pregnancy Care
  static const String pregnancy = '/pregnancy';
  static const String antenatalSchedule = '/pregnancy/anc-schedule';
  static const String pregnancyWarningSigns = '/pregnancy/warning-signs';

  // Emergency — full screen, no bottom nav
  static const String emergency = '/emergency';
  static const String firstAid = '/emergency/first-aid/:type';
  static const String offlineEmergency = '/emergency/offline';
  static const String offlineSettings = '/emergency/offline-settings';

  // AI
  static const String aiChat = '/ai-chat';
  static const String aiAssistant = '/ai-chat';

  // Find Care & Healthcare Finder
  static const String facilityFinder = '/find-care';
  static const String healthcareDetails = '/healthcare-details/:id';
  static const String directions = '/directions';
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

  // Appointments & Queue (Demo)
  static const String bookAppointment = '/care/book-appointment';
  static const String confirmAppointment = '/care/confirm-appointment';
  static const String appointmentConfirmed = '/care/appointment-confirmed';
  static const String myAppointments = '/care/appointments';
  static const String appointmentDetails = '/care/appointments/:id';
  static const String checkIn = '/care/appointments/:id/checkin';
  static const String liveQueue = '/care/queue';

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
            path: AppRoutes.pregnancy,
            builder: (context, state) => const PregnancyDashboardScreen(),
            routes: [
              GoRoute(
                path: 'anc-schedule',
                builder: (context, state) => const AntenatalScheduleScreen(),
              ),
              GoRoute(
                path: 'warning-signs',
                builder: (context, state) =>
                    const PregnancyWarningSignsScreen(),
              ),
            ],
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
            builder: (context, state) {
              final extra = state.extra;
              final prompt = extra is String ? extra : null;
              return AiChatScreen(initialPrompt: prompt);
            },
          ),
          GoRoute(
            path: AppRoutes.facilityFinder,
            builder: (context, state) {
              final extra = state.extra;
              String? initialCategory;
              bool isEmergency = false;

              if (extra is Map<String, dynamic>) {
                initialCategory = extra['category'] as String?;
                isEmergency = extra['emergency'] as bool? ?? false;
              } else if (extra is String) {
                initialCategory = extra;
              }

              initialCategory ??= state.uri.queryParameters['category'];
              if (state.uri.queryParameters['emergency'] == 'true') {
                isEmergency = true;
              }

              return HealthcareMapScreen(
                key: ValueKey('healthcare_map_${initialCategory ?? "All"}_$isEmergency'),
                initialCategory: initialCategory,
                isEmergencyMode: isEmergency,
              );
            },
            routes: [
              GoRoute(
                path: 'doctors',
                builder: (context, state) => const HealthcareMapScreen(
                  key: ValueKey('healthcare_map_Doctors_false'),
                  initialCategory: 'Doctors',
                  isEmergencyMode: false,
                ),
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
            path: '/healthcare-details/:id',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is HealthcarePlace) {
                return HealthcareDetailsScreen(place: extra);
              }
              final id = state.pathParameters['id'] ?? 'place_satara_dist_hosp';
              return HealthcareDetailsScreen(
                place: HealthcarePlace(
                  id: id,
                  name: 'Healthcare Facility',
                  category: 'Hospitals',
                  type: 'District Hospital',
                  address: 'Satara District, Maharashtra',
                  distance: 'Nearby',
                  phone: '+91 2162 233 444',
                  hours: 'Open 24 Hours',
                  isEmergency24x7: true,
                  hasMaternalCare: true,
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.directions,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is HealthcarePlace) {
                return DirectionsScreen(place: extra);
              }
              return const DirectionsScreen(
                place: HealthcarePlace(
                  id: 'default',
                  name: 'Satara District Hospital',
                  category: 'Hospitals',
                  type: 'District Hospital',
                  address: 'Satara, Maharashtra',
                  distance: '1.8 km',
                  distanceKm: 1.8,
                  phone: '+91 2162 233 444',
                  hours: 'Open 24 Hours',
                  isEmergency24x7: true,
                  hasMaternalCare: true,
                ),
              );
            },
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

          // ── Appointments & Queue (Demo) ──────────────────────────
          GoRoute(
            path: AppRoutes.bookAppointment,
            builder: (context, state) {
              final place = state.extra is HealthcarePlace
                  ? state.extra as HealthcarePlace
                  : null;
              return BookAppointmentScreen(place: place);
            },
          ),
          GoRoute(
            path: AppRoutes.confirmAppointment,
            builder: (context, state) {
              final appointmentData = state.extra is Map<String, dynamic>
                  ? state.extra as Map<String, dynamic>
                  : <String, dynamic>{};
              return ConfirmAppointmentScreen(
                appointmentData: appointmentData,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.appointmentConfirmed,
            builder: (context, state) {
              final appointment = state.extra is DemoAppointment
                  ? state.extra as DemoAppointment
                  : null;
              return AppointmentConfirmedScreen(
                appointment: appointment,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.myAppointments,
            builder: (context, state) => const MyAppointmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.appointmentDetails,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final appointment = state.extra is DemoAppointment
                  ? state.extra as DemoAppointment
                  : null;
              return AppointmentDetailsScreen(
                appointmentId: id,
                initialAppointment: appointment,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.checkIn,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final appointment = state.extra is DemoAppointment
                  ? state.extra as DemoAppointment
                  : null;
              return CheckInScreen(
                appointmentId: id,
                initialAppointment: appointment,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.liveQueue,
            builder: (context, state) => const LiveQueueScreen(),
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
