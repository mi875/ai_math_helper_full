// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  sender:
      $enumDecodeNullable(_$MessageSenderEnumMap, json['sender']) ??
      MessageSender.user,
  feedbackType: json['feedbackType'] as String?,
  threadId: json['threadId'] as String?,
  resourceId: json['resourceId'] as String?,
  state:
      $enumDecodeNullable(_$ConversationStateEnumMap, json['state']) ??
      ConversationState.normal,
  isFromMemory: json['isFromMemory'] as bool?,
  tokensConsumed: (json['tokensConsumed'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'feedbackType': instance.feedbackType,
      'threadId': instance.threadId,
      'resourceId': instance.resourceId,
      'state': _$ConversationStateEnumMap[instance.state]!,
      'isFromMemory': instance.isFromMemory,
      'tokensConsumed': instance.tokensConsumed,
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.ai: 'ai',
};

const _$ConversationStateEnumMap = {
  ConversationState.normal: 'normal',
  ConversationState.streaming: 'streaming',
  ConversationState.error: 'error',
};
