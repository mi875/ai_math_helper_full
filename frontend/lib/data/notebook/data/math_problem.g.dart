// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'math_problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MathProblem _$MathProblemFromJson(Map<String, dynamic> json) => _MathProblem(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  imagePaths:
      (json['imagePaths'] as List<dynamic>?)?.map((e) => e as String).toList(),
  scribbleData: json['scribbleData'] as String?,
  aiFeedbacks:
      (json['aiFeedbacks'] as List<dynamic>?)
          ?.map((e) => AiFeedback.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ProblemStatusEnumMap, json['status']) ??
      ProblemStatus.unsolved,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$MathProblemToJson(_MathProblem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'imagePaths': instance.imagePaths,
      'scribbleData': instance.scribbleData,
      'aiFeedbacks': instance.aiFeedbacks,
      'status': _$ProblemStatusEnumMap[instance.status]!,
      'tags': instance.tags,
    };

const _$ProblemStatusEnumMap = {
  ProblemStatus.unsolved: 'unsolved',
  ProblemStatus.inProgress: 'inProgress',
  ProblemStatus.solved: 'solved',
  ProblemStatus.needsHelp: 'needsHelp',
};
