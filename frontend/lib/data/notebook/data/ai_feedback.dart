import 'package:freezed_annotation/freezed_annotation.dart';
import 'problem_status.dart';

part 'ai_feedback.freezed.dart';
part 'ai_feedback.g.dart';

@freezed
abstract class AiFeedback with _$AiFeedback {
  const factory AiFeedback({
    required String id,
    required String message,
    required DateTime timestamp,
    @Default(FeedbackType.suggestion) FeedbackType type,
    String? relatedImagePath,
  }) = _AiFeedback;

  factory AiFeedback.fromJson(Map<String, dynamic> json) =>
      _$AiFeedbackFromJson(json);
}
