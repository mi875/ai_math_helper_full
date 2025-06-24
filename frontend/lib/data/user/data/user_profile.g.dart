// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: (json['id'] as num).toInt(),
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  grade: json['grade'] as String?,
  gradeDisplayName: json['gradeDisplayName'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  totalTokens: (json['totalTokens'] as num).toInt(),
  usedTokens: (json['usedTokens'] as num).toInt(),
  remainingTokens: (json['remainingTokens'] as num).toInt(),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'grade': instance.grade,
      'gradeDisplayName': instance.gradeDisplayName,
      'profileImageUrl': instance.profileImageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'totalTokens': instance.totalTokens,
      'usedTokens': instance.usedTokens,
      'remainingTokens': instance.remainingTokens,
    };

_GradeOption _$GradeOptionFromJson(Map<String, dynamic> json) => _GradeOption(
  key: json['key'] as String,
  displayName: json['displayName'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$GradeOptionToJson(_GradeOption instance) =>
    <String, dynamic>{
      'key': instance.key,
      'displayName': instance.displayName,
      'category': instance.category,
    };

_TokenStatus _$TokenStatusFromJson(Map<String, dynamic> json) => _TokenStatus(
  totalTokens: (json['totalTokens'] as num).toInt(),
  usedTokens: (json['usedTokens'] as num).toInt(),
  remainingTokens: (json['remainingTokens'] as num).toInt(),
  resetDate: DateTime.parse(json['resetDate'] as String),
  hasLowTokens: json['hasLowTokens'] as bool,
);

Map<String, dynamic> _$TokenStatusToJson(_TokenStatus instance) =>
    <String, dynamic>{
      'totalTokens': instance.totalTokens,
      'usedTokens': instance.usedTokens,
      'remainingTokens': instance.remainingTokens,
      'resetDate': instance.resetDate.toIso8601String(),
      'hasLowTokens': instance.hasLowTokens,
    };
