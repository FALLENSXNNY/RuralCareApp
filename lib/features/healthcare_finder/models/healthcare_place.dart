/// Model representing a healthcare place returned by the backend Healthcare Finder
class HealthcarePlace {
  final String id;
  final String name;
  final String category; // Hospitals, Clinics, Doctors, Pharmacies, Emergency, Maternal Care
  final String type; // District Hospital, PHC, CHC, Clinic, Pharmacy
  final String address;
  final double? latitude;
  final double? longitude;
  final String distance; // e.g. "1.8 km"
  final double distanceKm;
  final double rating;
  final int userRatingsTotal;
  final String phone;
  final bool isOpen;
  final String hours;
  final String website;
  final String googleMapsUrl;
  final bool isEmergency24x7;
  final bool hasMaternalCare;
  final List<String> services;

  const HealthcarePlace({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.address,
    this.latitude,
    this.longitude,
    this.distance = 'Nearby',
    this.distanceKm = 0.0,
    this.rating = 4.2,
    this.userRatingsTotal = 0,
    this.phone = '',
    this.isOpen = true,
    this.hours = 'Open 24 Hours · Daily',
    this.website = '',
    this.googleMapsUrl = '',
    this.isEmergency24x7 = false,
    this.hasMaternalCare = false,
    this.services = const [],
  });

  factory HealthcarePlace.fromJson(Map<String, dynamic> json) {
    return HealthcarePlace(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Hospitals',
      type: json['type'] as String? ?? 'Healthcare Facility',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: json['distance'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.2,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? true,
      hours: json['hours'] as String? ?? 'Open Now',
      website: json['website'] as String? ?? '',
      googleMapsUrl: json['googleMapsUrl'] as String? ?? '',
      isEmergency24x7: json['isEmergency24x7'] as bool? ?? false,
      hasMaternalCare: json['hasMaternalCare'] as bool? ?? false,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'distanceKm': distanceKm,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'phone': phone,
      'isOpen': isOpen,
      'hours': hours,
      'website': website,
      'googleMapsUrl': googleMapsUrl,
      'isEmergency24x7': isEmergency24x7,
      'hasMaternalCare': hasMaternalCare,
      'services': services,
    };
  }

  HealthcarePlace copyWith({
    String? id,
    String? name,
    String? category,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    String? distance,
    double? distanceKm,
    double? rating,
    int? userRatingsTotal,
    String? phone,
    bool? isOpen,
    String? hours,
    String? website,
    String? googleMapsUrl,
    bool? isEmergency24x7,
    bool? hasMaternalCare,
    List<String>? services,
  }) {
    return HealthcarePlace(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      hours: hours ?? this.hours,
      website: website ?? this.website,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      isEmergency24x7: isEmergency24x7 ?? this.isEmergency24x7,
      hasMaternalCare: hasMaternalCare ?? this.hasMaternalCare,
      services: services ?? this.services,
    );
  }

  /// Returns true if this facility/provider supports appointment booking (Doctors and Hospitals only)
  bool get supportsAppointmentBooking {
    final cat = category.toLowerCase().trim();
    final typ = type.toLowerCase().trim();
    final nm = name.toLowerCase().trim();

    // Explicitly exclude pharmacies, medical stores, diagnostic centers/labs
    if (cat.contains('pharmacy') ||
        typ.contains('pharmacy') ||
        nm.contains('pharmacy') ||
        nm.contains('chemist') ||
        nm.contains('medical store') ||
        typ.contains('chemist') ||
        cat.contains('lab') ||
        typ.contains('lab')) {
      return false;
    }

    // Only allow Doctors and Hospitals
    final isDoctor = cat == 'doctors' ||
        cat == 'doctor' ||
        typ.contains('doctor') ||
        typ.contains('psychiatrist') ||
        typ.contains('pediatrician') ||
        typ.contains('gynecologist') ||
        typ.contains('physician') ||
        typ.contains('surgeon') ||
        typ.contains('cardiologist') ||
        typ.contains('dermatologist') ||
        typ.contains('orthopedic') ||
        nm.startsWith('dr.') ||
        nm.startsWith('dr ');

    final isHospital = cat == 'hospitals' ||
        cat == 'hospital' ||
        typ.contains('hospital') ||
        typ.contains('phc') ||
        typ.contains('chc') ||
        typ.contains('district hospital') ||
        typ.contains('sub-district hospital') ||
        typ.contains('civil hospital') ||
        nm.contains('hospital');

    return isDoctor || isHospital;
  }
}
