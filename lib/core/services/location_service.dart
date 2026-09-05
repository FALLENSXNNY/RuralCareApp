import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Permission status enumeration for location services
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  unknown,
}

/// Normalized user location snapshot
class UserLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? placename;
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.placename,
    required this.timestamp,
  });

  /// Default fallback location for Satara rural district (Maharashtra, India)
  static final UserLocation fallbackRuralSatara = UserLocation(
    latitude: 17.6805,
    longitude: 74.0183,
    accuracy: 100.0,
    placename: 'Satara District, Maharashtra',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'placename': placename,
        'timestamp': timestamp.toIso8601String(),
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      placename: json['placename'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service handling device GPS queries, permissions, and distance computation
class LocationService {
  LocationService();

  /// Check current location permission and service status
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unknown;
      }
    } catch (e) {
      debugPrint('LocationService.checkPermission error: $e');
      return LocationPermissionStatus.unknown;
    }
  }

  /// Request location permission from the operating system
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unknown;
      }
    } catch (e) {
      debugPrint('LocationService.requestPermission error: $e');
      return LocationPermissionStatus.unknown;
    }
  }

  /// Fetch current device GPS location with timeout fallback
  Future<UserLocation?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final status = await checkPermission();
      if (status != LocationPermissionStatus.granted) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      ).timeout(timeout);

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        placename: 'Detected GPS Location',
        timestamp: position.timestamp,
      );
    } on TimeoutException {
      debugPrint('LocationService.getCurrentLocation: Timed out');
      // Attempt to retrieve last known position as fallback
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return UserLocation(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          accuracy: lastKnown.accuracy,
          placename: 'Last Known Location',
          timestamp: lastKnown.timestamp,
        );
      }
      return null;
    } catch (e) {
      debugPrint('LocationService.getCurrentLocation error: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinate pairs in Kilometers using Haversine formula
  double calculateDistanceKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(endLatitude - startLatitude);
    final dLon = _degreesToRadians(endLongitude - startLongitude);

    final lat1 = _degreesToRadians(startLatitude);
    final lat2 = _degreesToRadians(endLatitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Format distance into patient-friendly string (e.g., '850 m' or '3.4 km')
  String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Open application settings for permanently denied permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings when GPS services are disabled
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
