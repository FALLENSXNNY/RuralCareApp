// Domain data models for RuralCare Child Care & Immunization (Universal Immunization Programme)

/// Age bracket category for pediatric immunization & care
enum ChildAgeBracket {
  atBirth,
  weeks6,
  weeks10,
  weeks14,
  months9to12,
  months16to24,
  years5to6,
}

/// A vaccination item based on India's National Immunization Schedule (NIS / UIP)
class ChildVaccine {
  final String id;
  final String name;
  final String fullName;
  final String ageGroup;
  final ChildAgeBracket ageBracket;
  final String route; // e.g. "Oral", "Intramuscular", "Intradermal"
  final String site; // e.g. "Left upper arm", "Right mid-thigh"
  final String dose; // e.g. "0.1 ml", "2 drops", "0.5 ml"
  final List<String> preventsDiseases;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? batchNumber;
  final String? notes;

  const ChildVaccine({
    required this.id,
    required this.name,
    required this.fullName,
    required this.ageGroup,
    required this.ageBracket,
    required this.route,
    required this.site,
    required this.dose,
    required this.preventsDiseases,
    this.isCompleted = false,
    this.completedDate,
    this.batchNumber,
    this.notes,
  });

  ChildVaccine copyWith({
    String? id,
    String? name,
    String? fullName,
    String? ageGroup,
    ChildAgeBracket? ageBracket,
    String? route,
    String? site,
    String? dose,
    List<String>? preventsDiseases,
    bool? isCompleted,
    DateTime? completedDate,
    String? batchNumber,
    String? notes,
  }) {
    return ChildVaccine(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      ageGroup: ageGroup ?? this.ageGroup,
      ageBracket: ageBracket ?? this.ageBracket,
      route: route ?? this.route,
      site: site ?? this.site,
      dose: dose ?? this.dose,
      preventsDiseases: preventsDiseases ?? this.preventsDiseases,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
    );
  }

  factory ChildVaccine.fromJson(Map<String, dynamic> json) {
    return ChildVaccine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      ageBracket: ChildAgeBracket.values.firstWhere(
        (e) => e.name == json['ageBracket'],
        orElse: () => ChildAgeBracket.atBirth,
      ),
      route: json['route'] as String? ?? 'Intramuscular',
      site: json['site'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      preventsDiseases: (json['preventsDiseases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.tryParse(json['completedDate'] as String)
          : null,
      batchNumber: json['batchNumber'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'ageGroup': ageGroup,
      'ageBracket': ageBracket.name,
      'route': route,
      'site': site,
      'dose': dose,
      'preventsDiseases': preventsDiseases,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'notes': notes,
    };
  }
}

/// Developmental Milestone classification
enum MilestoneDomain { motor, cognitive, speech, social }

class ChildMilestone {
  final String id;
  final String ageRange;
  final String title;
  final String description;
  final MilestoneDomain domain;
  final List<String> keyMilestones;
  final String stimulationTip;
  final String redFlags;

  const ChildMilestone({
    required this.id,
    required this.ageRange,
    required this.title,
    required this.description,
    required this.domain,
    required this.keyMilestones,
    required this.stimulationTip,
    required this.redFlags,
  });
}

/// Postnatal Care (PNC) Visit for Mother and Newborn (MoHFW Guidelines)
class PostnatalVisit {
  final int visitNumber;
  final String timing;
  final String title;
  final List<String> maternalChecks;
  final List<String> newbornChecks;
  final bool isCompleted;
  final DateTime? completedDate;

  const PostnatalVisit({
    required this.visitNumber,
    required this.timing,
    required this.title,
    required this.maternalChecks,
    required this.newbornChecks,
    this.isCompleted = false,
    this.completedDate,
  });

  PostnatalVisit copyWith({
    int? visitNumber,
    String? timing,
    String? title,
    List<String>? maternalChecks,
    List<String>? newbornChecks,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return PostnatalVisit(
      visitNumber: visitNumber ?? this.visitNumber,
      timing: timing ?? this.timing,
      title: title ?? this.title,
      maternalChecks: maternalChecks ?? this.maternalChecks,
      newbornChecks: newbornChecks ?? this.newbornChecks,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

/// Fetal Kick Count Session
class FetalKickSession {
  final DateTime timestamp;
  final int kicksCount;
  final int durationMinutes;
  final bool isNormal; // 10 kicks within 2 hours

  const FetalKickSession({
    required this.timestamp,
    required this.kicksCount,
    required this.durationMinutes,
    required this.isNormal,
  });

  factory FetalKickSession.fromJson(Map<String, dynamic> json) {
    return FetalKickSession(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      kicksCount: json['kicksCount'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      isNormal: json['isNormal'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'kicksCount': kicksCount,
        'durationMinutes': durationMinutes,
        'isNormal': isNormal,
      };
}
