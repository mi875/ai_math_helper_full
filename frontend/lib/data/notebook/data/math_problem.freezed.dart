// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'math_problem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MathProblem {

 String get id; String get title; String? get description; DateTime get createdAt; DateTime get updatedAt; List<String>? get imagePaths; String? get scribbleData; List<AiFeedback> get aiFeedbacks; ProblemStatus get status; List<String> get tags;
/// Create a copy of MathProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MathProblemCopyWith<MathProblem> get copyWith => _$MathProblemCopyWithImpl<MathProblem>(this as MathProblem, _$identity);

  /// Serializes this MathProblem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MathProblem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths)&&(identical(other.scribbleData, scribbleData) || other.scribbleData == scribbleData)&&const DeepCollectionEquality().equals(other.aiFeedbacks, aiFeedbacks)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,createdAt,updatedAt,const DeepCollectionEquality().hash(imagePaths),scribbleData,const DeepCollectionEquality().hash(aiFeedbacks),status,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'MathProblem(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, imagePaths: $imagePaths, scribbleData: $scribbleData, aiFeedbacks: $aiFeedbacks, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $MathProblemCopyWith<$Res>  {
  factory $MathProblemCopyWith(MathProblem value, $Res Function(MathProblem) _then) = _$MathProblemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, DateTime createdAt, DateTime updatedAt, List<String>? imagePaths, String? scribbleData, List<AiFeedback> aiFeedbacks, ProblemStatus status, List<String> tags
});




}
/// @nodoc
class _$MathProblemCopyWithImpl<$Res>
    implements $MathProblemCopyWith<$Res> {
  _$MathProblemCopyWithImpl(this._self, this._then);

  final MathProblem _self;
  final $Res Function(MathProblem) _then;

/// Create a copy of MathProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? imagePaths = freezed,Object? scribbleData = freezed,Object? aiFeedbacks = null,Object? status = null,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,imagePaths: freezed == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>?,scribbleData: freezed == scribbleData ? _self.scribbleData : scribbleData // ignore: cast_nullable_to_non_nullable
as String?,aiFeedbacks: null == aiFeedbacks ? _self.aiFeedbacks : aiFeedbacks // ignore: cast_nullable_to_non_nullable
as List<AiFeedback>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProblemStatus,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MathProblem implements MathProblem {
  const _MathProblem({required this.id, required this.title, this.description, required this.createdAt, required this.updatedAt, final  List<String>? imagePaths, this.scribbleData, final  List<AiFeedback> aiFeedbacks = const [], this.status = ProblemStatus.unsolved, final  List<String> tags = const []}): _imagePaths = imagePaths,_aiFeedbacks = aiFeedbacks,_tags = tags;
  factory _MathProblem.fromJson(Map<String, dynamic> json) => _$MathProblemFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<String>? _imagePaths;
@override List<String>? get imagePaths {
  final value = _imagePaths;
  if (value == null) return null;
  if (_imagePaths is EqualUnmodifiableListView) return _imagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? scribbleData;
 final  List<AiFeedback> _aiFeedbacks;
@override@JsonKey() List<AiFeedback> get aiFeedbacks {
  if (_aiFeedbacks is EqualUnmodifiableListView) return _aiFeedbacks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aiFeedbacks);
}

@override@JsonKey() final  ProblemStatus status;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of MathProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MathProblemCopyWith<_MathProblem> get copyWith => __$MathProblemCopyWithImpl<_MathProblem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MathProblemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MathProblem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._imagePaths, _imagePaths)&&(identical(other.scribbleData, scribbleData) || other.scribbleData == scribbleData)&&const DeepCollectionEquality().equals(other._aiFeedbacks, _aiFeedbacks)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,createdAt,updatedAt,const DeepCollectionEquality().hash(_imagePaths),scribbleData,const DeepCollectionEquality().hash(_aiFeedbacks),status,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'MathProblem(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, imagePaths: $imagePaths, scribbleData: $scribbleData, aiFeedbacks: $aiFeedbacks, status: $status, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$MathProblemCopyWith<$Res> implements $MathProblemCopyWith<$Res> {
  factory _$MathProblemCopyWith(_MathProblem value, $Res Function(_MathProblem) _then) = __$MathProblemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, DateTime createdAt, DateTime updatedAt, List<String>? imagePaths, String? scribbleData, List<AiFeedback> aiFeedbacks, ProblemStatus status, List<String> tags
});




}
/// @nodoc
class __$MathProblemCopyWithImpl<$Res>
    implements _$MathProblemCopyWith<$Res> {
  __$MathProblemCopyWithImpl(this._self, this._then);

  final _MathProblem _self;
  final $Res Function(_MathProblem) _then;

/// Create a copy of MathProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? imagePaths = freezed,Object? scribbleData = freezed,Object? aiFeedbacks = null,Object? status = null,Object? tags = null,}) {
  return _then(_MathProblem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,imagePaths: freezed == imagePaths ? _self._imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>?,scribbleData: freezed == scribbleData ? _self.scribbleData : scribbleData // ignore: cast_nullable_to_non_nullable
as String?,aiFeedbacks: null == aiFeedbacks ? _self._aiFeedbacks : aiFeedbacks // ignore: cast_nullable_to_non_nullable
as List<AiFeedback>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProblemStatus,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
