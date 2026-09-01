import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/lab_report.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';

class LabReportScreen extends ConsumerWidget {
  const LabReportScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(labReportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Lab Report Details'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Report',
            onPressed: () {
              final report = reportAsync.valueOrNull ??
                  MockPatientData.labReports.firstWhere(
                    (r) => r.id == reportId,
                    orElse: () => MockPatientData.labReports.first,
                  );
              final text = 'Lab Report #${report.id}\n'
                  'Test: ${report.testName}\n'
                  'Facility: ${report.facility}\n'
                  'Date: ${report.date}\n'
                  'Result: ${report.result}\n'
                  'Status: ${report.status}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report details copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) => _buildContent(context, ref, report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          final fallback = MockPatientData.labReports.firstWhere(
            (r) => r.id == reportId,
            orElse: () => MockPatientData.labReports.first,
          );
          return _buildContent(context, ref, fallback);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, LabReport report) {
    final allReportsAsync = ref.watch(labReportsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.science_outlined,
                          color: Color(0xFF0277BD), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.testName,
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 2),
                          Text(report.facility,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    StatusBadge(
                      status: report.isAbnormal
                          ? StatusType.emergency
                          : StatusType.active,
                      customLabel: report.status,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Date of Test: ${report.date}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Diagnostic Finding / Result', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: report.isAbnormal
                        ? AppColors.emergencyContainer
                        : AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    report.result,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: report.isAbnormal
                          ? AppColors.emergency
                          : AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (report.isAbnormal) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 20, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This diagnostic value is outside normal reference range. Please consult your doctor.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.warning, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ask AI Assistant shortcut
          SectionCard(
            onTap: () => context.push(AppRoutes.aiChat),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ask AI Health Assistant',
                          style: AppTextStyles.titleSmall),
                      Text('Get a simple explanation of this lab report',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Other lab reports
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Other Lab Reports',
                        style: AppTextStyles.titleMedium),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.labReportsList),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(allReportsAsync.valueOrNull ?? MockPatientData.labReports)
                    .where((r) => r.id != report.id)
                    .take(3)
                    .map((r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => context.push('/records/lab/${r.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.testName, style: AppTextStyles.titleSmall),
                                Text(r.date,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          StatusBadge(
                            status: r.isAbnormal
                                ? StatusType.emergency
                                : StatusType.active,
                            customLabel: r.status,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: 'Discuss with Doctor',
            icon: Icons.person_search_outlined,
            onPressed: () => context.push(AppRoutes.findDoctor),
          ),
        ],
      ),
    );
  }
}
