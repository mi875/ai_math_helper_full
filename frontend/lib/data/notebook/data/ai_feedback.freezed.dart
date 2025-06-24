// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiFeedback {

 String get id; String get message; DateTime get timestamp; FeedbackType get type; String? get relatedImagePath;
/// Create a copy of AiFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiFeedbackCopyWith<AiFeedback> get copyWith => _$AiFeedbackCopyWithImpl<AiFeedback>(this as AiFeedback, _$identity);

  /// Serializes this AiFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.relatedImagePath, relatedImagePath) || other.relatedImagePath == relatedImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,timestamp,type,relatedImagePath);

@override
String toString() {
  return 'AiFeedback(id: $id, message: $message, timestamp: $timestamp, type: $type, relatedImagePath: $relatedImagePath)';
}


}

/// @nodoc
abstract mixin class $AiFeedbackCopyWith<$Res>  {
  factory $AiFeedbackCopyWith(AiFeedback value, $Res Function(AiFeedback) _then) = _$AiFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String message, DateTime timestamp, FeedbackType type, String? relatedImagePath
});




}
/// @nodoc
class _$AiFeedbackCopyWithImpl<$Res>
    implements $AiFeedbackCopyWith<$Res> {
  _$AiFeedbackCopyWithImpl(this._self, this._then);

  final AiFeedback _self;
  final $Res Function(AiFeedback) _then;

/// Create a copy of AiFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? timestamp = null,Object? type = null,Object? relatedImagePath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedbackType,relatedImagePath: freezed == relatedImagePath ? _self.relatedImagePath : relatedImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AiFeedback implements AiFeedback {
  const _AiFeedback({required this.id, required this.message, required this.timestamp, this.type = FeedbackType.suggestion, this.relatedImagePath});
  factory _AiFeedback.fromJson(Map<String, dynamic> json) => _$AiFeedbackFromJson(json);

@override final  String id;
@override final  String message;
@override final  DateTime timestamp;
@override@JsonKey() final  FeedbackType type;
@override final  String? relatedImagePath;

/// Create a copy of AiFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiFeedbackCopyWith<_AiFeedback> get copyWith => __$AiFeedbackCopyWithImpl<_AiFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.type, type) || other.type == type)&&(identical(other.relatedImagePath, relatedImagePath) || other.relatedImagePath == relatedImagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,timestamp,type,relatedImagePath);

@override
String toString() {
  return 'AiFeedback(id: $id, message: $message, timestamp: $timestamp, type: $type, relatedImagePath: $relatedImagePath)';
}


}

/// @nodoc
abstract mixin class _$AiFeedbackCopyWith<$Res> implements $AiFeedbackCopyWith<$Res> {
  factory _$AiFeedbackCopyWith(_AiFeedback value, $Res Function(_AiFeedback) _then) = __$AiFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String message, DateTime timestamp, FeedbackType type, String? relatedImagePath
});




}
/// @nodoc
class __$AiFeedbackCopyWithImpl<$Res>
    implements _$AiFeedbackCopyWith<$Res> {
  __$AiFeedbackCopyWithImpl(this._self, this._then);

  final _AiFeedback _self;
  final $Res Function(_AiFeedback) _then;

/// Create a copy of AiFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? timestamp = null,Object? type = null,Object? relatedImagePath = freezed,}) {
  return _then(_AiFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedbackType,relatedImagePath: freezed == relatedImagePath ? _self.relatedImagePath : relatedImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
