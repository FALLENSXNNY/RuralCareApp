import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/doctor.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key, required this.doctorId});
  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailProvider(doctorId));
    final l10n = context.l10n;

    final doc = doctorAsync.valueOrNull ??
        MockPatientData.doctors.firstWhere(
          (d) => d.id == doctorId,
          orElse: () => MockPatientData.doctors.first,
        );

    final initial = doc.name.trim().isNotEmpty
        ? doc.name.trim().split(' ').last[0].toUpperCase()
        : 'D';

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(l10n.doctorProfileTitle),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          children: [
            // Doctor card
            SectionCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      initial,
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(doc.name, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    doc.speciality,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.qualification,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.work_outline,
                        label: doc.experience,
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.local_hospital_outlined,
                        label: doc.facility,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Available slots
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.nextAvailableSlot,
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.secondary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          doc.availableSlots,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Online options
            if (doc.acceptsOnline)
              SectionCard(
                child: Row(
                  children: [
                    const Icon(Icons.video_call_outlined,
                        color: AppColors.primary, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.onlineConsultationAvailable,
                              style: AppTextStyles.titleSmall),
                          Text(l10n.videoCallFromPhone,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 22),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            RuralCareButton(
              label: l10n.bookAppointment,
              onPressed: () => _showBookingSheet(context, doc, l10n),
              icon: Icons.calendar_month_outlined,
            ),

            const SizedBox(height: 12),

            if (doc.acceptsOnline)
              RuralCareButton(
                label: l10n.startVideoConsultation,
                onPressed: () => context.push(AppRoutes.videoConsultation),
                variant: RuralCareButtonVariant.secondary,
                icon: Icons.video_call_outlined,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(
      BuildContext context, Doctor doc, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.confirmConsultation, style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.scheduleConsultationWith(doc.name, doc.facility),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.slotLabel(doc.availableSlots),
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              RuralCareButton(
                label: l10n.confirmBooking,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.appointmentConfirmedMsg(
                            doc.name, doc.availableSlots),
                      ),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
