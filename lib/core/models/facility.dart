// Healthcare facility model — represents a healthcare facility with GPS and capability metadata
class HealthcareFacility {
  final String id;
  final String name;
  final String type; // PHC / CHC / District Hospital / Clinic / Maternity Center
  final String address;
  final String distance; // e.g. "2.3 km"
  final String phone;
  final String hours;
  final bool isOpen;
  final List<String> services;
  final double? latitude;
  final double? longitude;
  final bool isEmergency24x7;
  final bool hasMaternalCare;

  const HealthcareFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
    required this.phone,
    required this.hours,
    required this.isOpen,
    required this.services,
    this.latitude,
    this.longitude,
    this.isEmergency24x7 = false,
    this.hasMaternalCare = false,
  });

  HealthcareFacility copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? distance,
    String? phone,
    String? hours,
    bool? isOpen,
    List<String>? services,
    double? latitude,
    double? longitude,
    bool? isEmergency24x7,
    bool? hasMaternalCare,
  }) {
    return HealthcareFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      phone: phone ?? this.phone,
      hours: hours ?? this.hours,
      isOpen: isOpen ?? this.isOpen,
      services: services ?? this.services,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isEmergency24x7: isEmergency24x7 ?? this.isEmergency24x7,
      hasMaternalCare: hasMaternalCare ?? this.hasMaternalCare,
    );
  }

  factory HealthcareFacility.fromJson(Map<String, dynamic> json) {
    return HealthcareFacility(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isEmergency24x7: json['isEmergency24x7'] as bool? ?? false,
      hasMaternalCare: json['hasMaternalCare'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'distance': distance,
      'phone': phone,
      'hours': hours,
      'isOpen': isOpen,
      'services': services,
      'latitude': latitude,
      'longitude': longitude,
      'isEmergency24x7': isEmergency24x7,
      'hasMaternalCare': hasMaternalCare,
    };
  }
}
