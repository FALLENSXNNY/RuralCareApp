import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/emergency_button.dart';
import '../../../core/widgets/section_card.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);
    final cached = ref.read(localStorageProvider).patientProfile;

    // Use live patient data if resolved, or cached profile, or default fallback
    final Patient patient = patientAsync.valueOrNull ??
        cached ??
        MockPatientData.currentPatient;

    final displayName =
        patient.name.isNotEmpty ? patient.name : 'Patient';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';
    final locationText = [
      if (patient.village.isNotEmpty) patient.village,
      if (patient.district.isNotEmpty) patient.district,
    ].join(', ');

    final rxList = ref.watch(prescriptionsProvider).valueOrNull ??
        MockPatientData.prescriptions;
    final refList = ref.watch(referralsProvider).valueOrNull ??
        MockPatientData.referrals;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── App bar / header ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.profile),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.surface,
                                  child: Text(
                                    initial,
                                    style: AppTextStyles.titleMedium
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Namaste, $displayName',
                                      style: AppTextStyles.titleLarge
                                          .copyWith(color: Colors.white),
                                    ),
                                    if (locationText.isNotEmpty)
                                      Text(
                                        locationText,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8)),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Emergency call banner
                          EmergencyButton(
                            label: 'Emergency / 108 Ambulance',
                            onPressed: () => context.go(AppRoutes.emergency),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Body content ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Quick action grid ──────────────────────────
                          Text('Quick Actions',
                              style: AppTextStyles.titleLarge),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Ask\nAI',
                                  color: AppColors.primary,
                                  onTap: () =>
                                      context.go(AppRoutes.aiChat),
                                ),
                              ),
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.video_call_outlined,
                                  label: 'Talk to\nDoctor',
                                  color: AppColors.secondary,
                                  onTap: () =>
                                      context.go(AppRoutes.videoConsultation),
                                ),
                              ),
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.local_hospital_outlined,
                                  label: 'Find\nFacility',
                                  color: const Color(0xFF00838F),
                                  onTap: () =>
                                      context.go(AppRoutes.facilityFinder),
                                ),
                              ),
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.folder_outlined,
                                  label: 'My Health\nRecords',
                                  color: const Color(0xFF6750A4),
                                  onTap: () =>
                                      context.go(AppRoutes.recordsHub),
                                ),
                              ),
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.upload_file_outlined,
                                  label: 'Upload\nDocs',
                                  color: const Color(0xFF0277BD),
                                  onTap: () => context.go(AppRoutes.documentUpload),
                                ),
                              ),
                              _QuickActionTile(
                                action: _QuickAction(
                                  icon: Icons.person_search_outlined,
                                  label: 'Find\nDoctor',
                                  color: const Color(0xFFE65100),
                                  onTap: () =>
                                      context.go(AppRoutes.findDoctor),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Health profile summary card ────────────────
                          Text('Health Profile',
                              style: AppTextStyles.titleLarge),
                          const SizedBox(height: 8),
                          SectionCard(
                            onTap: () => context.go(AppRoutes.profile),
                            child: Column(
                              children: [
                                _HealthInfoRow(
                                  icon: Icons.bloodtype_outlined,
                                  label: 'Blood Group',
                                  value: patient.bloodGroup.isNotEmpty
                                      ? patient.bloodGroup
                                      : "Don't Know",
                                  color: AppColors.emergency,
                                ),
                                const Divider(height: 16),
                                _HealthInfoRow(
                                  icon: Icons.medical_information_outlined,
                                  label: 'Conditions',
                                  value: patient.conditions.isNotEmpty
                                      ? patient.conditions.join(', ')
                                      : 'None recorded',
                                  color: AppColors.warning,
                                ),
                                const Divider(height: 16),
                                _HealthInfoRow(
                                  icon: Icons.warning_amber_outlined,
                                  label: 'Allergies',
                                  value: patient.allergies.isNotEmpty
                                      ? patient.allergies.join(', ')
                                      : 'No known allergies',
                                  color: AppColors.emergency,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Recent prescriptions ─────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Prescriptions',
                                  style: AppTextStyles.titleLarge),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.recordsHub),
                                child: Text('See All',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (rxList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('No prescriptions found',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textMuted)),
                            ),

                          ...rxList.take(2).map(
                            (rx) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SectionCard(
                                onTap: () => context
                                    .go('/records/prescription/${rx.id}'),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          Icons.medication_outlined,
                                          color: AppColors.primary,
                                          size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(rx.doctorName,
                                              style: AppTextStyles.titleSmall),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${rx.medicines.length} medicines · ${rx.date}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                        color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Referrals ────────────────────────────────────
                          if (refList.isNotEmpty) ...[
                            Text('Active Referrals',
                                style: AppTextStyles.titleLarge),
                            const SizedBox(height: 8),
                            ...refList.map((referralItem) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SectionCard(
                                    onTap: () => context.go(
                                        '/records/referral/${referralItem.id}'),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                              Icons.transfer_within_a_station,
                                              color: AppColors.secondary,
                                              size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(referralItem.referredTo,
                                                  style:
                                                      AppTextStyles.titleSmall),
                                              const SizedBox(height: 2),
                                              Text(referralItem.speciality,
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                          color: AppColors
                                                              .textMuted)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF8E1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(referralItem.status,
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                      color:
                                                          AppColors.warning)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthInfoRow extends StatelessWidget {
  const _HealthInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted)),
              Text(value, style: AppTextStyles.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}
