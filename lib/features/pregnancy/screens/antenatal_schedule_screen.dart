import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/pregnancy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class AntenatalScheduleScreen extends ConsumerWidget {
  const AntenatalScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visitsAsync = ref.watch(antenatalVisitsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(l10n.allAncVisits),
        backgroundColor: AppColors.surface,
      ),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading ANC visits: $err'),
        ),
        data: (visits) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            itemCount: visits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return _AntenatalVisitCard(
                visit: visit,
                onToggleComplete: (val) async {
                  await ref
                      .read(pregnancyRepositoryProvider)
                      .updateVisitStatus(visit.visitNumber, val);
                  ref.invalidate(antenatalVisitsProvider);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AntenatalVisitCard extends StatelessWidget {
  const _AntenatalVisitCard({
    required this.visit,
    required this.onToggleComplete,
  });

  final AntenatalVisit visit;
  final ValueChanged<bool> onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: visit.isCompleted
                      ? AppColors.secondaryContainer
                      : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    visit.isCompleted ? Icons.check : Icons.event_available,
                    color: visit.isCompleted
                        ? AppColors.secondary
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ancVisitNumber(visit.visitNumber),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: visit.isCompleted
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(visit.title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.timelapse, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          visit.weekRange,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: visit.isCompleted
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  visit.isCompleted ? l10n.ancCompleted : l10n.ancPending,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: visit.isCompleted
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          Text(
            visit.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          Text(
            l10n.testsProcedures,
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...visit.testsAndProcedures.map(
            (test) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(test, style: AppTextStyles.bodySmall),
                  ),
                ],
              ),
            ),
          ),

          if (visit.clinicName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  visit.clinicName!,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                ),
                if (visit.scheduledDate != null) ...[
                  const Text(' · '),
                  Text(
                    DateFormat('dd MMM yyyy').format(visit.scheduledDate!),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => onToggleComplete(!visit.isCompleted),
                icon: Icon(
                  visit.isCompleted ? Icons.undo : Icons.check_circle,
                  size: 16,
                  color: visit.isCompleted ? AppColors.textMuted : AppColors.secondary,
                ),
                label: Text(
                  visit.isCompleted ? 'Mark Pending' : 'Mark Completed',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: visit.isCompleted ? AppColors.textMuted : AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
