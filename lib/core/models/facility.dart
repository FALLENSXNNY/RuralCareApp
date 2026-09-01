// Healthcare facility model — represents a healthcare facility
class HealthcareFacility {
  final String id;
  final String name;
  final String type; // PHC / CHC / District Hospital / Clinic
  final String address;
  final String distance; // e.g. "2.3 km"
  final String phone;
  final String hours;
  final bool isOpen;
  final List<String> services;

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
  });

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
    };
  }
}
