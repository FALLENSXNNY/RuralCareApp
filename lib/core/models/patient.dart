// Patient model — represents the authenticated patient's profile
class Patient {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String gender;
  final String village;
  final String district;
  final String state;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> conditions;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.village,
    required this.district,
    required this.state,
    required this.bloodGroup,
    required this.allergies,
    required this.conditions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'village': village,
      'district': district,
      'state': state,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? phone,
    int? age,
    String? gender,
    String? village,
    String? district,
    String? state,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? conditions,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
    );
  }
}
