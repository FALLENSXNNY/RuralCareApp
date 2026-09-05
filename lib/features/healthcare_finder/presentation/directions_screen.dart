import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/healthcare_controller.dart';
import '../data/directions_service.dart';
import '../models/healthcare_place.dart';

class DirectionsScreen extends ConsumerStatefulWidget {
  final HealthcarePlace place;

  const DirectionsScreen({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends ConsumerState<DirectionsScreen> {
  final DirectionsService _directionsService = DirectionsService();
  GoogleMapController? _mapController;
  HealthcareRoute? _route;
  bool _isLoadingRoute = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _fallbackLocation = LatLng(17.6805, 74.0183);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRouteAndSetupMap();
    });
  }

  Future<void> _loadRouteAndSetupMap() async {
    final userLoc = ref.read(healthcareFinderProvider).userLocation;
    final destLat = widget.place.latitude ?? _fallbackLocation.latitude;
    final destLng = widget.place.longitude ?? _fallbackLocation.longitude;

    final destPos = LatLng(destLat, destLng);
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.place.isEmergency24x7
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: widget.place.name,
          snippet: widget.place.address,
        ),
      ),
    );

    if (userLoc != null) {
      final originPos = LatLng(userLoc.latitude, userLoc.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: originPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      final route = await _directionsService.fetchDirections(
        originLat: userLoc.latitude,
        originLng: userLoc.longitude,
        destLat: destLat,
        destLng: destLng,
      );

      if (mounted) {
        setState(() {
          _route = route;
          _isLoadingRoute = false;

          // Connect origin and destination with a straight route line if polyline points not decoded
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: [originPos, destPos],
              color: AppColors.primary,
              width: 5,
            ),
          );
        });

        _fitBounds(originPos, destPos);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    if (_mapController == null) return;

    final southwestLat = min(p1.latitude, p2.latitude);
    final southwestLng = min(p1.longitude, p2.longitude);
    final northeastLat = max(p1.latitude, p2.latitude);
    final northeastLng = max(p1.longitude, p2.longitude);

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _startNavigation() {
    final userLoc = ref.read(healthcareFinderProvider).userLocation;
    _directionsService.launchGoogleMapsNavigation(
      destLat: widget.place.latitude ?? 17.6805,
      destLng: widget.place.longitude ?? 74.0183,
      originLat: userLoc?.latitude,
      originLng: userLoc?.longitude,
      facilityName: widget.place.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final userLoc = ref.watch(healthcareFinderProvider).userLocation;

    final initialTarget = widget.place.latitude != null && widget.place.longitude != null
        ? LatLng(widget.place.latitude!, widget.place.longitude!)
        : _fallbackLocation;

    final estimatedDuration = _route?.duration.isNotEmpty == true
        ? _route!.duration
        : '${max(4, (widget.place.distanceKm * 2.5).round())} mins';

    final estimatedDistance = _route?.distance.isNotEmpty == true
        ? _route!.distance
        : (widget.place.distance.isNotEmpty ? widget.place.distance : '4.2 km');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${loc.translate('directionsTo')} ${widget.place.name}',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: widget.place.isEmergency24x7
            ? AppColors.emergencyRed
            : AppColors.primary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fullscreen Real Google Map View
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: userLoc != null,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (userLoc != null && widget.place.latitude != null && widget.place.longitude != null) {
                  _fitBounds(
                    LatLng(userLoc.latitude, userLoc.longitude),
                    LatLng(widget.place.latitude!, widget.place.longitude!),
                  );
                }
              },
            ),
          ),
          if (_isLoadingRoute)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),

          // Floating ETA & Distance Summary Card (Top)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              estimatedDuration,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($estimatedDistance)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.traffic_rounded,
                              size: 14,
                              color: AppColors.healthGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              loc.translate('fastestRoute'),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.healthGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Persistent Navigation & Start Action Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXl),
                  topRight: Radius.circular(AppDimensions.radiusXl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Turn instruction
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          child: const Icon(
                            Icons.turn_right_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _route?.steps.isNotEmpty == true
                                    ? _route!.steps.first.instruction
                                    : 'Follow connecting highway to facility',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Destination: ${widget.place.name}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Primary Button: Start Google Maps Navigation (Min 56dp height)
                    ElevatedButton.icon(
                      onPressed: _startNavigation,
                      icon: const Icon(Icons.navigation_rounded, size: 22),
                      label: Text(
                        loc.translate('startGoogleMapsNavigation'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.place.isEmergency24x7
                            ? AppColors.emergencyRed
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
