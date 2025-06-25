import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_feedback.dart';
import 'problem_status.dart';
import 'problem_image.dart';

part 'math_problem.freezed.dart';
part 'math_problem.g.dart';

@freezed
abstract class MathProblem with _$MathProblem {
  const factory MathProblem({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    ProblemImage? image,
    String? scribbleData,
    @Default([]) List<AiFeedback> aiFeedbacks,
    @Default(ProblemStatus.unsolved) ProblemStatus status,
    @Default([]) List<String> tags,
  }) = _MathProblem;

  factory MathProblem.fromJson(Map<String, dynamic> json) =>
      _$MathProblemFromJson(json);
}
