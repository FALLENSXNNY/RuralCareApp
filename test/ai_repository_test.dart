import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/ai_message.dart';
import 'package:ruralcare/core/repositories/mock_repositories.dart';

void main() {
  group('Phase 7 AI Assistant Models & Repository Tests', () {
    test('AiMessage fromJson and toJson roundtrip', () {
      final json = {
        'id': 'msg-101',
        'text': 'Drink plenty of water and rest well.',
        'isAi': true,
        'time': '2026-08-31T10:00:00.000Z',
        'isEmergency': false,
      };

      final msg = AiMessage.fromJson(json);
      expect(msg.id, 'msg-101');
      expect(msg.text, 'Drink plenty of water and rest well.');
      expect(msg.isAi, true);
      expect(msg.isEmergency, false);

      final serialized = msg.toJson();
      expect(serialized['id'], 'msg-101');
      expect(serialized['isAi'], true);
      expect(serialized['isEmergency'], false);
    });

    test('AiMessage fromJson handles emergency response payload', () {
      final json = {
        'id': 'msg-102',
        'text': '🚨 Call 108 immediately for snake bite.',
        'isAi': true,
        'time': '2026-08-31T10:01:00.000Z',
        'isEmergency': true,
      };

      final msg = AiMessage.fromJson(json);
      expect(msg.isEmergency, true);
      expect(msg.text, contains('108'));
    });

    test('MockAIRepository returns safe clinical response with disclaimer', () async {
      final repo = MockAIRepository();

      final response = await repo.sendMessage('I have a headache');
      expect(response.isAi, true);
      expect(response.text.isNotEmpty, true);
      expect(response.text.toLowerCase(), contains('general health information'));

      final history = await repo.getConversationHistory();
      expect(history.isNotEmpty, true);

      await repo.clearConversationHistory();
    });
  });
}
