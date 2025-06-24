// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebook_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notebook _$NotebookFromJson(Map<String, dynamic> json) => _Notebook(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  problems:
      (json['problems'] as List<dynamic>?)
          ?.map((e) => MathProblem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  coverColor: json['coverColor'] as String? ?? 'default',
);

Map<String, dynamic> _$NotebookToJson(_Notebook instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'problems': instance.problems,
  'coverColor': instance.coverColor,
};

_NotebookData _$NotebookDataFromJson(Map<String, dynamic> json) =>
    _NotebookData(
      notebooks:
          (json['notebooks'] as List<dynamic>?)
              ?.map((e) => Notebook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$NotebookDataToJson(_NotebookData instance) =>
    <String, dynamic>{
      'notebooks': instance.notebooks,
      'isLoading': instance.isLoading,
      'errorMessage': instance.errorMessage,
    };
