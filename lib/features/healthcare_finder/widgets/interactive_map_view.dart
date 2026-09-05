import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../models/healthcare_place.dart';

/// Real Google Map view with fully working multi-touch (pinch/zoom/pan).
///
/// Key fix: Use a single [EagerGestureRecognizer] which wins the gesture
/// arena immediately, giving the platform view 100% ownership of all
/// pointer events. Do NOT mix Scale+Pan+Tap recognizers – that creates
/// arena contention that breaks multi-touch after the first pointer resolves.
class InteractiveHealthcareMapView extends StatefulWidget {
  final UserLocation? userLocation;
  final List<HealthcarePlace> places;
  final HealthcarePlace? selectedPlace;
  final Function(HealthcarePlace) onPlaceSelected;
  final Function(HealthcarePlace)? onPlaceDetailsTap;
  final VoidCallback onRecenter;
  final bool isRecenterLoading;
  final Function(LatLng center)? onSearchThisArea;

  const InteractiveHealthcareMapView({
    super.key,
    this.userLocation,
    required this.places,
    this.selectedPlace,
    required this.onPlaceSelected,
    this.onPlaceDetailsTap,
    required this.onRecenter,
    this.isRecenterLoading = false,
    this.onSearchThisArea,
  });

  @override
  State<InteractiveHealthcareMapView> createState() =>
      _InteractiveHealthcareMapViewState();
}

class _InteractiveHealthcareMapViewState
    extends State<InteractiveHealthcareMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _currentCameraCenter;
  bool _showSearchThisAreaButton = false;

  static const LatLng _fallbackLocation = LatLng(17.6805, 74.0183);

  // A single EagerGestureRecognizer claims the gesture arena immediately,
  // giving the Android platform view full ownership of every pointer event.
  // This is the only configuration that makes pinch-to-zoom work reliably.
  static final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers =
      <Factory<OneSequenceGestureRecognizer>>{
    Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    _buildMarkers(notify: false);
  }

  @override
  void didUpdateWidget(covariant InteractiveHealthcareMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.places != widget.places ||
        oldWidget.selectedPlace != widget.selectedPlace) {
      _buildMarkers(notify: true);
    }
    if (widget.userLocation != null &&
        (oldWidget.userLocation == null ||
            (oldWidget.userLocation!.latitude - widget.userLocation!.latitude)
                    .abs() >
                0.0001 ||
            (oldWidget.userLocation!.longitude -
                        widget.userLocation!.longitude)
                    .abs() >
                0.0001)) {
      _animateToUserLocation();
      if (mounted) {
        setState(() {
          _showSearchThisAreaButton = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double _getMarkerHue(HealthcarePlace place) {
    if (place.isEmergency24x7) return BitmapDescriptor.hueRed;
    if (place.hasMaternalCare) return BitmapDescriptor.hueRose;
    final cat = place.category.toLowerCase();
    if (cat.contains('clinic')) return BitmapDescriptor.hueGreen;
    if (cat.contains('doctor')) return BitmapDescriptor.hueViolet;
    if (cat.contains('pharmac')) return BitmapDescriptor.hueCyan;
    return BitmapDescriptor.hueAzure;
  }

  void _buildMarkers({bool notify = true}) {
    final Set<Marker> newMarkers = {};

    for (final place in widget.places) {
      if (place.latitude == null || place.longitude == null) continue;

      final isSelected = widget.selectedPlace?.id == place.id;
      final hue = _getMarkerHue(place);

      newMarkers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude!, place.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.type} • ${place.distance}',
            onTap: () {
              if (widget.onPlaceDetailsTap != null) {
                widget.onPlaceDetailsTap!(place);
              } else {
                widget.onPlaceSelected(place);
              }
            },
          ),
          zIndexInt: isSelected ? 2 : 1,
          onTap: () {
            widget.onPlaceSelected(place);
          },
        ),
      );
    }

    _markers.clear();
    _markers.addAll(newMarkers);
    if (notify && mounted) {
      setState(() {});
    }
  }

  void _animateToUserLocation() {
    if (_mapController == null || widget.userLocation == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.userLocation!.latitude,
            widget.userLocation!.longitude,
          ),
          zoom: 14.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = widget.userLocation != null
        ? LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude)
        : _fallbackLocation;

    // StackFit.expand gives the first non-positioned child (GoogleMap) the
    // full parent size explicitly. This guarantees RenderPlatformView has a
    // non-zero size before any touch arrives — fixing the hit-test crash.
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        // GoogleMap as direct non-positioned child — gets full size from
        // StackFit.expand without needing a Positioned.fill wrapper.
        GoogleMap(
            key: const ValueKey('interactive_healthcare_map_view'),
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14.0,
            ),
            markers: Set<Marker>.from(_markers),
            myLocationEnabled: widget.userLocation != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            // Single EagerGestureRecognizer — the ONLY correct fix for
            // multi-touch on Android hybrid platform views.
            gestureRecognizers: _gestureRecognizers,
            onCameraMove: (CameraPosition pos) {
              _currentCameraCenter = pos.target;
            },
            onCameraIdle: () {
              if (_currentCameraCenter != null &&
                  widget.onSearchThisArea != null) {
                final userLat = widget.userLocation?.latitude ??
                    _fallbackLocation.latitude;
                final userLng = widget.userLocation?.longitude ??
                    _fallbackLocation.longitude;
                final diffLat =
                    (_currentCameraCenter!.latitude - userLat).abs();
                final diffLng =
                    (_currentCameraCenter!.longitude - userLng).abs();
                if (diffLat > 0.008 || diffLng > 0.008) {
                  if (!_showSearchThisAreaButton && mounted) {
                    setState(() {
                      _showSearchThisAreaButton = true;
                    });
                  }
                } else {
                  if (_showSearchThisAreaButton && mounted) {
                    setState(() {
                      _showSearchThisAreaButton = false;
                    });
                  }
                }
              }
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (widget.userLocation != null) {
                _animateToUserLocation();
              }
              // Re-build markers after map is ready
              if (mounted) {
                setState(() {});
              }
            },
          ),

        // "Search This Area" pill — shown when camera is panned away
        if (_showSearchThisAreaButton && widget.onSearchThisArea != null)
          Positioned(
            top: 12,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentCameraCenter != null) {
                  setState(() {
                    _showSearchThisAreaButton = false;
                  });
                  widget.onSearchThisArea!(_currentCameraCenter!);
                }
              },
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Search This Area'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                elevation: 4,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

        // GPS acquiring indicator
        if (widget.isRecenterLoading)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Acquiring GPS...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
