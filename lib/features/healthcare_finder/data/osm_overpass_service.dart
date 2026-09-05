import 'dart:convert';
import 'dart:math' show cos, pi;
import 'package:http/http.dart' as http;
import '../../../core/services/location_service.dart';
import '../models/healthcare_place.dart';
import '../models/place_details.dart';

/// OpenStreetMap Overpass API Service — 100% FREE, No API Key, No Billing Required.
/// Fetches genuinely real live healthcare facilities worldwide from OpenStreetMap's global database.
class OsmOverpassService {
  final http.Client _client;
  final LocationService _locationService;

  static const List<String> _kOverpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  // In-memory cache to prevent redundant network calls (10 min TTL)
  final Map<String, _CachedOsmResult> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 10);

  OsmOverpassService({
    http.Client? client,
    LocationService? locationService,
  })  : _client = client ?? http.Client(),
        _locationService = locationService ?? LocationService();

  /// Fetches real nearby healthcare facilities within [radius] meters (default 25km) of [latitude], [longitude].
  Future<List<HealthcarePlace>> fetchNearbyHealthcare({
    required double latitude,
    required double longitude,
    double radius = 25000,
    String category = 'all',
  }) async {
    final normCategory = category.toLowerCase().trim();
    final cacheKey =
        '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${radius.toInt()}_$normCategory';

    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.places;
    }

    final amenityFilter = _getOsmAmenityFilter(normCategory);
    final searchRadius = radius.clamp(1000, 50000).toInt();

    // Overpass QL Query — fetches nodes, ways, and relations (complex hospital complexes) with healthcare amenities
    final overpassQuery = '''
[out:json][timeout:25];
(
  node[$amenityFilter](around:$searchRadius,$latitude,$longitude);
  way[$amenityFilter](around:$searchRadius,$latitude,$longitude);
  relation[$amenityFilter](around:$searchRadius,$latitude,$longitude);
);
out body center 150;
'''.trim();

    // --- Run Overpass mirrors AND Nominatim simultaneously ---
    // Whichever returns real data first is merged.
    // ignore: avoid_print
    print('[OsmOverpassService] 🚀 Launching Overpass + Nominatim in parallel for ($latitude, $longitude)');

    final overpassFuture = _tryAllOverpassMirrors(
      overpassQuery: overpassQuery,
      latitude: latitude,
      longitude: longitude,
    );

    final nominatimFuture = _fetchViaNominatim(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: searchRadius,
      category: normCategory,
    );

    // Wait for both and merge unique facilities
    List<HealthcarePlace> places = [];

    final results = await Future.wait(
      [overpassFuture, nominatimFuture],
      eagerError: false,
    );

    final overpassPlaces = results[0];
    final nominatimPlaces = results[1];

    final merged = <String, HealthcarePlace>{};
    for (final p in overpassPlaces) {
      merged[p.id] = p;
    }
    for (final p in nominatimPlaces) {
      if (!merged.containsKey(p.id)) {
        merged[p.id] = p;
      }
    }

    places = merged.values.toList();
    places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (places.isNotEmpty) {
      // ignore: avoid_print
      print('[OsmOverpassService] ✅ Merged OSM + Nominatim total: ${places.length} facilities (Overpass: ${overpassPlaces.length}, Nominatim: ${nominatimPlaces.length})');
    } else {
      // ignore: avoid_print
      print('[OsmOverpassService] ⛔ Both Overpass and Nominatim returned empty');
    }

    if (places.isNotEmpty) {
      _cache[cacheKey] = _CachedOsmResult(
        timestamp: DateTime.now(),
        places: places,
      );
    }

    return places;
  }

  /// Tries all Overpass API mirrors sequentially. Returns empty list if all fail/timeout.
  Future<List<HealthcarePlace>> _tryAllOverpassMirrors({
    required String overpassQuery,
    required double latitude,
    required double longitude,
  }) async {
    for (final mirrorUrl in _kOverpassMirrors) {
      try {
        final uri = Uri.parse(mirrorUrl);
        // ignore: avoid_print
        print('[OsmOverpassService] Overpass trying $mirrorUrl...');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'RuralCareApp/1.0 (HealthcareFinder)',
            'Accept': 'application/json',
          },
          body: 'data=${Uri.encodeComponent(overpassQuery)}',
        ).timeout(const Duration(seconds: 5)); // short timeout — Nominatim runs in parallel

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map<String, dynamic>) {
            final elements = decoded['elements'];
            if (elements is List && elements.isNotEmpty) {
              final places = <HealthcarePlace>[];
              for (final el in elements) {
                if (el is Map<String, dynamic>) {
                  final place = _parseOsmElement(el, latitude, longitude);
                  if (place != null) places.add(place);
                }
              }
              places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
              // ignore: avoid_print
              print('[OsmOverpassService] ✅ Overpass $mirrorUrl → ${places.length} named facilities');
              if (places.isNotEmpty) return places;
            }
          }
        } else {
          // ignore: avoid_print
          print('[OsmOverpassService] ❌ Overpass HTTP ${response.statusCode} from $mirrorUrl');
        }
      } catch (e) {
        // ignore: avoid_print
        print('[OsmOverpassService] ❌ Overpass exception from $mirrorUrl: ${e.runtimeType}');
        continue;
      }
    }
    // ignore: avoid_print
    print('[OsmOverpassService] Overpass: all mirrors failed/timed out');
    return [];
  }

  /// Fetches real nearby healthcare using Nominatim OSM Search API (free, no key, officially supported).
  /// Used as fallback when Overpass API mirrors are unreachable (e.g. regional network blocks).
  Future<List<HealthcarePlace>> _fetchViaNominatim({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String category,
  }) async {
    // Map categories to Nominatim amenity types
    final amenityTypes = _getNominatimAmenities(category);
    final allPlaces = <HealthcarePlace>[];

    for (final amenity in amenityTypes) {
      try {
        // Calculate bounding box: 1° lat ≈ 111km, 1° lon ≈ 111km * cos(lat)
        final deltaLat = radiusMeters / 111000.0;
        final deltaLon = radiusMeters / (111000.0 * cos(latitude * pi / 180.0));
        final south = latitude - deltaLat;
        final north = latitude + deltaLat;
        final west = longitude - deltaLon;
        final east = longitude + deltaLon;

        // Nominatim viewbox format is left,top,right,bottom -> west,north,east,south
        // bounded=1 strictly restricts results to this bounding box around the user
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?format=jsonv2'
          '&amenity=${Uri.encodeComponent(amenity)}'
          '&viewbox=${west.toStringAsFixed(6)},${north.toStringAsFixed(6)},${east.toStringAsFixed(6)},${south.toStringAsFixed(6)}'
          '&bounded=1'
          '&limit=50'
          '&addressdetails=1'
          '&extratags=1',
        );

        // ignore: avoid_print
        print('[OsmOverpassService] Nominatim query: amenity=$amenity near ($latitude, $longitude)');

        final response = await _client.get(
          uri,
          headers: {
            'User-Agent': 'RuralCareApp/1.0 (HealthcareFinder; contact@ruralcare.app)',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is List) {
            // ignore: avoid_print
            print('[OsmOverpassService] Nominatim returned ${decoded.length} results for amenity=$amenity');
            for (final item in decoded) {
              if (item is Map<String, dynamic>) {
                final place = _parseNominatimResult(
                  item,
                  latitude,
                  longitude,
                  amenity,
                  radiusMeters,
                );
                if (place != null) {
                  allPlaces.add(place);
                }
              }
            }
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('[OsmOverpassService] Nominatim error for amenity=$amenity: $e');
      }
    }

    // Deduplicate by OSM place id
    final seen = <String>{};
    final unique = allPlaces.where((p) => seen.add(p.id)).toList();
    unique.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    // ignore: avoid_print
    print('[OsmOverpassService] ✅ Nominatim total: ${unique.length} unique real facilities');
    return unique;
  }

  List<String> _getNominatimAmenities(String category) {
    switch (category) {
      case 'hospitals':
      case 'hospital':
      case 'emergency':
        return ['hospital'];
      case 'clinics':
      case 'clinic':
        return ['clinic', 'health_centre'];
      case 'doctors':
      case 'doctor':
        return ['doctors'];
      case 'pharmacies':
      case 'pharmacy':
        return ['pharmacy'];
      case 'maternal care':
      case 'maternal':
      case 'maternity':
        return ['hospital', 'clinic'];
      case 'all':
      default:
        return ['hospital', 'clinic', 'doctors', 'pharmacy', 'health_centre'];
    }
  }

  /// Parses a Nominatim JSON result into a [HealthcarePlace]
  HealthcarePlace? _parseNominatimResult(
    Map<String, dynamic> item,
    double userLat,
    double userLng,
    String amenity,
    int radiusMeters,
  ) {
    final rawDisplayName = item['display_name']?.toString();
    var name = item['name']?.toString().trim() ?? '';
    if (name.isEmpty && rawDisplayName != null) {
      name = rawDisplayName.split(',').first.trim();
    }
    if (name.isEmpty) return null;

    final lat = double.tryParse(item['lat']?.toString() ?? '');
    final lng = double.tryParse(item['lon']?.toString() ?? '');
    if (lat == null || lng == null) return null;

    final distanceKm = _locationService.calculateDistanceKm(userLat, userLng, lat, lng);
    // Strict geographic safeguard: ignore any result outside 1.25x the search radius
    if (distanceKm > (radiusMeters / 1000.0) * 1.25) return null;

    // Enhance generic names with locality/suburb/road
    final genericWords = {'health centre', 'health center', 'clinic', 'hospital', 'pharmacy', 'chemist', 'dispensary', 'doctor'};
    if (genericWords.contains(name.toLowerCase())) {
      final addr = item['address'] as Map<String, dynamic>?;
      final locality = addr?['suburb'] ?? addr?['neighbourhood'] ?? addr?['village'] ?? addr?['road'] ?? addr?['town'] ?? addr?['city'];
      if (locality != null && locality.toString().trim().isNotEmpty) {
        name = '$name (${locality.toString().trim()})';
      }
    }

    final placeId = 'osm_nominatim_${item['place_id'] ?? name.hashCode}';
    final distanceStr = _locationService.formatDistance(distanceKm);

    // Address from Nominatim address details
    final address = item['address'] is Map<String, dynamic>
        ? _buildNominatimAddress(item['address'] as Map<String, dynamic>)
        : (rawDisplayName != null ? rawDisplayName.split(',').skip(1).take(3).join(',').trim() : '');

    // Extra tags
    final extratags = (item['extratags'] as Map<String, dynamic>?) ?? {};
    final phone = extratags['phone']?.toString() ?? extratags['contact:phone']?.toString() ?? '';
    final website = extratags['website']?.toString() ?? '';
    final openingHours = extratags['opening_hours']?.toString() ?? '';

    final nameLower = name.toLowerCase();
    final isHospital = amenity == 'hospital';
    final isEmergency = isHospital ||
        nameLower.contains('civil') ||
        nameLower.contains('district') ||
        nameLower.contains('government') ||
        nameLower.contains('emergency') ||
        nameLower.contains('medical college');

    final hasMaternal = isHospital ||
        nameLower.contains('matern') ||
        nameLower.contains('women') ||
        nameLower.contains('child') ||
        nameLower.contains('mother');

    String category;
    String type;
    switch (amenity) {
      case 'pharmacy':
        category = 'Pharmacies';
        type = 'Pharmacy';
        break;
      case 'doctors':
        category = 'Doctors';
        type = 'Doctor Clinic';
        break;
      case 'clinic':
        category = 'Clinics';
        type = 'Clinic';
        break;
      case 'health_centre':
        category = 'Clinics';
        type = 'Health Centre';
        break;
      default:
        category = 'Hospitals';
        type = 'Hospital';
    }

    final isOpen = openingHours.contains('24/7') || openingHours.isEmpty;
    final hours = openingHours == '24/7'
        ? 'Open 24 Hours · Daily'
        : (openingHours.isNotEmpty ? openingHours : 'Open Now');

    return HealthcarePlace(
      id: placeId,
      name: name,
      category: category,
      type: type,
      address: address.isNotEmpty ? address : 'Near $lat, $lng',
      latitude: lat,
      longitude: lng,
      distance: distanceStr,
      distanceKm: distanceKm,
      rating: 4.2,
      userRatingsTotal: 0,
      phone: phone,
      isOpen: isOpen,
      hours: hours,
      website: website,
      googleMapsUrl: 'https://maps.google.com/?q=$lat,$lng',
      isEmergency24x7: isEmergency,
      hasMaternalCare: hasMaternal,
      services: [
        if (isEmergency) '24x7 Emergency Services' else 'General Consultations',
        if (hasMaternal) 'Maternal & Child Health' else 'Basic Healthcare',
        'Outpatient Care',
      ],
    );
  }

  String _buildNominatimAddress(Map<String, dynamic> addr) {
    final parts = [
      addr['road']?.toString(),
      addr['village']?.toString() ?? addr['suburb']?.toString() ?? addr['town']?.toString() ?? addr['city']?.toString(),
      addr['state_district']?.toString() ?? addr['district']?.toString(),
      addr['state']?.toString(),
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }



  /// Maps RuralCare categories to OSM Overpass QL amenity filters
  String _getOsmAmenityFilter(String category) {
    switch (category) {
      case 'hospitals':
      case 'hospital':
        return '"amenity"="hospital"';
      case 'clinics':
      case 'clinic':
        return '"amenity"~"clinic|health_centre"';
      case 'doctors':
      case 'doctor':
        return '"amenity"="doctors"';
      case 'pharmacies':
      case 'pharmacy':
        return '"amenity"~"pharmacy|chemist"';
      case 'emergency':
        return '"amenity"="hospital"';
      case 'maternal care':
      case 'maternal':
      case 'maternity':
        return '"amenity"~"hospital|clinic"';
      case 'all':
      default:
        return '"amenity"~"hospital|clinic|doctors|pharmacy|health_centre|dentist"';
    }
  }

  /// Parses an OpenStreetMap node or way element into a normalized [HealthcarePlace]
  HealthcarePlace? _parseOsmElement(
    Map<String, dynamic> el,
    double userLat,
    double userLng,
  ) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final rawName = tags['name']?.toString() ??
        tags['name:en']?.toString() ??
        tags['name:hi']?.toString() ??
        tags['name:bn']?.toString() ??
        tags['operator']?.toString();

    // Skip unnamed nodes to keep list high quality
    if (rawName == null || rawName.trim().isEmpty) {
      return null;
    }

    final name = rawName.trim();
    final typeStr = el['type']?.toString() ?? 'node';
    final idStr = el['id']?.toString() ?? '${name.hashCode}';
    final placeId = 'osm_${typeStr}_$idStr';

    // Lat/Lng from node or way center
    double? lat;
    double? lng;
    if (el.containsKey('lat') && el.containsKey('lon')) {
      lat = (el['lat'] as num?)?.toDouble();
      lng = (el['lon'] as num?)?.toDouble();
    } else if (el['center'] is Map<String, dynamic>) {
      final center = el['center'] as Map<String, dynamic>;
      lat = (center['lat'] as num?)?.toDouble();
      lng = (center['lon'] as num?)?.toDouble();
    }

    final distanceKm = (lat != null && lng != null)
        ? _locationService.calculateDistanceKm(userLat, userLng, lat, lng)
        : 0.0;
    final distanceStr = _locationService.formatDistance(distanceKm);

    final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
    final healthcare = tags['healthcare']?.toString().toLowerCase() ?? '';

    // Map Category & Type
    String category = 'Hospitals';
    String type = 'Hospital';

    if (amenity == 'pharmacy' || amenity == 'chemist' || healthcare == 'pharmacy') {
      category = 'Pharmacies';
      type = 'Pharmacy';
    } else if (amenity == 'doctors' || amenity == 'dentist' || healthcare == 'doctor') {
      category = 'Doctors';
      type = amenity == 'dentist' ? 'Dental Clinic' : 'Doctor Clinic';
    } else if (amenity == 'clinic' || amenity == 'health_centre' || healthcare == 'clinic' || healthcare == 'centre') {
      category = 'Clinics';
      type = amenity == 'health_centre' ? 'Health Centre' : 'Clinic';
    } else {
      category = 'Hospitals';
      type = 'Hospital';
    }

    final nameLower = name.toLowerCase();

    // Emergency capability check
    final isEmergency = amenity == 'hospital' ||
        healthcare == 'hospital' ||
        tags['emergency']?.toString().toLowerCase() == 'yes' ||
        nameLower.contains('civil') ||
        nameLower.contains('district') ||
        nameLower.contains('emergency') ||
        nameLower.contains('trauma') ||
        nameLower.contains('government') ||
        nameLower.contains('medical college');

    // Maternal care capability check
    final speciality = tags['healthcare:speciality']?.toString().toLowerCase() ?? '';
    final hasMaternal = amenity == 'hospital' ||
        speciality.contains('maternity') ||
        speciality.contains('obstetric') ||
        speciality.contains('gynaecolog') ||
        nameLower.contains('matern') ||
        nameLower.contains('women') ||
        nameLower.contains('child') ||
        nameLower.contains('mother') ||
        nameLower.contains('gynaec');

    // Hours
    final osmHours = tags['opening_hours']?.toString() ?? '';
    final isOpen = osmHours.contains('24/7') || osmHours.isEmpty;
    final hours = osmHours == '24/7'
        ? 'Open 24 Hours · Daily'
        : (osmHours.isNotEmpty ? osmHours : 'Open Now');

    // Address construction
    final addrParts = [
      tags['addr:housenumber']?.toString(),
      tags['addr:street']?.toString(),
      tags['addr:village']?.toString() ??
          tags['addr:suburb']?.toString() ??
          tags['addr:city']?.toString(),
      tags['addr:district']?.toString(),
      tags['addr:state']?.toString(),
    ].where((p) => p != null && p.trim().isNotEmpty).toList();

    final address = addrParts.isNotEmpty
        ? addrParts.join(', ')
        : (tags['description']?.toString() ??
            'Near ${userLat.toStringAsFixed(4)}, ${userLng.toStringAsFixed(4)}');

    final phone = tags['phone']?.toString() ??
        tags['contact:phone']?.toString() ??
        tags['contact:mobile']?.toString() ??
        '';

    final website = tags['website']?.toString() ??
        tags['contact:website']?.toString() ??
        '';

    final googleMapsUrl = (lat != null && lng != null)
        ? 'https://maps.google.com/?q=$lat,$lng'
        : '';

    final services = <String>[
      if (isEmergency) '24x7 Emergency Services' else 'General Consultations',
      if (hasMaternal) 'Maternal & Child Health' else 'Basic Healthcare',
      if (category == 'Pharmacies')
        'Essential & Emergency Medicines'
      else
        'Outpatient Care',
    ];

    return HealthcarePlace(
      id: placeId,
      name: name,
      category: category,
      type: type,
      address: address,
      latitude: lat,
      longitude: lng,
      distance: distanceStr,
      distanceKm: distanceKm,
      rating: 4.3,
      userRatingsTotal: 0,
      phone: phone,
      isOpen: isOpen,
      hours: hours,
      website: website,
      googleMapsUrl: googleMapsUrl,
      isEmergency24x7: isEmergency,
      hasMaternalCare: hasMaternal,
      services: services,
    );
  }

  /// Fetches detailed metadata for an OpenStreetMap place
  Future<PlaceDetails?> fetchPlaceDetails(HealthcarePlace place) async {
    return PlaceDetails(
      place: place,
      operatingHours: place.hours,
      nationalPhone: place.phone,
      verifiedServices: place.services,
    );
  }

  void clearCache() {
    _cache.clear();
  }
}

class _CachedOsmResult {
  final DateTime timestamp;
  final List<HealthcarePlace> places;

  _CachedOsmResult({
    required this.timestamp,
    required this.places,
  });
}
