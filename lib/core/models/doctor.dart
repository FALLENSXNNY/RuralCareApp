// Doctor model — represents a doctor available for consultation
class Doctor {
  final String id;
  final String name;
  final String speciality;
  final String qualification;
  final String facility;
  final String experience; // e.g. "8 years"
  final String availableSlots;
  final bool acceptsOnline;

  const Doctor({
    required this.id,
    required this.name,
    required this.speciality,
    required this.qualification,
    required this.facility,
    required this.experience,
    required this.availableSlots,
    required this.acceptsOnline,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      speciality: json['speciality'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      facility: json['facility'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      availableSlots: json['availableSlots'] as String? ?? '',
      acceptsOnline: json['acceptsOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speciality': speciality,
      'qualification': qualification,
      'facility': facility,
      'experience': experience,
      'availableSlots': availableSlots,
      'acceptsOnline': acceptsOnline,
    };
  }
}
