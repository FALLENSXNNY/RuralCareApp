// Consultation model — represents a healthcare consultation
class Consultation {
  final String id;
  final String doctorName;
  final String doctorSpeciality;
  final String facility;
  final String date;
  final String type; // In-person / Teleconsultation
  final List<String> complaints;
  final String diagnosis;
  final String plan;

  const Consultation({
    required this.id,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.facility,
    required this.date,
    required this.type,
    required this.complaints,
    required this.diagnosis,
    required this.plan,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    final rawComplaints = (json['complaints'] as List<dynamic>?) ??
        (json['symptoms'] as List<dynamic>?);

    return Consultation(
      id: json['id'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpeciality: json['doctorSpeciality'] as String? ??
          json['doctorSpecialty'] as String? ??
          'General Physician',
      facility: json['facility'] as String? ??
          json['facilityName'] as String? ??
          'Primary Health Centre',
      date: json['date'] as String? ?? '',
      type: json['type'] as String? ?? 'In-person',
      complaints: rawComplaints?.map((e) => e.toString()).toList() ?? const [],
      diagnosis: json['diagnosis'] as String? ?? '',
      plan: json['plan'] as String? ?? json['doctorNotes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'doctorSpeciality': doctorSpeciality,
      'facility': facility,
      'date': date,
      'type': type,
      'complaints': complaints,
      'diagnosis': diagnosis,
      'plan': plan,
    };
  }
}
