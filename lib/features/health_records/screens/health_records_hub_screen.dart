import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class HealthRecordsHubScreen extends ConsumerWidget {
  const HealthRecordsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionsProvider);
    final labReportsAsync = ref.watch(labReportsProvider);
    final referralsAsync = ref.watch(referralsProvider);
    final consultationsAsync = ref.watch(consultationsProvider);
    final documentsAsync = ref.watch(patientDocumentsProvider(null));

    final rxCount = prescriptionsAsync.valueOrNull?.length ?? 0;
    final labCount = labReportsAsync.valueOrNull?.length ?? 0;
    final refCount = referralsAsync.valueOrNull?.length ?? 0;
    final conCount = consultationsAsync.valueOrNull?.length ?? 0;
    final docCount = documentsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('My Health Records'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        children: [
          _RecordCategoryCard(
            icon: Icons.timeline,
            title: 'Health Timeline',
            subtitle: 'Your full chronological health history',
            color: AppColors.primary,
            onTap: () => context.push(AppRoutes.recordsTimeline),
          ),
          const SizedBox(height: 10),
          _RecordCategoryCard(
            icon: Icons.medication_outlined,
            title: 'Prescriptions',
            subtitle: '$rxCount active prescription${rxCount == 1 ? '' : 's'}',
            color: const Color(0xFF6750A4),
            onTap: () => context.push(AppRoutes.prescriptionsList),
          ),
          const SizedBox(height: 10),
          _RecordCategoryCard(
            icon: Icons.science_outlined,
            title: 'Lab Reports',
            subtitle: '$labCount diagnostic report${labCount == 1 ? '' : 's'}',
            color: const Color(0xFF0277BD),
            onTap: () => context.push(AppRoutes.labReportsList),
          ),
          const SizedBox(height: 10),
          _RecordCategoryCard(
            icon: Icons.transfer_within_a_station,
            title: 'Referrals',
            subtitle: '$refCount referral tracking record${refCount == 1 ? '' : 's'}',
            color: AppColors.secondary,
            onTap: () => context.push(AppRoutes.referralsList),
          ),
          const SizedBox(height: 10),
          _RecordCategoryCard(
            icon: Icons.event_note_outlined,
            title: 'Consultations',
            subtitle: '$conCount doctor visit${conCount == 1 ? '' : 's'} & clinical summaries',
            color: const Color(0xFF00838F),
            onTap: () => context.push(AppRoutes.consultationsList),
          ),
          const SizedBox(height: 10),
          _RecordCategoryCard(
            icon: Icons.upload_file_outlined,
            title: 'Uploaded Documents',
            subtitle: docCount > 0
                ? '$docCount uploaded document${docCount == 1 ? '' : 's'} & scans'
                : 'Upload prescriptions, reports & scans',
            color: const Color(0xFFE65100),
            onTap: () => context.push(AppRoutes.documentsList),
          ),
        ],
      ),
    );
  }
}

class _RecordCategoryCard extends StatelessWidget {
  const _RecordCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
