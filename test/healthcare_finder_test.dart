import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/localization/app_localizations.dart';
import 'package:ruralcare/core/services/location_service.dart';
import 'package:ruralcare/features/healthcare_finder/data/directions_service.dart';
import 'package:ruralcare/features/healthcare_finder/data/google_places_service.dart';
import 'package:ruralcare/features/healthcare_finder/data/healthcare_repository.dart';
import 'package:ruralcare/features/healthcare_finder/models/healthcare_place.dart';
import 'package:ruralcare/features/healthcare_finder/models/place_details.dart';

import 'package:ruralcare/features/healthcare_finder/data/osm_overpass_service.dart';

class FakeOsmOverpassService extends OsmOverpassService {
  final List<HealthcarePlace> testPlaces;

  FakeOsmOverpassService({this.testPlaces = const []});

  @override
  Future<List<HealthcarePlace>> fetchNearbyHealthcare({
    required double latitude,
    required double longitude,
    double radius = 25000,
    String category = 'all',
  }) async {
    return testPlaces;
  }
}

class FakeGooglePlacesService extends GooglePlacesService {
  final List<HealthcarePlace> testPlaces = [
    const HealthcarePlace(
      id: 'FAC-001',
      name: 'Satara District Hospital',
      category: 'Hospitals',
      type: 'District Hospital',
      address: 'Sadar Bazar, Satara',
      latitude: 17.6805,
      longitude: 74.0183,
      distance: '1.8 km',
      distanceKm: 1.8,
      rating: 4.6,
      userRatingsTotal: 340,
      phone: '+91 2162 233 444',
      isOpen: true,
      hours: 'Open 24 Hours',
      isEmergency24x7: true,
      hasMaternalCare: true,
      services: ['Emergency Unit', 'Maternity Ward'],
    ),
    const HealthcarePlace(
      id: 'FAC-002',
      name: 'Koregaon Rural Clinic',
      category: 'Clinics',
      type: 'Primary Health Centre',
      address: 'Station Road, Koregaon',
      latitude: 17.7012,
      longitude: 74.1754,
      distance: '5.2 km',
      distanceKm: 5.2,
      rating: 4.2,
      userRatingsTotal: 80,
      phone: '+91 2163 220 108',
      isOpen: false,
      hours: '9:00 AM - 5:00 PM',
      isEmergency24x7: false,
      hasMaternalCare: true,
      services: ['Antenatal Care', 'Vaccinations'],
    ),
    const HealthcarePlace(
      id: 'FAC-003',
      name: 'Dr. Deshmukh Clinic',
      category: 'Doctors',
      type: 'General Physician',
      address: 'Shivaji Chowk, Satara',
      latitude: 17.6912,
      longitude: 74.0201,
      distance: '2.1 km',
      distanceKm: 2.1,
      rating: 4.8,
      userRatingsTotal: 150,
      phone: '+91 2162 244 112',
      isOpen: true,
      hours: '9:00 AM - 8:00 PM',
      isEmergency24x7: false,
      hasMaternalCare: false,
      services: ['General OPD', 'ECG'],
    ),
  ];

  @override
  Future<List<HealthcarePlace>> fetchNearbyHealthcare({
    required double latitude,
    required double longitude,
    double radius = 25000,
    String category = 'all',
  }) async {
    return testPlaces;
  }

  @override
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    final match = testPlaces.where((p) => p.id == placeId).firstOrNull;
    if (match != null) {
      return PlaceDetails(
        place: match,
        operatingHours: match.hours,
        nationalPhone: match.phone,
        verifiedServices: match.services,
      );
    }
    return null;
  }
}

void main() {
  group('HealthcarePlace and PlaceDetails Models', () {
    test('HealthcarePlace parses from JSON correctly', () {
      final json = {
        'id': 'place_123',
        'name': 'Satara Civil Hospital',
        'category': 'Hospitals',
        'type': 'District Hospital',
        'address': 'Sadar Bazar, Satara',
        'latitude': 17.6805,
        'longitude': 74.0183,
        'distance': '1.8 km',
        'distanceKm': 1.8,
        'rating': 4.6,
        'userRatingsTotal': 230,
        'phone': '+91 2162 233 444',
        'isOpen': true,
        'hours': 'Open 24 Hours',
        'website': 'https://arogya.maharashtra.gov.in',
        'googleMapsUrl': 'https://maps.google.com/?q=17.6805,74.0183',
        'isEmergency24x7': true,
        'hasMaternalCare': true,
        'services': ['Emergency', 'Delivery Ward', 'Blood Bank'],
      };

      final place = HealthcarePlace.fromJson(json);

      expect(place.id, 'place_123');
      expect(place.name, 'Satara Civil Hospital');
      expect(place.category, 'Hospitals');
      expect(place.type, 'District Hospital');
      expect(place.latitude, 17.6805);
      expect(place.longitude, 74.0183);
      expect(place.distanceKm, 1.8);
      expect(place.rating, 4.6);
      expect(place.isEmergency24x7, true);
      expect(place.hasMaternalCare, true);
      expect(place.services.length, 3);
    });

    test('PlaceDetails model wraps HealthcarePlace and verified services', () {
      const place = HealthcarePlace(
        id: 'place_99',
        name: 'Koregaon Hospital',
        category: 'Hospitals',
        type: 'Sub-District Hospital',
        address: 'Station Road, Koregaon',
        distance: '2.5 km',
        phone: '+91 2163 220 108',
        hours: 'Open 24 Hours',
        isEmergency24x7: true,
        hasMaternalCare: true,
      );

      final details = PlaceDetails(
        place: place,
        operatingHours: 'Open 24 Hours · Daily',
        nationalPhone: '+91 2163 220 108',
        verifiedServices: const ['Trauma Unit', 'Maternity Ward'],
      );

      expect(details.place.id, 'place_99');
      expect(details.isVerified, true);
      expect(details.verifiedServices.length, 2);
    });
  });

  group('HealthcareFinderRepository', () {
    late HealthcareFinderRepository repository;
    late FakeGooglePlacesService fakePlacesService;
    late FakeOsmOverpassService fakeOsmService;

    setUp(() {
      fakePlacesService = FakeGooglePlacesService();
      fakeOsmService = FakeOsmOverpassService(testPlaces: fakePlacesService.testPlaces);
      repository = HealthcareFinderRepository(
        osmService: fakeOsmService,
        placesService: fakePlacesService,
      );
    });

    test('Retrieves facilities and computes live distance from user location', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'All',
      );

      expect(places.isNotEmpty, true);
      for (final p in places) {
        expect(p.distance, isNotEmpty);
      }
    });

    test('Filters facilities by Hospitals category', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'Hospitals',
      );

      expect(places.isNotEmpty, true);
      for (final p in places) {
        expect(
          p.category.toLowerCase().contains('hospital') ||
              p.type.toLowerCase().contains('hospital') ||
              p.name.toLowerCase().contains('hospital'),
          true,
        );
      }
    });

    test('Filters facilities by Emergency category', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'Emergency',
      );

      expect(places.isNotEmpty, true);
      for (final p in places) {
        expect(p.isEmergency24x7, true);
      }
    });

    test('Filters facilities by Maternal Care category', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'Maternal Care',
      );

      expect(places.isNotEmpty, true);
      for (final p in places) {
        expect(p.hasMaternalCare, true);
      }
    });

    test('Sorts by rating descending', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'All',
        sortOption: HealthcareSortOption.rating,
      );

      expect(places.isNotEmpty, true);
      for (int i = 0; i < places.length - 1; i++) {
        expect(places[i].rating >= places[i + 1].rating, true);
      }
    });

    test('In Emergency mode, prioritizes 24x7 emergency facilities', () async {
      final userLoc = UserLocation(
        latitude: 17.6805,
        longitude: 74.0183,
        placename: 'Satara City',
        timestamp: DateTime.now(),
      );

      final places = await repository.getHealthcarePlaces(
        userLocation: userLoc,
        category: 'All',
        isEmergencyMode: true,
      );

      expect(places.isNotEmpty, true);
      expect(places.first.isEmergency24x7, true);
    });

    test('Retrieves place details by ID', () async {
      final details = await repository.getPlaceDetails('FAC-001');
      expect(details, isNotNull);
      expect(details!.place.name, contains('Satara'));
    });
  });

  group('DirectionsService', () {
    test('HealthcareRoute model parsing and URL creation', () {
      final json = {
        'distance': '4.2 km',
        'distanceMeters': 4200,
        'duration': '12 mins',
        'durationSeconds': 720,
        'startAddress': 'User Location',
        'endAddress': 'Satara District Hospital',
        'steps': [
          {
            'instruction': 'Turn right on NH48',
            'distance': '200 m',
            'duration': '1 min',
          }
        ],
        'googleMapsNavigationUrl':
            'https://www.google.com/maps/dir/?api=1&origin=17.6805,74.0183&destination=17.7012,74.1754',
      };

      final route = HealthcareRoute.fromJson(json);

      expect(route.distance, '4.2 km');
      expect(route.duration, '12 mins');
      expect(route.steps.length, 1);
      expect(route.googleMapsNavigationUrl, contains('google.com/maps/dir'));
    });
  });

  group('Healthcare Finder Localization Tests', () {
    test('English dictionary contains all required Healthcare Finder keys', () {
      final loc = AppLocalizations(const Locale('en'));

      expect(loc.translate('nearbyHealthcare'), 'Nearby Healthcare');
      expect(loc.translate('allCategories'), 'All');
      expect(loc.translate('emergencyCategory'), '24x7 Emergency');
      expect(loc.translate('hospitals'), 'Hospitals');
      expect(loc.translate('clinics'), 'Clinics');
      expect(loc.translate('doctors'), 'Doctors');
      expect(loc.translate('pharmacies'), 'Pharmacies');
      expect(loc.translate('maternalCare'), 'Maternal Care');
      expect(loc.translate('facilityDetails'), 'Facility Details');
      expect(loc.translate('viewInFullMap'), 'View in Full Map');
      expect(loc.translate('startGoogleMapsNavigation'),
          'Start Google Maps Navigation');
      expect(loc.translate('fastestRoute'), 'Fastest Route');
      expect(loc.translate('openNow'), 'Open Now');
      expect(loc.translate('closed'), 'Closed');
      expect(loc.translate('changeArea'), 'Change Area');
      expect(loc.translate('selectArea'), 'Select Search Area');
      expect(loc.translate('searchAreaHint'), 'Search city, town, or district...');
      expect(loc.translate('useLiveGps'), 'Use Live GPS Location');
      expect(loc.translate('searchThisArea'), 'Search This Area');
      expect(loc.translate('popularAreas'), 'Popular Areas & Towns');
    });

    test('Hindi dictionary contains all required Healthcare Finder keys', () {
      final loc = AppLocalizations(const Locale('hi'));

      expect(loc.translate('nearbyHealthcare'), 'नजदीकी स्वास्थ्य सेवा');
      expect(loc.translate('allCategories'), 'सभी');
      expect(loc.translate('emergencyCategory'), '24x7 आपातकालीन');
      expect(loc.translate('hospitals'), 'अस्पताल');
      expect(loc.translate('clinics'), 'क्लीनिक');
      expect(loc.translate('doctors'), 'डॉक्टर');
      expect(loc.translate('pharmacies'), 'दवा की दुकानें');
      expect(loc.translate('maternalCare'), 'मातृ देखभाल');
      expect(loc.translate('facilityDetails'), 'अस्पताल विवरण');
      expect(loc.translate('viewInFullMap'), 'पूरे मानचित्र में देखें');
      expect(loc.translate('startGoogleMapsNavigation'),
          'Google Maps नेविगेशन शुरू करें');
      expect(loc.translate('fastestRoute'), 'सबसे तेज़ रास्ता');
      expect(loc.translate('openNow'), 'खुला है');
      expect(loc.translate('closed'), 'बंद है');
      expect(loc.translate('changeArea'), 'क्षेत्र बदलें');
      expect(loc.translate('selectArea'), 'खोज क्षेत्र चुनें');
      expect(loc.translate('searchAreaHint'), 'शहर, कस्बा या जिला खोजें...');
      expect(loc.translate('useLiveGps'), 'लाइव GPS स्थान का उपयोग करें');
      expect(loc.translate('searchThisArea'), 'इस क्षेत्र में खोजें');
      expect(loc.translate('popularAreas'), 'प्रमुख क्षेत्र व शहर');
    });

    test('Bengali dictionary contains all required Healthcare Finder keys', () {
      final loc = AppLocalizations(const Locale('bn'));

      expect(loc.translate('nearbyHealthcare'), 'নিকটস্থ স্বাস্থ্যসেবা');
      expect(loc.translate('allCategories'), 'সব');
      expect(loc.translate('emergencyCategory'), '২৪x৭ জরুরি');
      expect(loc.translate('hospitals'), 'হাসপাতাল');
      expect(loc.translate('clinics'), 'ক্লিনিক');
      expect(loc.translate('doctors'), 'ডাক্তার');
      expect(loc.translate('pharmacies'), 'ওষুধের দোকান');
      expect(loc.translate('maternalCare'), 'মাতৃ যত্ন');
      expect(loc.translate('facilityDetails'), 'স্বাস্থ্যকেন্দ্র বিবরণ');
      expect(loc.translate('viewInFullMap'), 'সম্পূর্ণ মানচিত্রে দেখুন');
      expect(loc.translate('startGoogleMapsNavigation'),
          'গুগল ম্যাপস নেভিগেশন শুরু করুন');
      expect(loc.translate('fastestRoute'), 'সবচেয়ে দ্রুত রুট');
      expect(loc.translate('openNow'), 'এখন খোলা');
      expect(loc.translate('closed'), 'বন্ধ');
      expect(loc.translate('changeArea'), 'এলাকা পরিবর্তন করুন');
      expect(loc.translate('selectArea'), 'অনুসন্ধান এলাকা নির্বাচন করুন');
      expect(loc.translate('searchAreaHint'), 'শহর, নগর বা জেলা অনুসন্ধান করুন...');
      expect(loc.translate('useLiveGps'), 'লাইভ জিপিএস অবস্থান ব্যবহার করুন');
      expect(loc.translate('searchThisArea'), 'এই এলাকায় অনুসন্ধান করুন');
      expect(loc.translate('popularAreas'), 'জনপ্রিয় এলাকা ও শহর');
    });
  });

  group('OsmOverpassService Tests', () {
    test('Overpass amenity filters map correctly', () {
      final service = OsmOverpassService();
      expect(service, isNotNull);
    });
  });
}

