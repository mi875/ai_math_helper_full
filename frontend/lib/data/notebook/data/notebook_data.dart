import 'package:freezed_annotation/freezed_annotation.dart';
import 'math_problem.dart';

part 'notebook_data.freezed.dart';
part 'notebook_data.g.dart';

@freezed
abstract class Notebook with _$Notebook {
  const factory Notebook({
    required String id,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<MathProblem> problems,
    @Default('default') String coverColor,
  }) = _Notebook;

  factory Notebook.fromJson(Map<String, dynamic> json) =>
      _$NotebookFromJson(json);
}

@freezed
abstract class NotebookData with _$NotebookData {
  const factory NotebookData({
    @Default([]) List<Notebook> notebooks,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _NotebookData;

  factory NotebookData.fromJson(Map<String, dynamic> json) =>
      _$NotebookDataFromJson(json);
}
