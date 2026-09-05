// Patient model — represents the authenticated patient's profile
class Patient {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String gender;
  final bool isPregnant;
  final int? gestationalWeek;
  final String? edd;
  final String village;
  final String district;
  final String state;
  final String bloodGroup;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String abhaId;
  final String preferredLanguage;
  final List<String> allergies;
  final List<String> conditions;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    this.isPregnant = false,
    this.gestationalWeek,
    this.edd,
    required this.village,
    required this.district,
    required this.state,
    required this.bloodGroup,
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.abhaId = '',
    this.preferredLanguage = 'en',
    required this.allergies,
    required this.conditions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? 'Female',
      isPregnant: (json['isPregnant'] ?? json['is_pregnant']) as bool? ?? false,
      gestationalWeek:
          ((json['gestationalWeek'] ?? json['gestational_week']) as num?)
              ?.toInt(),
      edd: (json['edd'] ?? json['estimated_due_date']) as String?,
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? 'Maharashtra',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      emergencyContactName:
          (json['emergencyContactName'] ?? json['emergency_contact_name'])
                  as String? ??
              '',
      emergencyContactPhone:
          (json['emergencyContactPhone'] ?? json['emergency_contact_phone'])
                  as String? ??
              '',
      abhaId: (json['abhaId'] ?? json['abha_id']) as String? ?? '',
      preferredLanguage:
          (json['preferredLanguage'] ?? json['preferred_language'])
                  as String? ??
              'en',
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
      'isPregnant': isPregnant,
      'gestationalWeek': gestationalWeek,
      'edd': edd,
      'village': village,
      'district': district,
      'state': state,
      'bloodGroup': bloodGroup,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'abhaId': abhaId,
      'preferredLanguage': preferredLanguage,
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
    bool? isPregnant,
    int? gestationalWeek,
    String? edd,
    String? village,
    String? district,
    String? state,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? abhaId,
    String? preferredLanguage,
    List<String>? allergies,
    List<String>? conditions,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      isPregnant: isPregnant ?? this.isPregnant,
      gestationalWeek: gestationalWeek ?? this.gestationalWeek,
      edd: edd ?? this.edd,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      abhaId: abhaId ?? this.abhaId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
    );
  }
}
