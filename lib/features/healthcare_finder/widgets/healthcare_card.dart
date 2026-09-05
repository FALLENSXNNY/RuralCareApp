import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/healthcare_place.dart';

class HealthcareCard extends StatelessWidget {
  final HealthcarePlace place;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback? onBookAppointment;

  const HealthcareCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onCall,
    required this.onDirections,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: place.isEmergency24x7
              ? AppColors.emergencyRed.withOpacity(0.3)
              : AppColors.outlineVariant.withOpacity(0.4),
          width: place.isEmergency24x7 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Badge + Distance Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: place.isEmergency24x7
                            ? AppColors.emergencyRed.withOpacity(0.12)
                            : AppColors.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            place.isEmergency24x7
                                ? Icons.emergency_rounded
                                : (place.hasMaternalCare
                                    ? Icons.pregnant_woman_rounded
                                    : Icons.local_hospital_rounded),
                            size: 14,
                            color: place.isEmergency24x7
                                ? AppColors.emergencyRed
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.type,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: place.isEmergency24x7
                                  ? AppColors.emergencyRed
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.near_me_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.distance.isNotEmpty
                                ? place.distance
                                : 'Nearby',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Facility Name
                Text(
                  place.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Rating & Open status row
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      place.userRatingsTotal > 0
                          ? '${place.rating} (${place.userRatingsTotal})'
                          : '${place.rating} · Verified',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      place.isOpen
                          ? Icons.check_circle_outline_rounded
                          : Icons.access_time_rounded,
                      size: 14,
                      color: place.isOpen
                          ? AppColors.healthGreen
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.isOpen ? loc.translate('openNow') : loc.translate('closed'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: place.isOpen
                            ? AppColors.healthGreen
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: Call & Directions
                Row(
                  children: [
                    // Call Button
                    if (place.phone.isNotEmpty) ...[
                      Expanded(
                        flex: 4,
                        child: OutlinedButton.icon(
                          onPressed: onCall,
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: Text(
                            loc.translate('call'),
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
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
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Directions Button
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        onPressed: onDirections,
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: Text(
                          loc.translate('directions'),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: place.isEmergency24x7
                              ? AppColors.emergencyRed
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Book Appointment Button (Full Width, Doctors & Hospitals only) ─
                if (onBookAppointment != null && place.supportsAppointmentBooking) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onBookAppointment,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text(
                        loc.translate('bookAppointment'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
