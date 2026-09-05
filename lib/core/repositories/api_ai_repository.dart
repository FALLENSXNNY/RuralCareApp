// Real API-backed implementation of AIRepository for Phase 7.
// Communicates with backend endpoints (/ai/chat, /ai/history) using bearer auth
// and automatically falls back to MockAIRepository on network errors or offline mode.
import '../error/app_exception.dart';
import '../models/ai_message.dart';
import '../networking/api_client.dart';
import '../repositories/mock_repositories.dart';
import '../services/firebase_auth_service.dart';
import 'ai_repository.dart';

class ApiAIRepository implements AIRepository {
  ApiAIRepository(ApiClient apiClient, FirebaseAuthService authService)
      : _apiClient = apiClient,
        _authService = authService,
        _fallback = MockAIRepository();

  final ApiClient _apiClient;
  final FirebaseAuthService _authService;
  final MockAIRepository _fallback;

  Future<String> _getIdToken() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw AppException.authentication('You are not signed in.');
    }
    String? token = await user.getIdToken(false);
    if (token == null || token.isEmpty) {
      token = await user.getIdToken(true);
    }
    if (token == null || token.isEmpty) {
      throw AppException.authentication('Could not obtain session token.');
    }
    return token;
  }

  @override
  Future<AiMessage> sendMessage(
    String message, {
    List<AiMessage>? history,
    String? language,
  }) async {
    try {
      final token = await _getIdToken();

      final payload = {
        'message': message,
        'language': language ?? 'en',
        if (history != null && history.isNotEmpty)
          'history': history.map((m) => m.toJson()).toList(),
      };

      final response = await _apiClient.request(
        '/ai/chat',
        method: ApiMethod.post,
        body: payload,
        authToken: token,
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.sendMessage(
          message,
          history: history,
          language: language,
        );
      }

      final data = response.data!;
      return AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: data['message'] as String? ?? 'No response returned.',
        isAi: true,
        time: DateTime.tryParse(data['timestamp'] as String? ?? '') ?? DateTime.now(),
        isEmergency: data['isEmergency'] as bool? ?? false,
      );
    } catch (_) {
      return await _fallback.sendMessage(
        message,
        history: history,
        language: language,
      );
    }
  }

  @override
  Future<List<AiMessage>> getConversationHistory() async {
    try {
      final token = await _getIdToken();

      final response = await _apiClient.request(
        '/ai/history',
        authToken: token,
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getConversationHistory();
      }

      final list = (response.data!['messages'] as List<dynamic>?) ?? const [];
      return list
          .map((item) => AiMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return await _fallback.getConversationHistory();
    }
  }

  @override
  Future<void> clearConversationHistory() async {
    try {
      final token = await _getIdToken();
      await _apiClient.request(
        '/ai/history',
        method: ApiMethod.delete,
        authToken: token,
      );
    } catch (_) {
      await _fallback.clearConversationHistory();
    }
  }
}
