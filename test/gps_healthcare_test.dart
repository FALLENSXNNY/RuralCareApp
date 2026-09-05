import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/models/facility.dart';
import 'package:ruralcare/core/repositories/healthcare_repository.dart';
import 'package:ruralcare/core/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    final locationService = LocationService();

    test('Haversine distance calculation is mathematically accurate', () {
      // Satara District Coordinates: 17.6805° N, 74.0183° E
      // Wai CHC Coordinates: 17.9482° N, 73.8924° E
      final distanceKm = locationService.calculateDistanceKm(
        17.6805,
        74.0183,
        17.9482,
        73.8924,
      );

      expect(distanceKm, greaterThan(30.0));
      expect(distanceKm, lessThan(35.0));
    });

    test('Distance formatting formats meters and kilometers accurately', () {
      expect(locationService.formatDistance(0.450), '450 m');
      expect(locationService.formatDistance(0.850), '850 m');
      expect(locationService.formatDistance(1.234), '1.2 km');
      expect(locationService.formatDistance(12.0), '12.0 km');
    });

    test('UserLocation fallback and JSON serialization work', () {
      final loc = UserLocation.fallbackRuralSatara;
      final json = loc.toJson();
      final fromJson = UserLocation.fromJson(json);

      expect(fromJson.latitude, 17.6805);
      expect(fromJson.longitude, 74.0183);
      expect(fromJson.placename, contains('Satara'));
    });
  });

  group('HealthcareFacility Model Tests', () {
    test('Facility models hold coordinate and emergency capability metadata', () {
      const facility = HealthcareFacility(
        id: 'FAC-TEST',
        name: 'District Trauma Centre',
        type: 'Hospital',
        address: 'Civil Lines, Satara',
        distance: '1.2 km',
        phone: '02162-999999',
        hours: 'Open 24 hours',
        isOpen: true,
        services: ['Emergency', 'Maternity', 'ICU'],
        latitude: 17.6800,
        longitude: 74.0100,
        isEmergency24x7: true,
        hasMaternalCare: true,
      );

      expect(facility.isEmergency24x7, isTrue);
      expect(facility.hasMaternalCare, isTrue);
      expect(facility.latitude, 17.6800);

      final json = facility.toJson();
      final parsed = HealthcareFacility.fromJson(json);
      expect(parsed.isEmergency24x7, isTrue);
      expect(parsed.hasMaternalCare, isTrue);
      expect(parsed.latitude, 17.6800);
      expect(parsed.longitude, 74.0100);
    });
  });

  group('HealthcareRepository Tests', () {
    late HealthcareRepository repository;

    setUp(() {
      repository = HealthcareRepository();
    });

    test('Calculates live distances from user position', () async {
      final userLoc = UserLocation(
        latitude: 17.6970,
        longitude: 74.1720,
        placename: 'Near Koregaon',
        timestamp: DateTime.now(),
      );

      final facilities = await repository.getFacilities(
        userLocation: userLoc,
        category: 'All',
      );

      expect(facilities.isNotEmpty, isTrue);
      final koregaon = facilities.firstWhere((f) => f.id == 'FAC-001');
      // Should be very close (under 1 km)
      expect(koregaon.distance, contains('m'));
    });

    test('Filters facilities by Hospitals category', () async {
      final hospitals = await repository.getFacilities(category: 'Hospitals');
      expect(hospitals.every((f) => f.type.toLowerCase().contains('hospital') || f.name.toLowerCase().contains('hospital')), isTrue);
    });

    test('Filters facilities by Maternal Care category', () async {
      final maternal = await repository.getFacilities(category: 'Maternal Care');
      expect(maternal.every((f) => f.hasMaternalCare || f.services.any((s) => s.toLowerCase().contains('matern') || s.toLowerCase().contains('gyn') || s.toLowerCase().contains('delivery'))), isTrue);
      expect(maternal.any((f) => f.name.contains('Maa Yashoda')), isTrue);
    });

    test('Filters facilities by 24x7 Emergency category', () async {
      final emergency = await repository.getFacilities(category: '24x7 Emergency');
      expect(emergency.every((f) => f.isEmergency24x7 || f.services.contains('Emergency') || f.hours.contains('24')), isTrue);
    });

    test('Search query matches facility name, services, and location', () async {
      final queryResults = await repository.getFacilities(searchQuery: 'NICU');
      expect(queryResults.isNotEmpty, isTrue);
      expect(queryResults.first.name, contains('Maa Yashoda'));
    });

    test('Emergency Mode prioritizes emergency hospitals at the top', () async {
      final emergencyTriage = await repository.getFacilities(
        isEmergencyMode: true,
      );

      expect(emergencyTriage.isNotEmpty, isTrue);
      // Top items must have 24x7 emergency capability
      expect(emergencyTriage.first.isEmergency24x7, isTrue);
    });

    test('Doctor search and filters work', () async {
      final gynaecologists = await repository.getDoctors(
        speciality: 'Gynaecologist',
      );
      expect(gynaecologists.isNotEmpty, isTrue);
      expect(gynaecologists.every((d) => d.speciality.contains('Gynaecologist')), isTrue);

      final onlineDocs = await repository.getDoctors(onlyOnline: true);
      expect(onlineDocs.every((d) => d.acceptsOnline), isTrue);
    });
  });

  group('Multilingual Parity for GPS & Triage Tests', () {
    test('All GPS and healthcare triage terms exist in en, hi, and bn', () {
      final locales = ['en', 'hi', 'bn'];
      final requiredKeys = [
        'findHealthcare',
        'findCareSubtitle',
        'findADoctor',
        'findDoctorSubtitle',
        'searchFacilitiesHint',
        'searchDoctorsHint',
        'filterAll',
        'hospitals',
        'clinics',
        'doctors',
        'maternalCare',
        'emergency24x7',
        'emergencyTriageBanner',
        'call108Ambulance',
        'priorityTriage',
        'detectedLocation',
        'refreshLocation',
        'locationPermissionDenied',
        'openSettings',
        'grantPermission',
        'gpsDisabled',
        'enableGps',
        'noFacilitiesFound',
        'callFacility',
      ];

      for (final lang in locales) {
        final l10n = AppLocalizations(Locale(lang));
        for (final key in requiredKeys) {
          final translated = l10n.translate(key);
          expect(
            translated,
            isNot(equals(key)),
            reason: 'Missing translation for key "$key" in language "$lang"',
          );
          expect(translated.isNotEmpty, isTrue);
        }
      }
    });
  });
}
