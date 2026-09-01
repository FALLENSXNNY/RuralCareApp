import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/consultation.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class ConsultationSummaryScreen extends ConsumerWidget {
  const ConsultationSummaryScreen({super.key, required this.consultationId});
  final String consultationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conAsync = ref.watch(consultationDetailProvider(consultationId));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Consultation Summary'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Summary',
            onPressed: () {
              final con = conAsync.valueOrNull ??
                  MockPatientData.consultations.firstWhere(
                    (c) => c.id == consultationId,
                    orElse: () => MockPatientData.consultations.first,
                  );
              final text = 'Clinical Consultation Summary #${con.id}\n'
                  'Doctor: ${con.doctorName} (${con.doctorSpeciality})\n'
                  'Facility: ${con.facility}\n'
                  'Date: ${con.date}\n'
                  'Diagnosis: ${con.diagnosis}\n'
                  'Plan: ${con.plan}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consultation details copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: conAsync.when(
        data: (con) => _buildContent(context, con),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          final fallback = MockPatientData.consultations.firstWhere(
            (c) => c.id == consultationId,
            orElse: () => MockPatientData.consultations.first,
          );
          return _buildContent(context, fallback);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Consultation con) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          // Visit info
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.person_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(con.doctorName,
                              style: AppTextStyles.titleMedium),
                          Text(con.doctorSpeciality,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(
                        con.type,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _row(Icons.calendar_today, 'Date of Visit', con.date),
                const SizedBox(height: 8),
                _row(Icons.local_hospital_outlined, 'Healthcare Facility',
                    con.facility),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chief complaints / Symptoms
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reported Symptoms & Complaints',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                if (con.complaints.isEmpty)
                  Text('Routine clinical follow-up',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMuted)),
                ...con.complaints.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle,
                                size: 6, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(c,
                                  style: AppTextStyles.bodyMedium)),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Diagnosis
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clinical Diagnosis',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    con.diagnosis.isNotEmpty
                        ? con.diagnosis
                        : 'General Clinical Review',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Plan / Doctor Notes
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text("Doctor's Care Plan & Advice",
                        style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  con.plan.isNotEmpty
                      ? con.plan
                      : 'Follow up as advised. Continue prescribed medications.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: 'View Prescriptions & Reports',
            icon: Icons.folder_open_outlined,
            onPressed: () => context.push(AppRoutes.recordsHub),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        Expanded(
          child: Text(value,
              style: AppTextStyles.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
