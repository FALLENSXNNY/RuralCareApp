import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/directions_service.dart';
import '../models/healthcare_place.dart';

class HealthcareDetailsScreen extends StatelessWidget {
  final HealthcarePlace place;

  const HealthcareDetailsScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final directionsService = DirectionsService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.translate('facilityDetails'),
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: place.isEmergency24x7
            ? AppColors.emergencyRed
            : AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: loc.translate('share'),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text:
                    '${place.name}\n${place.address}\nPhone: ${place.phone}\n${place.googleMapsUrl}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.translate('copiedToClipboard')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Facility Name & Badges Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(
                        color: place.isEmergency24x7
                            ? AppColors.emergencyRed.withOpacity(0.3)
                            : AppColors.outlineVariant.withOpacity(0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: place.isEmergency24x7
                                    ? AppColors.emergencyRed.withOpacity(0.12)
                                    : AppColors.primaryContainer
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
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
                                    size: 16,
                                    color: place.isEmergency24x7
                                        ? AppColors.emergencyRed
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    place.type,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: place.isEmergency24x7
                                          ? AppColors.emergencyRed
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                                border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                place.distance.isNotEmpty
                                    ? place.distance
                                    : 'Nearby',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          place.name,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${place.rating} (${place.userRatingsTotal > 0 ? place.userRatingsTotal : "80+"} ${loc.translate('reviews')})',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Embedded Google Map Preview Card
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLg),
                    child: Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8ECEF),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (place.latitude != null && place.longitude != null)
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(place.latitude!, place.longitude!),
                                zoom: 15.0,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(place.id),
                                  position: LatLng(place.latitude!, place.longitude!),
                                  infoWindow: InfoWindow(
                                    title: place.name,
                                    snippet: place.address,
                                  ),
                                ),
                              },
                              liteModeEnabled: false,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                            )
                          else
                            const Center(
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          // View Full Map Button Overlay
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push(
                                '/directions',
                                extra: place,
                              ),
                              icon: const Icon(Icons.fullscreen_rounded, size: 16),
                              label: Text(loc.translate('viewInFullMap')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Cards: Address, Phone, Hours
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    title: loc.translate('address'),
                    content: place.address,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: loc.translate('copy'),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: place.address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(loc.translate('copiedToClipboard')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (place.phone.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.phone_rounded,
                      title: loc.translate('contactNumber'),
                      content: place.phone,
                      badge: loc.translate('verified'),
                    ),
                  const SizedBox(height: 10),

                  _buildInfoCard(
                    icon: Icons.access_time_rounded,
                    title: loc.translate('timing'),
                    content: place.hours,
                  ),
                  const SizedBox(height: 16),

                  // Verified Services
                  Text(
                    loc.translate('verifiedServices'),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (place.services.isNotEmpty
                            ? place.services
                            : [
                                '24x7 Emergency Services',
                                'Maternal Delivery Care',
                                'Essential Diagnostics',
                                'Pharmacy',
                              ])
                        .map((service) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                                border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: AppColors.healthGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    service,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Bar (Call & Directions min 56dp height)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (place.phone.isNotEmpty) ...[
                        Expanded(
                          flex: 4,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                directionsService.launchPhoneCall(place.phone),
                            icon: const Icon(Icons.call_rounded, size: 20),
                            label: Text(
                              loc.translate('call'),
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 5,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/directions',
                            extra: place,
                          ),
                          icon: const Icon(Icons.directions_rounded, size: 22),
                          label: Text(
                            loc.translate('getDirections'),
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
                            minimumSize: const Size.fromHeight(50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (place.supportsAppointmentBooking) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.bookAppointment,
                          extra: place,
                        ),
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
                          minimumSize: const Size.fromHeight(46),
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
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? badge,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.healthGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.healthGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
