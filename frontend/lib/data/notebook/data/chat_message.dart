import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageSender {
  user,
  ai,
}

enum ConversationState {
  normal,
  streaming,
  error,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String message,
    required DateTime timestamp,
    @Default(MessageSender.user) MessageSender sender,
    String? feedbackType, // For AI messages, stores the original feedback type
    String? threadId, // Conversation thread ID for memory context
    String? resourceId, // Resource ID for memory scoping
    @Default(ConversationState.normal) ConversationState state, // Message state for streaming
    bool? isFromMemory, // Whether this message was loaded from conversation history
    int? tokensConsumed, // Tokens consumed for AI responses
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  // Helper method to create a user message
  factory ChatMessage.user({
    required String message,
    String? threadId,
    String? resourceId,
  }) {
    return ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
      threadId: threadId,
      resourceId: resourceId,
    );
  }

  // Helper method to create an AI message
  factory ChatMessage.ai({
    required String id,
    required String message,
    required DateTime timestamp,
    String? feedbackType,
    String? threadId,
    String? resourceId,
    ConversationState state = ConversationState.normal,
    int? tokensConsumed,
  }) {
    return ChatMessage(
      id: id,
      message: message,
      timestamp: timestamp,
      sender: MessageSender.ai,
      feedbackType: feedbackType,
      threadId: threadId,
      resourceId: resourceId,
      state: state,
      tokensConsumed: tokensConsumed,
    );
  }

  // Helper method to create a streaming AI message
  factory ChatMessage.aiStreaming({
    required String message,
    String? threadId,
    String? resourceId,
  }) {
    return ChatMessage(
      id: 'ai-streaming-${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      timestamp: DateTime.now(),
      sender: MessageSender.ai,
      threadId: threadId,
      resourceId: resourceId,
      state: ConversationState.streaming,
    );
  }

  // Helper method to create an error message
  factory ChatMessage.error({
    required String message,
    String? threadId,
    String? resourceId,
  }) {
    return ChatMessage(
      id: 'error-${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      timestamp: DateTime.now(),
      sender: MessageSender.ai,
      threadId: threadId,
      resourceId: resourceId,
      state: ConversationState.error,
    );
  }
}