// Data models for RuralCare V2 Pregnancy & Maternal Care

/// High-level risk classification for pregnancy
enum PregnancyRiskLevel {
  normal,
  highRisk,
}

/// Trimester stages
enum PregnancyTrimester {
  first,
  second,
  third,
}

/// Patient Pregnancy Profile
class PregnancyProfile {
  final String id;
  final String patientId;
  final bool isPregnant;
  final DateTime? estimatedDueDate;
  final DateTime? lastMenstrualPeriod;
  final int currentWeek;
  final PregnancyRiskLevel riskLevel;
  final String? primaryHealthCenter;
  final String? doctorOrAshaWorker;
  final String? notes;
  final DateTime updatedAt;

  const PregnancyProfile({
    required this.id,
    required this.patientId,
    this.isPregnant = true,
    this.estimatedDueDate,
    this.lastMenstrualPeriod,
    this.currentWeek = 1,
    this.riskLevel = PregnancyRiskLevel.normal,
    this.primaryHealthCenter,
    this.doctorOrAshaWorker,
    this.notes,
    required this.updatedAt,
  });

  PregnancyProfile copyWith({
    String? id,
    String? patientId,
    bool? isPregnant,
    DateTime? estimatedDueDate,
    DateTime? lastMenstrualPeriod,
    int? currentWeek,
    PregnancyRiskLevel? riskLevel,
    String? primaryHealthCenter,
    String? doctorOrAshaWorker,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PregnancyProfile(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      isPregnant: isPregnant ?? this.isPregnant,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      currentWeek: currentWeek ?? this.currentWeek,
      riskLevel: riskLevel ?? this.riskLevel,
      primaryHealthCenter: primaryHealthCenter ?? this.primaryHealthCenter,
      doctorOrAshaWorker: doctorOrAshaWorker ?? this.doctorOrAshaWorker,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PregnancyProfile.fromJson(Map<String, dynamic> json) {
    return PregnancyProfile(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      isPregnant: json['isPregnant'] as bool? ?? true,
      estimatedDueDate: json['estimatedDueDate'] != null
          ? DateTime.tryParse(json['estimatedDueDate'] as String)
          : null,
      lastMenstrualPeriod: json['lastMenstrualPeriod'] != null
          ? DateTime.tryParse(json['lastMenstrualPeriod'] as String)
          : null,
      currentWeek: json['currentWeek'] as int? ?? 1,
      riskLevel: json['riskLevel'] == 'highRisk'
          ? PregnancyRiskLevel.highRisk
          : PregnancyRiskLevel.normal,
      primaryHealthCenter: json['primaryHealthCenter'] as String?,
      doctorOrAshaWorker: json['doctorOrAshaWorker'] as String?,
      notes: json['notes'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'isPregnant': isPregnant,
      'estimatedDueDate': estimatedDueDate?.toIso8601String(),
      'lastMenstrualPeriod': lastMenstrualPeriod?.toIso8601String(),
      'currentWeek': currentWeek,
      'riskLevel': riskLevel == PregnancyRiskLevel.highRisk ? 'highRisk' : 'normal',
      'primaryHealthCenter': primaryHealthCenter,
      'doctorOrAshaWorker': doctorOrAshaWorker,
      'notes': notes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Standard Antenatal Care (ANC) visit model (MoHFW / WHO guidelines)
class AntenatalVisit {
  final int visitNumber;
  final String title;
  final String weekRange;
  final String description;
  final List<String> testsAndProcedures;
  final DateTime? scheduledDate;
  final bool isCompleted;
  final String? clinicName;
  final String? doctorNotes;

  const AntenatalVisit({
    required this.visitNumber,
    required this.title,
    required this.weekRange,
    required this.description,
    required this.testsAndProcedures,
    this.scheduledDate,
    this.isCompleted = false,
    this.clinicName,
    this.doctorNotes,
  });

  AntenatalVisit copyWith({
    int? visitNumber,
    String? title,
    String? weekRange,
    String? description,
    List<String>? testsAndProcedures,
    DateTime? scheduledDate,
    bool? isCompleted,
    String? clinicName,
    String? doctorNotes,
  }) {
    return AntenatalVisit(
      visitNumber: visitNumber ?? this.visitNumber,
      title: title ?? this.title,
      weekRange: weekRange ?? this.weekRange,
      description: description ?? this.description,
      testsAndProcedures: testsAndProcedures ?? this.testsAndProcedures,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      clinicName: clinicName ?? this.clinicName,
      doctorNotes: doctorNotes ?? this.doctorNotes,
    );
  }

  factory AntenatalVisit.fromJson(Map<String, dynamic> json) {
    return AntenatalVisit(
      visitNumber: json['visitNumber'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      weekRange: json['weekRange'] as String? ?? '',
      description: json['description'] as String? ?? '',
      testsAndProcedures: (json['testsAndProcedures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      clinicName: json['clinicName'] as String?,
      doctorNotes: json['doctorNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitNumber': visitNumber,
      'title': title,
      'weekRange': weekRange,
      'description': description,
      'testsAndProcedures': testsAndProcedures,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'clinicName': clinicName,
      'doctorNotes': doctorNotes,
    };
  }
}

/// Educational guidance item structured by trimester and category
class PregnancyGuidanceItem {
  final String id;
  final PregnancyTrimester trimester;
  final String category; // 'Nutrition', 'Wellness', 'Exercises', 'Medical'
  final String title;
  final String summary;
  final List<String> bulletPoints;
  final String? importantNotice;

  const PregnancyGuidanceItem({
    required this.id,
    required this.trimester,
    required this.category,
    required this.title,
    required this.summary,
    required this.bulletPoints,
    this.importantNotice,
  });
}

/// Symptom triage item with urgency classification
enum SymptomUrgency {
  routine,
  concerning,
  emergency,
}

class PregnancySymptom {
  final String id;
  final String name;
  final String description;
  final SymptomUrgency urgency;
  final String actionRequired;
  final bool isEmergencyWarningSign;

  const PregnancySymptom({
    required this.id,
    required this.name,
    required this.description,
    required this.urgency,
    required this.actionRequired,
    this.isEmergencyWarningSign = false,
  });
}
