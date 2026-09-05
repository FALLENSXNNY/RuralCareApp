import '../mock/mock_patient_data.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../services/location_service.dart';

/// Repository for discovering healthcare facilities and doctors with location intelligence
class HealthcareRepository {
  final LocationService _locationService;

  HealthcareRepository({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  /// Retrieve facilities sorted by distance and emergency capability
  Future<List<HealthcareFacility>> getFacilities({
    UserLocation? userLocation,
    String category = 'All',
    String searchQuery = '',
    bool isEmergencyMode = false,
  }) async {
    // Start with verified facilities
    List<HealthcareFacility> list = List.from(MockPatientData.facilities);

    // If user location is provided, dynamically compute distances
    if (userLocation != null) {
      list = list.map((facility) {
        if (facility.latitude != null && facility.longitude != null) {
          final distanceKm = _locationService.calculateDistanceKm(
            userLocation.latitude,
            userLocation.longitude,
            facility.latitude!,
            facility.longitude!,
          );
          return facility.copyWith(
            distance: _locationService.formatDistance(distanceKm),
          );
        }
        return facility;
      }).toList();
    }

    // Apply category filter
    if (category != 'All') {
      final cat = category.toLowerCase().trim();
      list = list.where((f) {
        if (cat == 'hospital' || cat == 'hospitals') {
          return f.type.toLowerCase().contains('hospital') ||
              f.name.toLowerCase().contains('hospital');
        }
        if (cat == 'clinic' || cat == 'clinics') {
          return f.type.toLowerCase().contains('clinic') ||
              f.type.toLowerCase().contains('phc');
        }
        if (cat == 'maternal' || cat == 'maternal care' || cat == 'maternity') {
          return f.hasMaternalCare ||
              f.services.any((s) =>
                  s.toLowerCase().contains('matern') ||
                  s.toLowerCase().contains('gyn') ||
                  s.toLowerCase().contains('delivery') ||
                  s.toLowerCase().contains('obstet'));
        }
        if (cat == 'emergency' || cat == '24x7 emergency' || cat == 'emergency 24x7') {
          return f.isEmergency24x7 ||
              f.services.any((s) => s.toLowerCase().contains('emergency')) ||
              f.hours.toLowerCase().contains('24');
        }
        return f.type.toLowerCase().contains(cat) ||
            f.name.toLowerCase().contains(cat);
      }).toList();
    }

    // Apply text search query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((f) {
        return f.name.toLowerCase().contains(q) ||
            f.address.toLowerCase().contains(q) ||
            f.type.toLowerCase().contains(q) ||
            f.services.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    // Sort order: In emergency mode, prioritize 24x7 emergency facilities and hospitals first
    if (isEmergencyMode) {
      list.sort((a, b) {
        final aScore = (a.isEmergency24x7 ? 10 : 0) +
            (a.type.toLowerCase().contains('hospital') ? 5 : 0) +
            (a.isOpen ? 2 : 0);
        final bScore = (b.isEmergency24x7 ? 10 : 0) +
            (b.type.toLowerCase().contains('hospital') ? 5 : 0) +
            (b.isOpen ? 2 : 0);
        return bScore.compareTo(aScore);
      });
    }

    return list;
  }

  /// Retrieve doctors with search and filter capabilities
  Future<List<Doctor>> getDoctors({
    String speciality = 'All',
    String searchQuery = '',
    bool onlyOnline = false,
  }) async {
    List<Doctor> list = List.from(MockPatientData.doctors);

    if (speciality != 'All') {
      final spec = speciality.toLowerCase().trim();
      list = list.where((d) => d.speciality.toLowerCase().contains(spec)).toList();
    }

    if (onlyOnline) {
      list = list.where((d) => d.acceptsOnline).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((d) {
        return d.name.toLowerCase().contains(q) ||
            d.speciality.toLowerCase().contains(q) ||
            d.facility.toLowerCase().contains(q) ||
            d.qualification.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }
}
