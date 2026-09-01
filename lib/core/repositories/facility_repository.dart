// Facility repository — abstraction for healthcare facility data
import '../models/doctor.dart';
import '../models/facility.dart';

abstract class FacilityRepository {
  /// Returns all healthcare facilities.
  Future<List<HealthcareFacility>> getFacilities();

  /// Searches facilities by name, type, or service.
  Future<List<HealthcareFacility>> searchFacilities(String query);

  /// Filters facilities by type.
  Future<List<HealthcareFacility>> getFacilitiesByType(String type);

  /// Returns all available doctors.
  Future<List<Doctor>> getDoctors();

  /// Returns a single doctor by ID.
  Future<Doctor> getDoctor(String id);
}
