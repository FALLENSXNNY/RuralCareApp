import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/offline_banner.dart';

class EmergencyLandingScreen extends ConsumerWidget {
  const EmergencyLandingScreen({super.key});

  Future<void> _callAmbulance() async {
    final uri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final topicsAsync = ref.watch(firstAidTopicsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.emergencyBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Offline banner if disconnected
              if (!isOnline)
                const OfflineBanner(
                  message: 'Offline Mode — Emergency content loaded on device',
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.emergency,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Emergency Help',
                        style: AppTextStyles.emergencyTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose an emergency type or dial 108 directly.\nAll first-aid guidance works 100% offline.',
                        style: AppTextStyles.emergencyBody.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CALL 108 AMBULANCE — large touch target (88dp)
                      _CallAmbulanceButton(onTap: _callAmbulance),

                      const SizedBox(height: 20),

                      // Quick action to find nearest emergency facility
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.facilityFinder),
                        icon: const Icon(
                          Icons.local_hospital_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Find Nearest Emergency Facility',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.white38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white10,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'First Aid Guide',
                        style: AppTextStyles.emergencyBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Emergency topics list
                      topicsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        error: (err, stack) => _buildFallbackTopicCards(context),
                        data: (topics) {
                          if (topics.isEmpty) {
                            return _buildFallbackTopicCards(context);
                          }
                          return Column(
                            children: topics.map((topic) {
                              return _EmergencyTypeCard(
                                icon: topic.icon,
                                title: topic.title,
                                urgency: topic.urgency,
                                onTap: () => context
                                    .go('/emergency/first-aid/${topic.id}'),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Offline info card
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.offlineEmergency),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: Colors.white70,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Offline Emergency Mode & Storage',
                                  style: AppTextStyles.emergencyBody.copyWith(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackTopicCards(BuildContext context) {
    const fallbacks = [
      {'id': 'cpr', 'icon': '🫀', 'title': 'CPR & Unconsciousness', 'urgency': 'HIGH'},
      {'id': 'choking', 'icon': '🫁', 'title': 'Choking (Heimlich Maneuver)', 'urgency': 'HIGH'},
      {'id': 'bleeding', 'icon': '🩸', 'title': 'Severe Bleeding & Pressure', 'urgency': 'HIGH'},
      {'id': 'burns', 'icon': '🔥', 'title': 'Burns & Scalds (Cool Water)', 'urgency': 'MEDIUM'},
      {'id': 'fracture', 'icon': '🦴', 'title': 'Fracture & Immobilization', 'urgency': 'MEDIUM'},
      {'id': 'snake_bite', 'icon': '🐍', 'title': 'Snake Bite (Stay Still & 108)', 'urgency': 'HIGH'},
      {'id': 'electric_shock', 'icon': '⚡', 'title': 'Electric Shock (Cut Power)', 'urgency': 'HIGH'},
      {'id': 'heat_stroke', 'icon': '☀️', 'title': 'Heat Stroke & Cooling', 'urgency': 'HIGH'},
      {'id': 'chest_pain', 'icon': '❤️', 'title': 'Chest Pain / Heart Attack', 'urgency': 'HIGH'},
      {'id': 'poisoning', 'icon': '⚠️', 'title': 'Pesticide & Poisoning', 'urgency': 'HIGH'},
      {'id': 'high_fever', 'icon': '🤒', 'title': 'High Fever & Fits', 'urgency': 'MEDIUM'},
    ];

    return Column(
      children: fallbacks.map((f) {
        return _EmergencyTypeCard(
          icon: f['icon']!,
          title: f['title']!,
          urgency: f['urgency']!,
          onTap: () => context.go('/emergency/first-aid/${f['id']}'),
        );
      }).toList(),
    );
  }
}

class _CallAmbulanceButton extends StatelessWidget {
  const _CallAmbulanceButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.emergencyContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                color: AppColors.emergency,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Call Ambulance',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.emergency,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Dial 108 — Free, 24/7 Emergency',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyTypeCard extends StatelessWidget {
  const _EmergencyTypeCard({
    required this.icon,
    required this.title,
    required this.urgency,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String urgency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHigh = urgency.toUpperCase() == 'HIGH';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.emergencyBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHigh ? 'High Urgency · Immediate Care' : 'Guidance Available',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isHigh ? const Color(0xFFFFCDD2) : Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
