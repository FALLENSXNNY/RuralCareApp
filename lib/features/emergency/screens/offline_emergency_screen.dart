import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OfflineEmergencyScreen extends ConsumerWidget {
  const OfflineEmergencyScreen({super.key});

  Future<void> _callAmbulance() async {
    final uri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final storage = ref.watch(localStorageProvider);
    final isDownloaded = storage.isOfflineContentDownloaded;
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.emergencyBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => context.go(AppRoutes.emergency),
                    ),
                    Text(
                      l10n.emergencyHelp,
                      style: AppTextStyles.emergencyTitle.copyWith(fontSize: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Connectivity indicator
                Icon(
                  isOnline ? Icons.cloud_done : Icons.wifi_off,
                  color: Colors.white70,
                  size: 64,
                ),
                const SizedBox(height: 16),

                Text(
                  isOnline ? 'Online Mode Active' : 'You are offline',
                  style: AppTextStyles.emergencyTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Emergency first-aid guidance and offline emergency numbers are pre-installed on this device and work 100% without cellular data or Wi-Fi.',
                  style: AppTextStyles.emergencyBody.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _callAmbulance,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.emergency,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  l10n.callAmbulance,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.emergency,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              Text(
                                l10n.call108Subtitle,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Go to first aid
                GestureDetector(
                  onTap: () => context.go(AppRoutes.emergency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white70,
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Open First Aid Guide (10 Topics)',
                            style: AppTextStyles.emergencyBody,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Status info chip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDownloaded ? Icons.check_circle : Icons.info_outline,
                        color: isDownloaded ? Colors.greenAccent : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isDownloaded
                              ? 'Offline emergency bundle v1.2 loaded on storage.'
                              : 'Offline emergency content active.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
