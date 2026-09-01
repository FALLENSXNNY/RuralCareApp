// Prescription model — represents a doctor-issued prescription
class Prescription {
  final String id;
  final String doctorName;
  final String date;
  final List<String> medicines;
  final String notes;

  const Prescription({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.medicines,
    required this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    final rawMedicines = (json['medicines'] as List<dynamic>?) ??
        (json['medications'] as List<dynamic>?);

    final List<String> list = rawMedicines?.map((e) {
          if (e is Map<String, dynamic>) {
            final name = e['name'] ?? '';
            final dosage = e['dosage'] ?? '';
            final freq = e['frequency'] ?? '';
            final instr = e['instructions'] ?? '';
            final parts = [
              name,
              if (dosage.isNotEmpty) dosage,
              if (freq.isNotEmpty) '($freq)',
              if (instr.isNotEmpty) '• $instr',
            ];
            return parts.join(' ');
          }
          return e.toString();
        }).toList() ??
        const [];

    return Prescription(
      id: json['id'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      medicines: list,
      notes: json['notes'] as String? ?? json['diagnosis'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'date': date,
      'medicines': medicines,
      'notes': notes,
    };
  }
}
