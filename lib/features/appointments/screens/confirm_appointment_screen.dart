import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../healthcare_finder/models/healthcare_place.dart';
import '../controller/demo_appointment_controller.dart';

class ConfirmAppointmentScreen extends ConsumerWidget {
  final Map<String, dynamic> appointmentData;

  const ConfirmAppointmentScreen({
    super.key,
    required this.appointmentData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    final doctorName = appointmentData['doctorName'] as String? ?? 'Dr. Krishanu Chakraborty';
    final specialty = appointmentData['specialty'] as String? ?? 'Psychiatrist';
    final facilityName = appointmentData['facilityName'] as String? ?? 'Doctor Clinic';
    final facilityAddress = appointmentData['facilityAddress'] as String? ?? 'Prafulla Nagar Road, Satara';
    final date = appointmentData['date'] as String? ?? 'September 6, 2026';
    final timeSlot = appointmentData['timeSlot'] as String? ?? '10:30 AM';
    final place = appointmentData['place'] as HealthcarePlace?;

    void onConfirm() {
      final appointment = ref.read(demoAppointmentProvider.notifier).bookAppointment(
            doctorName: doctorName,
            specialty: specialty,
            facilityName: facilityName,
            facilityAddress: facilityAddress,
            date: date,
            timeSlot: timeSlot,
            place: place,
          );

      context.go(
        AppRoutes.appointmentConfirmed,
        extra: appointment,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.translate('confirmAppointment'),
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('reviewBookingDetails'),
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.translate('reviewBookingSubtitle'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmation Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.person_rounded,
                            label: loc.translate('doctorLabel'),
                            value: doctorName,
                            iconColor: AppColors.primary,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.medical_services_outlined,
                            label: loc.translate('specialtyLabel'),
                            value: specialty,
                            iconColor: AppColors.primary,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.local_hospital_outlined,
                            label: loc.translate('clinicLabel'),
                            value: facilityName,
                            subvalue: facilityAddress,
                            iconColor: const Color(0xFF00838F),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.calendar_month_rounded,
                            label: loc.translate('dateLabel'),
                            value: date,
                            iconColor: const Color(0xFFE65100),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            label: loc.translate('timeLabel'),
                            value: timeSlot,
                            iconColor: AppColors.healthGreen,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // No Payment Required Demo Badge
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.healthGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.healthGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: AppColors.healthGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate('freeBookingNotice'),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.healthGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.translate('freeBookingSub'),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Confirm Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  loc.translate('confirmBooking'),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subvalue,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              if (subvalue != null && subvalue.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subvalue,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
