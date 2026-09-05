// Model for pre-loaded first-aid topics and structured emergency steps
class FirstAidStep {
  const FirstAidStep({
    required this.step,
    required this.title,
    required this.body,
    this.isCaution = false,
    this.illustrationAsset,
  });

  final int step;
  final String title;
  final String body;
  final bool isCaution;
  final String? illustrationAsset;

  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    return FirstAidStep(
      step: json['step'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isCaution: json['isCaution'] as bool? ?? false,
      illustrationAsset: json['illustrationAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'body': body,
        'isCaution': isCaution,
        if (illustrationAsset != null) 'illustrationAsset': illustrationAsset,
      };
}

class FirstAidTopic {
  const FirstAidTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.urgency,
    required this.callAmb,
    this.warningBanner,
    this.steps = const [],
    this.dos = const [],
    this.donts = const [],
  });

  final String id;
  final String title;
  final String icon;
  final String urgency;
  final bool callAmb;
  final String? warningBanner;
  final List<FirstAidStep> steps;
  final List<String> dos;
  final List<String> donts;

  factory FirstAidTopic.fromJson(Map<String, dynamic> json) {
    return FirstAidTopic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '🚨',
      urgency: json['urgency'] as String? ?? 'MEDIUM',
      callAmb: json['callAmb'] as bool? ?? false,
      warningBanner: json['warningBanner'] as String?,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => FirstAidStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      donts: (json['donts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'urgency': urgency,
        'callAmb': callAmb,
        if (warningBanner != null) 'warningBanner': warningBanner,
        'steps': steps.map((s) => s.toJson()).toList(),
        'dos': dos,
        'donts': donts,
      };
}
