import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String uid,
    required String email,
    String? displayName,
    String? grade,
    String? gradeDisplayName,
    String? profileImageUrl,
    String? thumbnailUrl,
    required int totalTokens,
    required int usedTokens,
    required int remainingTokens,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class GradeOption with _$GradeOption {
  const factory GradeOption({
    required String key,
    required String displayName,
    required String category,
  }) = _GradeOption;

  factory GradeOption.fromJson(Map<String, dynamic> json) =>
      _$GradeOptionFromJson(json);
}

@freezed
abstract class TokenStatus with _$TokenStatus {
  const factory TokenStatus({
    required int totalTokens,
    required int usedTokens,
    required int remainingTokens,
    required DateTime resetDate,
    required bool hasLowTokens,
  }) = _TokenStatus;

  factory TokenStatus.fromJson(Map<String, dynamic> json) =>
      _$TokenStatusFromJson(json);
}