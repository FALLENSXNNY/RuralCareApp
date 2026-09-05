import 'healthcare_place.dart';

/// Detailed information about a specific healthcare facility
class PlaceDetails {
  final HealthcarePlace place;
  final String operatingHours;
  final String website;
  final String nationalPhone;
  final bool isVerified;
  final List<String> verifiedServices;
  final String overview;

  const PlaceDetails({
    required this.place,
    required this.operatingHours,
    this.website = '',
    required this.nationalPhone,
    this.isVerified = true,
    required this.verifiedServices,
    this.overview = '',
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final place = HealthcarePlace.fromJson(json);
    return PlaceDetails(
      place: place,
      operatingHours: json['hours'] as String? ?? 'Open 24 Hours · Daily',
      website: json['website'] as String? ?? '',
      nationalPhone: json['phone'] as String? ?? '',
      isVerified: true,
      verifiedServices: place.services.isNotEmpty
          ? place.services
          : const [
              'Emergency Trauma Unit',
              'Maternal Delivery Ward',
              'General Outpatient Care',
              'Pharmacy & Medical Supplies',
            ],
      overview: json['overview'] as String? ?? '',
    );
  }
}
