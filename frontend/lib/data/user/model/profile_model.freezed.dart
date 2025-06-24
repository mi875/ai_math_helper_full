// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState implements DiagnosticableTreeMixin {

 UserProfile? get profile; List<GradeOption> get gradeOptions; bool get isLoading; bool get isUpdating; String? get errorMessage;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProfileState'))
    ..add(DiagnosticsProperty('profile', profile))..add(DiagnosticsProperty('gradeOptions', gradeOptions))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isUpdating', isUpdating))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.gradeOptions, gradeOptions)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(gradeOptions),isLoading,isUpdating,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProfileState(profile: $profile, gradeOptions: $gradeOptions, isLoading: $isLoading, isUpdating: $isUpdating, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 UserProfile? profile, List<GradeOption> gradeOptions, bool isLoading, bool isUpdating, String? errorMessage
});


$UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = freezed,Object? gradeOptions = null,Object? isLoading = null,Object? isUpdating = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,gradeOptions: null == gradeOptions ? _self.gradeOptions : gradeOptions // ignore: cast_nullable_to_non_nullable
as List<GradeOption>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc


class _ProfileState with DiagnosticableTreeMixin implements ProfileState {
  const _ProfileState({this.profile, final  List<GradeOption> gradeOptions = const [], this.isLoading = false, this.isUpdating = false, this.errorMessage}): _gradeOptions = gradeOptions;
  

@override final  UserProfile? profile;
 final  List<GradeOption> _gradeOptions;
@override@JsonKey() List<GradeOption> get gradeOptions {
  if (_gradeOptions is EqualUnmodifiableListView) return _gradeOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gradeOptions);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isUpdating;
@override final  String? errorMessage;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProfileState'))
    ..add(DiagnosticsProperty('profile', profile))..add(DiagnosticsProperty('gradeOptions', gradeOptions))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isUpdating', isUpdating))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._gradeOptions, _gradeOptions)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_gradeOptions),isLoading,isUpdating,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProfileState(profile: $profile, gradeOptions: $gradeOptions, isLoading: $isLoading, isUpdating: $isUpdating, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 UserProfile? profile, List<GradeOption> gradeOptions, bool isLoading, bool isUpdating, String? errorMessage
});


@override $UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = freezed,Object? gradeOptions = null,Object? isLoading = null,Object? isUpdating = null,Object? errorMessage = freezed,}) {
  return _then(_ProfileState(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,gradeOptions: null == gradeOptions ? _self._gradeOptions : gradeOptions // ignore: cast_nullable_to_non_nullable
as List<GradeOption>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
