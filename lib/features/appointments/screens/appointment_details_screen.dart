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
import '../models/demo_appointment.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  final String appointmentId;
  final DemoAppointment? initialAppointment;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
    this.initialAppointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(demoAppointmentProvider);
    final appointment = ref.read(demoAppointmentProvider.notifier).getAppointmentById(appointmentId) ??
        initialAppointment ??
        state.selectedAppointment ??
        DemoAppointment(
          id: appointmentId,
          doctorName: 'Dr. Krishanu Chakraborty',
          specialty: 'Psychiatrist',
          facilityName: 'Doctor Clinic',
          facilityAddress: 'Prafulla Nagar Road, Satara',
          date: 'September 6, 2026',
          timeSlot: '10:30 AM',
          status: AppointmentStatus.confirmed,
          createdAt: DateTime.now(),
        );

    final isCheckedIn = appointment.isCheckedIn;

    void onGetDirections() {
      final place = appointment.place ??
          HealthcarePlace(
            id: 'place_doctor_clinic',
            name: appointment.facilityName,
            category: 'Doctors',
            type: appointment.specialty,
            address: appointment.facilityAddress,
            latitude: 17.6805,
            longitude: 74.0183,
            distance: '2.3 km',
            distanceKm: 2.3,
            phone: '+91 2162 233 444',
            hours: '10:00 AM – 7:00 PM',
          );

      context.push(AppRoutes.directions, extra: place);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.translate('appointmentDetails'),
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
                    // Doctor Summary Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.doctorName,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      appointment.specialty,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Facility Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_hospital_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.facilityName,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        appointment.facilityAddress,
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

                          const Divider(height: 24),

                          // Details List
                          _buildInfoRow(
                            icon: Icons.calendar_month_rounded,
                            label: loc.translate('dateLabel'),
                            value: appointment.date,
                            color: const Color(0xFFE65100),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            label: loc.translate('timeLabel'),
                            value: appointment.timeSlot,
                            color: AppColors.healthGreen,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.tag_rounded,
                            label: loc.translate('appointmentIdLabel'),
                            value: appointment.id,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: isCheckedIn
                                ? Icons.confirmation_number_rounded
                                : Icons.check_circle_outline_rounded,
                            label: loc.translate('statusLabel'),
                            value: isCheckedIn
                                ? 'Checked In (${appointment.queueToken ?? "A024"})'
                                : loc.translate('confirmed'),
                            color: isCheckedIn
                                ? AppColors.healthGreen
                                : AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    if (isCheckedIn) ...[
                      const SizedBox(height: 16),
                      // Queue Token Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.healthGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.healthGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.healthGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                appointment.queueToken ?? 'A024',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.translate('checkedInNotice'),
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.healthGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.translate('trackInLiveQueue'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Buttons
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Check In or View Live Queue Button
                  if (!isCheckedIn)
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/care/appointments/${appointment.id}/checkin',
                          extra: appointment,
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: Text(
                        loc.translate('checkIn'),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.healthGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.liveQueue);
                      },
                      icon: const Icon(Icons.confirmation_number_rounded,
                          size: 18),
                      label: Text(
                        loc.translate('viewLiveQueue'),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Get Directions Button (reusing existing directions map)
                  OutlinedButton.icon(
                    onPressed: onGetDirections,
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: Text(
                      loc.translate('getDirections'),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
