// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiFeedback _$AiFeedbackFromJson(Map<String, dynamic> json) => _AiFeedback(
  id: json['id'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type:
      $enumDecodeNullable(_$FeedbackTypeEnumMap, json['type']) ??
      FeedbackType.suggestion,
  relatedImagePath: json['relatedImagePath'] as String?,
);

Map<String, dynamic> _$AiFeedbackToJson(_AiFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'relatedImagePath': instance.relatedImagePath,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.suggestion: 'suggestion',
  FeedbackType.correction: 'correction',
  FeedbackType.explanation: 'explanation',
  FeedbackType.encouragement: 'encouragement',
};
