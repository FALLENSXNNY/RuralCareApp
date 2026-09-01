import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/first_aid_topic.dart';

void main() {
  group('Phase 6 Emergency First Aid Model & Dataset Tests', () {
    test('FirstAidTopic and FirstAidStep fromJson and toJson roundtrip', () {
      final json = {
        'id': 'snake_bite',
        'title': 'Snake Bite',
        'icon': '🐍',
        'urgency': 'HIGH',
        'callAmb': true,
        'warningBanner': 'Do NOT suck venom.',
        'steps': [
          {
            'step': 1,
            'title': 'Stay Calm',
            'body': 'Keep the person completely still.',
            'isCaution': false,
          },
        ],
        'dos': ['Keep person calm and still'],
        'donts': ['Do NOT cut the bite area'],
      };

      final topic = FirstAidTopic.fromJson(json);
      expect(topic.id, 'snake_bite');
      expect(topic.title, 'Snake Bite');
      expect(topic.urgency, 'HIGH');
      expect(topic.callAmb, true);
      expect(topic.warningBanner, 'Do NOT suck venom.');
      expect(topic.steps.length, 1);
      expect(topic.steps.first.title, 'Stay Calm');
      expect(topic.dos.length, 1);
      expect(topic.donts.length, 1);

      final serialized = topic.toJson();
      expect(serialized['id'], 'snake_bite');
      expect(serialized['callAmb'], true);
    });

    test('Bundled first_aid_content.json contains all 10 rural emergency protocols', () {
      final file = File('assets/emergency/first_aid_content.json');
      expect(file.existsSync(), true, reason: 'assets/emergency/first_aid_content.json must exist');

      final raw = file.readAsStringSync();
      final List<dynamic> list = jsonDecode(raw);
      expect(list.length, greaterThanOrEqualTo(10));

      final topicIds = <String>{};
      for (final item in list) {
        final topic = FirstAidTopic.fromJson(item as Map<String, dynamic>);
        expect(topic.id.isNotEmpty, true);
        expect(topic.title.isNotEmpty, true);
        expect(topic.icon.isNotEmpty, true);
        expect(topic.steps.isNotEmpty, true, reason: 'Topic ${topic.id} must have steps');
        expect(topic.dos.isNotEmpty, true, reason: 'Topic ${topic.id} must have DOs');
        expect(topic.donts.isNotEmpty, true, reason: 'Topic ${topic.id} must have DON\'Ts');
        expect(['HIGH', 'MEDIUM', 'LOW'], contains(topic.urgency.toUpperCase()));
        topicIds.add(topic.id);
      }

      // Check required emergency topics
      expect(topicIds, contains('snake_bite'));
      expect(topicIds, contains('chest_pain'));
      expect(topicIds, contains('bleeding'));
      expect(topicIds, contains('burns'));
      expect(topicIds, contains('choking'));
      expect(topicIds, contains('unconscious'));
      expect(topicIds, contains('fracture'));
      expect(topicIds, contains('heat_stroke'));
      expect(topicIds, contains('poisoning'));
      expect(topicIds, contains('high_fever'));
    });
  });
}
