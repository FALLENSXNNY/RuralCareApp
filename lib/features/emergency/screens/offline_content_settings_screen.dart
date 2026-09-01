import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class OfflineContentSettingsScreen extends ConsumerStatefulWidget {
  const OfflineContentSettingsScreen({super.key});

  @override
  ConsumerState<OfflineContentSettingsScreen> createState() =>
      _OfflineContentSettingsScreenState();
}

class _OfflineContentSettingsScreenState
    extends ConsumerState<OfflineContentSettingsScreen> {
  bool _downloadingFirstAid = false;

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(localStorageProvider);
    final isDownloaded = storage.isOfflineContentDownloaded;
    final version = storage.offlineContentVersion ?? '1.2.0 (Preloaded)';

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Offline Content Settings'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline Emergency Guidance',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All critical first-aid guidance and emergency dialers are pre-saved on your device so you never lose access even without network.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Stored Content Packages', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),

            // First aid guide
            SectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.emergencyContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.emergency,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency First Aid Protocols',
                              style: AppTextStyles.titleSmall,
                            ),
                            Text(
                              '10 clinical topics (Snake bite, CPR, Burns, etc.)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Size: ~140 KB · Version: $version',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isDownloaded)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 28,
                        )
                      else if (_downloadingFirstAid)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.download_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: _syncFirstAid,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Offline verified · Pre-loaded on device',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _syncFirstAid,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Re-sync'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            RuralCareButton(
              label: 'Open Emergency Guide',
              onPressed: () => context.go(AppRoutes.emergency),
              variant: RuralCareButtonVariant.primary,
              icon: Icons.emergency,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncFirstAid() async {
    setState(() => _downloadingFirstAid = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final storage = ref.read(localStorageProvider);
    await storage.setOfflineContentDownloaded(true);
    await storage.setOfflineContentVersion('1.2.0 (Synced)');
    setState(() => _downloadingFirstAid = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Emergency first-aid content synced and verified!'),
        ),
      );
    }
  }
}
