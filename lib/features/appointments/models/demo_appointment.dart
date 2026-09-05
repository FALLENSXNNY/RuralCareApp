import '../../healthcare_finder/models/healthcare_place.dart';

/// Enum representing the status of an appointment
enum AppointmentStatus {
  confirmed,
  checkedIn,
  completed,
  cancelled,
}

/// Model representing a demo appointment
class DemoAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String facilityName;
  final String facilityAddress;
  final String date;
  final String timeSlot;
  final AppointmentStatus status;
  final String? queueToken;
  final HealthcarePlace? place;
  final DateTime createdAt;

  const DemoAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.facilityName,
    required this.facilityAddress,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.confirmed,
    this.queueToken,
    this.place,
    required this.createdAt,
  });

  bool get isCheckedIn => status == AppointmentStatus.checkedIn || queueToken != null;

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.checkedIn:
        return 'Checked In';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  DemoAppointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? facilityName,
    String? facilityAddress,
    String? date,
    String? timeSlot,
    AppointmentStatus? status,
    String? queueToken,
    HealthcarePlace? place,
    DateTime? createdAt,
  }) {
    return DemoAppointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      facilityName: facilityName ?? this.facilityName,
      facilityAddress: facilityAddress ?? this.facilityAddress,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      queueToken: queueToken ?? this.queueToken,
      place: place ?? this.place,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'facilityName': facilityName,
      'facilityAddress': facilityAddress,
      'date': date,
      'timeSlot': timeSlot,
      'status': status.name,
      'queueToken': queueToken,
      'place': place?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DemoAppointment.fromJson(Map<String, dynamic> json) {
    return DemoAppointment(
      id: json['id'] as String? ?? 'RC-DEMO-1024',
      doctorName: json['doctorName'] as String? ?? 'Dr. Krishanu Chakraborty',
      specialty: json['specialty'] as String? ?? 'Psychiatrist',
      facilityName: json['facilityName'] as String? ?? 'Doctor Clinic',
      facilityAddress: json['facilityAddress'] as String? ?? 'Prafulla Nagar Road',
      date: json['date'] as String? ?? 'September 6, 2026',
      timeSlot: json['timeSlot'] as String? ?? '10:30 AM',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.confirmed,
      ),
      queueToken: json['queueToken'] as String?,
      place: json['place'] != null
          ? HealthcarePlace.fromJson(json['place'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
