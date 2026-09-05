import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/language_selector_modal.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(l10n.profileTitle),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded, color: AppColors.primary),
            tooltip: l10n.changeLanguage,
            onPressed: () => LanguageSelectorModal.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editProfile,
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: patientAsync.when(
        data: (patient) => _buildProfileContent(context, ref, patient),
        loading: () {
          final cached = ref.read(localStorageProvider).patientProfile;
          if (cached != null) {
            return _buildProfileContent(context, ref, cached);
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          final cached = ref.read(localStorageProvider).patientProfile;
          if (cached != null) {
            return _buildProfileContent(context, ref, cached);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.emergency),
                const SizedBox(height: 16),
                Text('Could not load profile: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentPatientProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, WidgetRef ref, Patient patient) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final activeLanguageName =
        AppLocalizations.languageNames[currentLocale.languageCode] ?? 'English';

    final displayName =
        patient.name.isNotEmpty ? patient.name : 'Patient';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';
    final locationText = [
      if (patient.village.isNotEmpty) patient.village,
      if (patient.district.isNotEmpty) patient.district,
      if (patient.state.isNotEmpty) patient.state,
    ].join(', ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        children: [
          // Avatar + name
          SectionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    initial,
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        patient.phone.isNotEmpty ? patient.phone : 'No phone',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                      if (locationText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationText,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Basic medical info
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.personalDetails, style: AppTextStyles.titleLarge),
                const SizedBox(height: 16),
                _profileRow(
                  Icons.calendar_today_outlined,
                  l10n.age,
                  patient.age > 0 ? '${patient.age} years' : 'Not specified',
                  AppColors.primary,
                ),
                const Divider(height: 24),
                _profileRow(
                  Icons.person_outline,
                  l10n.gender,
                  patient.gender.isNotEmpty ? patient.gender : 'Not specified',
                  AppColors.secondary,
                ),
                const Divider(height: 24),
                _profileRow(
                  Icons.bloodtype_outlined,
                  l10n.bloodGroup,
                  patient.bloodGroup.isNotEmpty
                      ? patient.bloodGroup
                      : 'Not specified',
                  AppColors.emergency,
                ),
                if (patient.abhaId.isNotEmpty) ...[
                  const Divider(height: 24),
                  _profileRow(
                    Icons.badge_outlined,
                    l10n.abhaIdLabel,
                    patient.abhaId,
                    AppColors.primary,
                  ),
                ],
                if (patient.gender.toLowerCase() == 'female' && patient.isPregnant) ...[
                  const Divider(height: 24),
                  _profileRow(
                    Icons.pregnant_woman_rounded,
                    l10n.pregnancyTitle,
                    '${l10n.yesPregnant} (${l10n.currentWeek(patient.gestationalWeek ?? 24)})',
                    const Color(0xFFC2185B),
                  ),
                ],
                if (patient.emergencyContactName.isNotEmpty || patient.emergencyContactPhone.isNotEmpty) ...[
                  const Divider(height: 24),
                  _profileRow(
                    Icons.contact_phone_outlined,
                    l10n.emergencyContactSection,
                    '${patient.emergencyContactName}${patient.emergencyContactPhone.isNotEmpty ? ' (${patient.emergencyContactPhone})' : ''}',
                    AppColors.emergency,
                  ),
                ],
                if (patient.allergies.isNotEmpty) ...[
                  const Divider(height: 24),
                  _profileRow(
                    Icons.warning_amber_outlined,
                    l10n.allergies,
                    patient.allergies.join(', '),
                    AppColors.warning,
                  ),
                ],
                if (patient.conditions.isNotEmpty) ...[
                  const Divider(height: 24),
                  _profileRow(
                    Icons.medical_information_outlined,
                    l10n.chronicConditions,
                    patient.conditions.join(', '),
                    AppColors.info,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings section
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settings, style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                _settingsTile(
                  Icons.language_outlined,
                  l10n.appLanguage,
                  activeLanguageName,
                  onTap: () => LanguageSelectorModal.show(context),
                ),
                const Divider(height: 1),
                _settingsTile(
                  Icons.download_outlined,
                  'Offline Emergency Content',
                  'Download for use without internet',
                  onTap: () => context.go(AppRoutes.offlineSettings),
                ),
                const Divider(height: 1),
                _settingsTile(
                  Icons.notifications_outlined,
                  'Notifications',
                  'Appointments, reminders',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: l10n.logout,
            onPressed: () async {
              await ref.read(firebaseAuthServiceProvider).signOut();
              ref.invalidate(currentPatientProvider);
              ref.invalidate(healthTimelineProvider);
              ref.invalidate(prescriptionsProvider);
              ref.invalidate(labReportsProvider);
              ref.invalidate(referralsProvider);
              ref.invalidate(consultationsProvider);
              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            variant: RuralCareButtonVariant.outline,
            icon: Icons.logout,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              Text(value, style: AppTextStyles.titleSmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      onTap: onTap,
      dense: true,
    );
  }
}
