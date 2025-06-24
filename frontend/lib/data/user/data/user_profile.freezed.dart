// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 int get id; String get uid; String get email; String? get displayName; String? get grade; String? get gradeDisplayName; String? get profileImageUrl; String? get thumbnailUrl; int get totalTokens; int get usedTokens; int get remainingTokens;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.gradeDisplayName, gradeDisplayName) || other.gradeDisplayName == gradeDisplayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.usedTokens, usedTokens) || other.usedTokens == usedTokens)&&(identical(other.remainingTokens, remainingTokens) || other.remainingTokens == remainingTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,email,displayName,grade,gradeDisplayName,profileImageUrl,thumbnailUrl,totalTokens,usedTokens,remainingTokens);

@override
String toString() {
  return 'UserProfile(id: $id, uid: $uid, email: $email, displayName: $displayName, grade: $grade, gradeDisplayName: $gradeDisplayName, profileImageUrl: $profileImageUrl, thumbnailUrl: $thumbnailUrl, totalTokens: $totalTokens, usedTokens: $usedTokens, remainingTokens: $remainingTokens)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 int id, String uid, String email, String? displayName, String? grade, String? gradeDisplayName, String? profileImageUrl, String? thumbnailUrl, int totalTokens, int usedTokens, int remainingTokens
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? email = null,Object? displayName = freezed,Object? grade = freezed,Object? gradeDisplayName = freezed,Object? profileImageUrl = freezed,Object? thumbnailUrl = freezed,Object? totalTokens = null,Object? usedTokens = null,Object? remainingTokens = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,gradeDisplayName: freezed == gradeDisplayName ? _self.gradeDisplayName : gradeDisplayName // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,usedTokens: null == usedTokens ? _self.usedTokens : usedTokens // ignore: cast_nullable_to_non_nullable
as int,remainingTokens: null == remainingTokens ? _self.remainingTokens : remainingTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.uid, required this.email, this.displayName, this.grade, this.gradeDisplayName, this.profileImageUrl, this.thumbnailUrl, required this.totalTokens, required this.usedTokens, required this.remainingTokens});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  int id;
@override final  String uid;
@override final  String email;
@override final  String? displayName;
@override final  String? grade;
@override final  String? gradeDisplayName;
@override final  String? profileImageUrl;
@override final  String? thumbnailUrl;
@override final  int totalTokens;
@override final  int usedTokens;
@override final  int remainingTokens;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.gradeDisplayName, gradeDisplayName) || other.gradeDisplayName == gradeDisplayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.usedTokens, usedTokens) || other.usedTokens == usedTokens)&&(identical(other.remainingTokens, remainingTokens) || other.remainingTokens == remainingTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,email,displayName,grade,gradeDisplayName,profileImageUrl,thumbnailUrl,totalTokens,usedTokens,remainingTokens);

@override
String toString() {
  return 'UserProfile(id: $id, uid: $uid, email: $email, displayName: $displayName, grade: $grade, gradeDisplayName: $gradeDisplayName, profileImageUrl: $profileImageUrl, thumbnailUrl: $thumbnailUrl, totalTokens: $totalTokens, usedTokens: $usedTokens, remainingTokens: $remainingTokens)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String uid, String email, String? displayName, String? grade, String? gradeDisplayName, String? profileImageUrl, String? thumbnailUrl, int totalTokens, int usedTokens, int remainingTokens
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? email = null,Object? displayName = freezed,Object? grade = freezed,Object? gradeDisplayName = freezed,Object? profileImageUrl = freezed,Object? thumbnailUrl = freezed,Object? totalTokens = null,Object? usedTokens = null,Object? remainingTokens = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String?,gradeDisplayName: freezed == gradeDisplayName ? _self.gradeDisplayName : gradeDisplayName // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,usedTokens: null == usedTokens ? _self.usedTokens : usedTokens // ignore: cast_nullable_to_non_nullable
as int,remainingTokens: null == remainingTokens ? _self.remainingTokens : remainingTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GradeOption {

 String get key; String get displayName; String get category;
/// Create a copy of GradeOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GradeOptionCopyWith<GradeOption> get copyWith => _$GradeOptionCopyWithImpl<GradeOption>(this as GradeOption, _$identity);

  /// Serializes this GradeOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GradeOption&&(identical(other.key, key) || other.key == key)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,displayName,category);

@override
String toString() {
  return 'GradeOption(key: $key, displayName: $displayName, category: $category)';
}


}

/// @nodoc
abstract mixin class $GradeOptionCopyWith<$Res>  {
  factory $GradeOptionCopyWith(GradeOption value, $Res Function(GradeOption) _then) = _$GradeOptionCopyWithImpl;
@useResult
$Res call({
 String key, String displayName, String category
});




}
/// @nodoc
class _$GradeOptionCopyWithImpl<$Res>
    implements $GradeOptionCopyWith<$Res> {
  _$GradeOptionCopyWithImpl(this._self, this._then);

  final GradeOption _self;
  final $Res Function(GradeOption) _then;

/// Create a copy of GradeOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? displayName = null,Object? category = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _GradeOption implements GradeOption {
  const _GradeOption({required this.key, required this.displayName, required this.category});
  factory _GradeOption.fromJson(Map<String, dynamic> json) => _$GradeOptionFromJson(json);

@override final  String key;
@override final  String displayName;
@override final  String category;

/// Create a copy of GradeOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GradeOptionCopyWith<_GradeOption> get copyWith => __$GradeOptionCopyWithImpl<_GradeOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GradeOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GradeOption&&(identical(other.key, key) || other.key == key)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,displayName,category);

@override
String toString() {
  return 'GradeOption(key: $key, displayName: $displayName, category: $category)';
}


}

/// @nodoc
abstract mixin class _$GradeOptionCopyWith<$Res> implements $GradeOptionCopyWith<$Res> {
  factory _$GradeOptionCopyWith(_GradeOption value, $Res Function(_GradeOption) _then) = __$GradeOptionCopyWithImpl;
@override @useResult
$Res call({
 String key, String displayName, String category
});




}
/// @nodoc
class __$GradeOptionCopyWithImpl<$Res>
    implements _$GradeOptionCopyWith<$Res> {
  __$GradeOptionCopyWithImpl(this._self, this._then);

  final _GradeOption _self;
  final $Res Function(_GradeOption) _then;

/// Create a copy of GradeOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? displayName = null,Object? category = null,}) {
  return _then(_GradeOption(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TokenStatus {

 int get totalTokens; int get usedTokens; int get remainingTokens; DateTime get resetDate; bool get hasLowTokens;
/// Create a copy of TokenStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenStatusCopyWith<TokenStatus> get copyWith => _$TokenStatusCopyWithImpl<TokenStatus>(this as TokenStatus, _$identity);

  /// Serializes this TokenStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenStatus&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.usedTokens, usedTokens) || other.usedTokens == usedTokens)&&(identical(other.remainingTokens, remainingTokens) || other.remainingTokens == remainingTokens)&&(identical(other.resetDate, resetDate) || other.resetDate == resetDate)&&(identical(other.hasLowTokens, hasLowTokens) || other.hasLowTokens == hasLowTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTokens,usedTokens,remainingTokens,resetDate,hasLowTokens);

@override
String toString() {
  return 'TokenStatus(totalTokens: $totalTokens, usedTokens: $usedTokens, remainingTokens: $remainingTokens, resetDate: $resetDate, hasLowTokens: $hasLowTokens)';
}


}

/// @nodoc
abstract mixin class $TokenStatusCopyWith<$Res>  {
  factory $TokenStatusCopyWith(TokenStatus value, $Res Function(TokenStatus) _then) = _$TokenStatusCopyWithImpl;
@useResult
$Res call({
 int totalTokens, int usedTokens, int remainingTokens, DateTime resetDate, bool hasLowTokens
});




}
/// @nodoc
class _$TokenStatusCopyWithImpl<$Res>
    implements $TokenStatusCopyWith<$Res> {
  _$TokenStatusCopyWithImpl(this._self, this._then);

  final TokenStatus _self;
  final $Res Function(TokenStatus) _then;

/// Create a copy of TokenStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTokens = null,Object? usedTokens = null,Object? remainingTokens = null,Object? resetDate = null,Object? hasLowTokens = null,}) {
  return _then(_self.copyWith(
totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,usedTokens: null == usedTokens ? _self.usedTokens : usedTokens // ignore: cast_nullable_to_non_nullable
as int,remainingTokens: null == remainingTokens ? _self.remainingTokens : remainingTokens // ignore: cast_nullable_to_non_nullable
as int,resetDate: null == resetDate ? _self.resetDate : resetDate // ignore: cast_nullable_to_non_nullable
as DateTime,hasLowTokens: null == hasLowTokens ? _self.hasLowTokens : hasLowTokens // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TokenStatus implements TokenStatus {
  const _TokenStatus({required this.totalTokens, required this.usedTokens, required this.remainingTokens, required this.resetDate, required this.hasLowTokens});
  factory _TokenStatus.fromJson(Map<String, dynamic> json) => _$TokenStatusFromJson(json);

@override final  int totalTokens;
@override final  int usedTokens;
@override final  int remainingTokens;
@override final  DateTime resetDate;
@override final  bool hasLowTokens;

/// Create a copy of TokenStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenStatusCopyWith<_TokenStatus> get copyWith => __$TokenStatusCopyWithImpl<_TokenStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenStatus&&(identical(other.totalTokens, totalTokens) || other.totalTokens == totalTokens)&&(identical(other.usedTokens, usedTokens) || other.usedTokens == usedTokens)&&(identical(other.remainingTokens, remainingTokens) || other.remainingTokens == remainingTokens)&&(identical(other.resetDate, resetDate) || other.resetDate == resetDate)&&(identical(other.hasLowTokens, hasLowTokens) || other.hasLowTokens == hasLowTokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTokens,usedTokens,remainingTokens,resetDate,hasLowTokens);

@override
String toString() {
  return 'TokenStatus(totalTokens: $totalTokens, usedTokens: $usedTokens, remainingTokens: $remainingTokens, resetDate: $resetDate, hasLowTokens: $hasLowTokens)';
}


}

/// @nodoc
abstract mixin class _$TokenStatusCopyWith<$Res> implements $TokenStatusCopyWith<$Res> {
  factory _$TokenStatusCopyWith(_TokenStatus value, $Res Function(_TokenStatus) _then) = __$TokenStatusCopyWithImpl;
@override @useResult
$Res call({
 int totalTokens, int usedTokens, int remainingTokens, DateTime resetDate, bool hasLowTokens
});




}
/// @nodoc
class __$TokenStatusCopyWithImpl<$Res>
    implements _$TokenStatusCopyWith<$Res> {
  __$TokenStatusCopyWithImpl(this._self, this._then);

  final _TokenStatus _self;
  final $Res Function(_TokenStatus) _then;

/// Create a copy of TokenStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTokens = null,Object? usedTokens = null,Object? remainingTokens = null,Object? resetDate = null,Object? hasLowTokens = null,}) {
  return _then(_TokenStatus(
totalTokens: null == totalTokens ? _self.totalTokens : totalTokens // ignore: cast_nullable_to_non_nullable
as int,usedTokens: null == usedTokens ? _self.usedTokens : usedTokens // ignore: cast_nullable_to_non_nullable
as int,remainingTokens: null == remainingTokens ? _self.remainingTokens : remainingTokens // ignore: cast_nullable_to_non_nullable
as int,resetDate: null == resetDate ? _self.resetDate : resetDate // ignore: cast_nullable_to_non_nullable
as DateTime,hasLowTokens: null == hasLowTokens ? _self.hasLowTokens : hasLowTokens // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
