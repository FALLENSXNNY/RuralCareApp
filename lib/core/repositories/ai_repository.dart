// AI repository — abstraction for AI health assistant communication
// IMPORTANT: This is an abstraction only. No API keys or AI provider
// credentials are stored in Flutter code. The actual AI service is
// accessed through the backend (Phase 7).
import '../models/ai_message.dart';

abstract class AIRepository {
  /// Sends a message to the AI assistant and returns the response.
  /// The AI must follow AI_SAFETY.md rules and synchronize language.
  Future<AiMessage> sendMessage(
    String message, {
    List<AiMessage>? history,
    String? language,
  });

  /// Returns the conversation history.
  Future<List<AiMessage>> getConversationHistory();

  /// Clears the conversation history for the current patient.
  Future<void> clearConversationHistory();
}
