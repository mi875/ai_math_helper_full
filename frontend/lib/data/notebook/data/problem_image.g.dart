// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProblemImage _$ProblemImageFromJson(Map<String, dynamic> json) =>
    _ProblemImage(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] as String,
      originalFilename: json['originalFilename'] as String,
      filename: json['filename'] as String,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      displayOrder: (json['displayOrder'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProblemImageToJson(_ProblemImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'originalFilename': instance.originalFilename,
      'filename': instance.filename,
      'fileUrl': instance.fileUrl,
      'mimeType': instance.mimeType,
      'fileSize': instance.fileSize,
      'width': instance.width,
      'height': instance.height,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt.toIso8601String(),
    };
