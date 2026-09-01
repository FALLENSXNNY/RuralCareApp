// Health record model — represents a patient's health record entry
class HealthRecord {
  final String id;
  final String type; // Prescription / Lab Report / Visit / Referral / etc.
  final String title;
  final String subtitle;
  final String date;
  final String? relatedId; // ID of the related entity (prescription, lab, etc.)

  const HealthRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.relatedId,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date'] as String? ?? '',
      relatedId: json['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'relatedId': relatedId,
    };
  }
}
