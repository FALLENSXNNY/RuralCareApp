import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/referral.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';

class ReferralTrackingScreen extends ConsumerWidget {
  const ReferralTrackingScreen({super.key, required this.referralId});
  final String referralId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralDetailProvider(referralId));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Referral Tracking'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Referral',
            onPressed: () {
              final referral = referralAsync.valueOrNull ??
                  MockPatientData.referrals.firstWhere(
                    (r) => r.id == referralId,
                    orElse: () => MockPatientData.referrals.first,
                  );
              final text = 'Medical Referral #${referral.id}\n'
                  'Referred To: ${referral.referredTo}\n'
                  'Speciality: ${referral.speciality}\n'
                  'Date: ${referral.date}\n'
                  'Reason: ${referral.reason}\n'
                  'Status: ${referral.status}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referral details copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: referralAsync.when(
        data: (referral) => _buildContent(context, referral),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          final fallback = MockPatientData.referrals.firstWhere(
            (r) => r.id == referralId,
            orElse: () => MockPatientData.referrals.first,
          );
          return _buildContent(context, fallback);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Referral referral) {
    final statusLower = referral.status.toLowerCase();
    final isCompleted = statusLower.contains('completed');
    final isScheduled = statusLower.contains('schedule') || isCompleted;
    final isAccepted = statusLower.contains('accept') || isScheduled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Referral #${referral.id}',
                        style: AppTextStyles.titleSmall),
                    StatusBadge(
                      status: isCompleted
                          ? StatusType.active
                          : StatusType.pending,
                      customLabel: referral.status,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Referred Facility',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(referral.referredTo,
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    referral.speciality,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Referred on ${referral.date}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Clinical Reason for Referral',
                    style: AppTextStyles.titleSmall),
                const SizedBox(height: 6),
                Text(
                  referral.reason,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status progress steps
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Referral Journey & Progress',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                const _StatusStep(label: 'Referral Initiated by Doctor', done: true),
                _StatusStep(
                    label: 'Transmitted to Destination Facility',
                    done: true),
                _StatusStep(
                    label: 'Specialist Review & Appointment Confirmed',
                    done: isAccepted),
                _StatusStep(
                    label: 'Specialist Consultation Completed',
                    done: isCompleted,
                    isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: 'Contact Referred Center',
            icon: Icons.phone_outlined,
            onPressed: () async {
              final uri = Uri.parse('tel:108');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.label,
    required this.done,
    this.isLast = false,
  });
  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done ? AppColors.secondary : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check : Icons.radio_button_unchecked,
                size: 16,
                color: done ? Colors.white : AppColors.textMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: done ? AppColors.secondary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: done ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
