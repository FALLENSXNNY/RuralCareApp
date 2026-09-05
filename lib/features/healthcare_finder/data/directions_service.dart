import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/services/location_service.dart';

/// Model representing a navigation route overview
class HealthcareRoute {
  final String distance;
  final int distanceMeters;
  final String duration;
  final int durationSeconds;
  final String startAddress;
  final String endAddress;
  final List<RouteStep> steps;
  final String googleMapsNavigationUrl;

  const HealthcareRoute({
    required this.distance,
    required this.distanceMeters,
    required this.duration,
    required this.durationSeconds,
    required this.startAddress,
    required this.endAddress,
    required this.steps,
    required this.googleMapsNavigationUrl,
  });

  factory HealthcareRoute.fromJson(Map<String, dynamic> json) {
    return HealthcareRoute(
      distance: json['distance'] as String? ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      duration: json['duration'] as String? ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      startAddress: json['startAddress'] as String? ?? '',
      endAddress: json['endAddress'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => RouteStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      googleMapsNavigationUrl:
          json['googleMapsNavigationUrl'] as String? ?? '',
    );
  }
}

class RouteStep {
  final String instruction;
  final String distance;
  final String duration;

  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }
}

/// Service handling route calculations and launching external navigation
class DirectionsService {
  final ApiClient _apiClient;

  DirectionsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches route directions from backend or falls back to OpenStreetMap OSRM Routing
  Future<HealthcareRoute?> fetchDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    // 1. Try backend endpoint first if available
    try {
      final query =
          'originLat=$originLat&originLng=$originLng&destLat=$destLat&destLng=$destLng';
      final response = await _apiClient.request(
        '/healthcare/directions?$query',
        method: ApiMethod.get,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'];
        if (data is Map<String, dynamic>) {
          return HealthcareRoute.fromJson(data);
        }
      }
    } catch (_) {
      // Backend not running / connection refused -> fallback to free OSRM
    }

    // 2. Free OpenStreetMap OSRM Routing API
    try {
      final osrmUri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$originLng,$originLat;$destLng,$destLat'
        '?overview=false&steps=true',
      );

      final osrmRes = await http
          .get(
            osrmUri,
            headers: {'User-Agent': 'RuralCareApp/1.0 (HealthcareNavigation)'},
          )
          .timeout(const Duration(seconds: 10));

      if (osrmRes.statusCode == 200) {
        final decoded = jsonDecode(osrmRes.body);
        final routes = decoded['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes.first as Map<String, dynamic>;
          final double distanceMeters =
              (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final double durationSec =
              (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;

          final legs = firstRoute['legs'] as List<dynamic>?;
          final stepsList = <RouteStep>[];
          if (legs != null && legs.isNotEmpty) {
            final steps = legs.first['steps'] as List<dynamic>? ?? [];
            for (final st in steps) {
              final maneuver = st['maneuver'] as Map<String, dynamic>? ?? {};
              final type = maneuver['type']?.toString() ?? 'turn';
              final modifier = maneuver['modifier']?.toString() ?? '';
              final name = st['name']?.toString() ?? '';
              final instruction = name.isNotEmpty
                  ? '$type $modifier onto $name'.trim()
                  : '$type $modifier'.trim();

              final stepDistM = (st['distance'] as num?)?.toDouble() ?? 0.0;
              final stepDurS = (st['duration'] as num?)?.toDouble() ?? 0.0;
              stepsList.add(
                RouteStep(
                  instruction: instruction.isNotEmpty ? instruction : 'Continue straight',
                  distance: stepDistM >= 1000
                      ? '${(stepDistM / 1000).toStringAsFixed(1)} km'
                      : '${stepDistM.round()} m',
                  duration: stepDurS >= 60
                      ? '${(stepDurS / 60).round()} min'
                      : '${stepDurS.round()} sec',
                ),
              );
            }
          }

          final distKm = distanceMeters / 1000.0;
          final distStr = distKm >= 1.0
              ? '${distKm.toStringAsFixed(1)} km'
              : '${distanceMeters.round()} m';
          final durationMinutes = (durationSec / 60.0).round();
          final durationStr = durationMinutes > 0
              ? '$durationMinutes mins'
              : '< 1 min';

          return HealthcareRoute(
            distance: distStr,
            distanceMeters: distanceMeters.round(),
            duration: durationStr,
            durationSeconds: durationSec.round(),
            startAddress: 'Your Current Location',
            endAddress: 'Healthcare Facility',
            steps: stepsList,
            googleMapsNavigationUrl:
                'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving',
          );
        }
      }
    } catch (_) {}

    // 3. Mathematical fallback using straight-line distance
    final locationService = LocationService();
    final distKm = locationService.calculateDistanceKm(
      originLat,
      originLng,
      destLat,
      destLng,
    );
    final distM = (distKm * 1000).round();
    final estMinutes = ((distKm / 35.0) * 60).round().clamp(1, 120);

    return HealthcareRoute(
      distance: locationService.formatDistance(distKm),
      distanceMeters: distM,
      duration: '$estMinutes mins',
      durationSeconds: estMinutes * 60,
      startAddress: 'Your Location',
      endAddress: 'Healthcare Facility',
      steps: [
        RouteStep(
          instruction: 'Head towards the healthcare facility',
          distance: locationService.formatDistance(distKm),
          duration: '$estMinutes mins',
        ),
      ],
      googleMapsNavigationUrl:
          'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving',
    );
  }

  /// Launches turn-by-turn navigation in Google Maps
  Future<bool> launchGoogleMapsNavigation({
    required double destLat,
    required double destLng,
    double? originLat,
    double? originLng,
    String? facilityName,
  }) async {
    // 1. Try native Google Navigation intent
    final nativeUri = Uri.parse(
      'google.navigation:q=$destLat,$destLng&mode=d',
    );
    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // 2. Fall back to standard Google Maps Web / App URL
    final originParam = (originLat != null && originLng != null)
        ? '&origin=$originLat,$originLng'
        : '';
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1$originParam&destination=$destLat,$destLng&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    return false;
  }

  /// Launches phone dialer
  Future<bool> launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return false;
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }
}
