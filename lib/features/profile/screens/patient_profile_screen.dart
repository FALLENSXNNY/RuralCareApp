import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
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
                  child: const Text('Retry'),
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
                      Text(displayName, style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 4),
                      Text(patient.phone,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textMuted)),
                      if (locationText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          locationText,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ID card
          if (patient.id.isNotEmpty) ...[
            SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient ID',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted)),
                      Text(patient.id, style: AppTextStyles.titleSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Health details
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Details', style: AppTextStyles.titleLarge),
                const SizedBox(height: 16),
                _profileRow(Icons.cake_outlined, 'Age',
                    patient.age > 0 ? '${patient.age} years' : 'Not set', AppColors.primary),
                const Divider(height: 20),
                _profileRow(Icons.person_outline, 'Gender',
                    patient.gender.isNotEmpty ? patient.gender : 'Not set', AppColors.primary),
                const Divider(height: 20),
                _profileRow(Icons.water_drop_outlined, 'Blood Group',
                    patient.bloodGroup.isNotEmpty ? patient.bloodGroup : "Don't Know", AppColors.emergency),
                const Divider(height: 20),
                _profileRow(
                    Icons.medical_information_outlined,
                    'Conditions',
                    patient.conditions.isNotEmpty
                        ? patient.conditions.join(', ')
                        : 'None reported',
                    AppColors.warning),
                const Divider(height: 20),
                _profileRow(
                    Icons.warning_amber_outlined,
                    'Allergies',
                    patient.allergies.isNotEmpty
                        ? patient.allergies.join(', ')
                        : 'None reported',
                    AppColors.emergency),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings section
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
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
                const Divider(height: 1),
                _settingsTile(
                  Icons.language_outlined,
                  'Language',
                  'English',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: 'Sign Out',
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
