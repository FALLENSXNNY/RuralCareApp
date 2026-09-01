// AI chat message model — represents a message in the AI health assistant conversation
class AiMessage {
  final String id;
  final String text;
  final bool isAi;
  final DateTime time;
  final bool isEmergency;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isAi,
    required this.time,
    this.isEmergency = false,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      text: json['text'] as String? ?? json['content'] as String? ?? '',
      isAi: json['isAi'] as bool? ?? (json['role'] == 'assistant'),
      time: DateTime.tryParse(json['time'] as String? ?? json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isAi': isAi,
      'time': time.toIso8601String(),
      'isEmergency': isEmergency,
    };
  }
}
