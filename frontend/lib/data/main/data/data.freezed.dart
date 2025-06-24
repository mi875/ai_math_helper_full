// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MainData {

 int get count;
/// Create a copy of MainData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MainDataCopyWith<MainData> get copyWith => _$MainDataCopyWithImpl<MainData>(this as MainData, _$identity);

  /// Serializes this MainData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MainData&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'MainData(count: $count)';
}


}

/// @nodoc
abstract mixin class $MainDataCopyWith<$Res>  {
  factory $MainDataCopyWith(MainData value, $Res Function(MainData) _then) = _$MainDataCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$MainDataCopyWithImpl<$Res>
    implements $MainDataCopyWith<$Res> {
  _$MainDataCopyWithImpl(this._self, this._then);

  final MainData _self;
  final $Res Function(MainData) _then;

/// Create a copy of MainData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MainData implements MainData {
  const _MainData({required this.count});
  factory _MainData.fromJson(Map<String, dynamic> json) => _$MainDataFromJson(json);

@override final  int count;

/// Create a copy of MainData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MainDataCopyWith<_MainData> get copyWith => __$MainDataCopyWithImpl<_MainData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MainDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MainData&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'MainData(count: $count)';
}


}

/// @nodoc
abstract mixin class _$MainDataCopyWith<$Res> implements $MainDataCopyWith<$Res> {
  factory _$MainDataCopyWith(_MainData value, $Res Function(_MainData) _then) = __$MainDataCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$MainDataCopyWithImpl<$Res>
    implements _$MainDataCopyWith<$Res> {
  __$MainDataCopyWithImpl(this._self, this._then);

  final _MainData _self;
  final $Res Function(_MainData) _then;

/// Create a copy of MainData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_MainData(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
