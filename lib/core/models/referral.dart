// Referral model — represents a patient referral between healthcare facilities
class Referral {
  final String id;
  final String referredTo;
  final String speciality;
  final String date;
  final String reason;
  final String status; // Pending / Accepted / Completed

  const Referral({
    required this.id,
    required this.referredTo,
    required this.speciality,
    required this.date,
    required this.reason,
    required this.status,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String? ?? '',
      referredTo: json['referredTo'] as String? ?? json['toFacility'] as String? ?? '',
      speciality: json['speciality'] as String? ?? json['specialtyRequired'] as String? ?? '',
      date: json['date'] as String? ?? json['referralDate'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'Initiated',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referredTo': referredTo,
      'speciality': speciality,
      'date': date,
      'reason': reason,
      'status': status,
    };
  }
}
