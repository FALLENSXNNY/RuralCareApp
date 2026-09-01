import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/prescription.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class PrescriptionViewScreen extends ConsumerWidget {
  const PrescriptionViewScreen({super.key, required this.prescriptionId});
  final String prescriptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rxAsync = ref.watch(prescriptionDetailProvider(prescriptionId));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Prescription Details'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Prescription',
            onPressed: () {
              final rx = rxAsync.valueOrNull ??
                  MockPatientData.prescriptions.firstWhere(
                    (r) => r.id == prescriptionId,
                    orElse: () => MockPatientData.prescriptions.first,
                  );
              final text = 'Prescription #${rx.id}\n'
                  'Doctor: ${rx.doctorName}\n'
                  'Date: ${rx.date}\n'
                  'Medicines:\n${rx.medicines.map((m) => "• $m").join("\n")}\n'
                  'Notes: ${rx.notes}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription details copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: rxAsync.when(
        data: (rx) => _buildContent(context, rx),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          // Fallback to mock data if available
          final fallback = MockPatientData.prescriptions.firstWhere(
            (r) => r.id == prescriptionId,
            orElse: () => MockPatientData.prescriptions.first,
          );
          return _buildContent(context, fallback);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Prescription rx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          // Header info
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
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medication_outlined,
                          color: Color(0xFF6750A4), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prescription #${rx.id}',
                              style: AppTextStyles.titleSmall),
                          const SizedBox(height: 2),
                          Text(rx.doctorName,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('Prescribed on ${rx.date}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Medicines
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prescribed Medicines',
                        style: AppTextStyles.titleMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${rx.medicines.length} Item${rx.medicines.length == 1 ? '' : 's'}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (rx.medicines.isEmpty)
                  Text('No medicines listed',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ...rx.medicines.asMap().entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF6750A4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notes
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text("Doctor's Advice & Instructions",
                        style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  rx.notes.isNotEmpty
                      ? rx.notes
                      : 'Follow prescribed dosages, take after meals and complete the full medication course.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: 'Share with Pharmacy',
            icon: Icons.send_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription shared with nearby PHC pharmacy')),
              );
            },
          ),
        ],
      ),
    );
  }
}
