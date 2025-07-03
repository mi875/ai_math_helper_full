// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notebook_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Notebook {

 String get id; String get title; String? get description; DateTime get createdAt; DateTime get updatedAt; List<MathProblem> get problems; String get coverColor;
/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotebookCopyWith<Notebook> get copyWith => _$NotebookCopyWithImpl<Notebook>(this as Notebook, _$identity);

  /// Serializes this Notebook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notebook&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.problems, problems)&&(identical(other.coverColor, coverColor) || other.coverColor == coverColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,createdAt,updatedAt,const DeepCollectionEquality().hash(problems),coverColor);

@override
String toString() {
  return 'Notebook(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, problems: $problems, coverColor: $coverColor)';
}


}

/// @nodoc
abstract mixin class $NotebookCopyWith<$Res>  {
  factory $NotebookCopyWith(Notebook value, $Res Function(Notebook) _then) = _$NotebookCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, DateTime createdAt, DateTime updatedAt, List<MathProblem> problems, String coverColor
});




}
/// @nodoc
class _$NotebookCopyWithImpl<$Res>
    implements $NotebookCopyWith<$Res> {
  _$NotebookCopyWithImpl(this._self, this._then);

  final Notebook _self;
  final $Res Function(Notebook) _then;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? problems = null,Object? coverColor = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as List<MathProblem>,coverColor: null == coverColor ? _self.coverColor : coverColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Notebook].
extension NotebookPatterns on Notebook {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Notebook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Notebook value)  $default,){
final _that = this;
switch (_that) {
case _Notebook():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Notebook value)?  $default,){
final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<MathProblem> problems,  String coverColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.createdAt,_that.updatedAt,_that.problems,_that.coverColor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<MathProblem> problems,  String coverColor)  $default,) {final _that = this;
switch (_that) {
case _Notebook():
return $default(_that.id,_that.title,_that.description,_that.createdAt,_that.updatedAt,_that.problems,_that.coverColor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  DateTime createdAt,  DateTime updatedAt,  List<MathProblem> problems,  String coverColor)?  $default,) {final _that = this;
switch (_that) {
case _Notebook() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.createdAt,_that.updatedAt,_that.problems,_that.coverColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Notebook implements Notebook {
  const _Notebook({required this.id, required this.title, this.description, required this.createdAt, required this.updatedAt, final  List<MathProblem> problems = const [], this.coverColor = 'default'}): _problems = problems;
  factory _Notebook.fromJson(Map<String, dynamic> json) => _$NotebookFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<MathProblem> _problems;
@override@JsonKey() List<MathProblem> get problems {
  if (_problems is EqualUnmodifiableListView) return _problems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_problems);
}

@override@JsonKey() final  String coverColor;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotebookCopyWith<_Notebook> get copyWith => __$NotebookCopyWithImpl<_Notebook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotebookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Notebook&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._problems, _problems)&&(identical(other.coverColor, coverColor) || other.coverColor == coverColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,createdAt,updatedAt,const DeepCollectionEquality().hash(_problems),coverColor);

@override
String toString() {
  return 'Notebook(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, problems: $problems, coverColor: $coverColor)';
}


}

/// @nodoc
abstract mixin class _$NotebookCopyWith<$Res> implements $NotebookCopyWith<$Res> {
  factory _$NotebookCopyWith(_Notebook value, $Res Function(_Notebook) _then) = __$NotebookCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, DateTime createdAt, DateTime updatedAt, List<MathProblem> problems, String coverColor
});




}
/// @nodoc
class __$NotebookCopyWithImpl<$Res>
    implements _$NotebookCopyWith<$Res> {
  __$NotebookCopyWithImpl(this._self, this._then);

  final _Notebook _self;
  final $Res Function(_Notebook) _then;

/// Create a copy of Notebook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? createdAt = null,Object? updatedAt = null,Object? problems = null,Object? coverColor = null,}) {
  return _then(_Notebook(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,problems: null == problems ? _self._problems : problems // ignore: cast_nullable_to_non_nullable
as List<MathProblem>,coverColor: null == coverColor ? _self.coverColor : coverColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotebookData {

 List<Notebook> get notebooks; bool get isLoading; String? get errorMessage;
/// Create a copy of NotebookData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotebookDataCopyWith<NotebookData> get copyWith => _$NotebookDataCopyWithImpl<NotebookData>(this as NotebookData, _$identity);

  /// Serializes this NotebookData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotebookData&&const DeepCollectionEquality().equals(other.notebooks, notebooks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(notebooks),isLoading,errorMessage);

@override
String toString() {
  return 'NotebookData(notebooks: $notebooks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $NotebookDataCopyWith<$Res>  {
  factory $NotebookDataCopyWith(NotebookData value, $Res Function(NotebookData) _then) = _$NotebookDataCopyWithImpl;
@useResult
$Res call({
 List<Notebook> notebooks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$NotebookDataCopyWithImpl<$Res>
    implements $NotebookDataCopyWith<$Res> {
  _$NotebookDataCopyWithImpl(this._self, this._then);

  final NotebookData _self;
  final $Res Function(NotebookData) _then;

/// Create a copy of NotebookData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notebooks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
notebooks: null == notebooks ? _self.notebooks : notebooks // ignore: cast_nullable_to_non_nullable
as List<Notebook>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotebookData].
extension NotebookDataPatterns on NotebookData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotebookData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotebookData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotebookData value)  $default,){
final _that = this;
switch (_that) {
case _NotebookData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotebookData value)?  $default,){
final _that = this;
switch (_that) {
case _NotebookData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Notebook> notebooks,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotebookData() when $default != null:
return $default(_that.notebooks,_that.isLoading,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Notebook> notebooks,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _NotebookData():
return $default(_that.notebooks,_that.isLoading,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Notebook> notebooks,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _NotebookData() when $default != null:
return $default(_that.notebooks,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotebookData implements NotebookData {
  const _NotebookData({final  List<Notebook> notebooks = const [], this.isLoading = false, this.errorMessage}): _notebooks = notebooks;
  factory _NotebookData.fromJson(Map<String, dynamic> json) => _$NotebookDataFromJson(json);

 final  List<Notebook> _notebooks;
@override@JsonKey() List<Notebook> get notebooks {
  if (_notebooks is EqualUnmodifiableListView) return _notebooks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notebooks);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of NotebookData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotebookDataCopyWith<_NotebookData> get copyWith => __$NotebookDataCopyWithImpl<_NotebookData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotebookDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotebookData&&const DeepCollectionEquality().equals(other._notebooks, _notebooks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notebooks),isLoading,errorMessage);

@override
String toString() {
  return 'NotebookData(notebooks: $notebooks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$NotebookDataCopyWith<$Res> implements $NotebookDataCopyWith<$Res> {
  factory _$NotebookDataCopyWith(_NotebookData value, $Res Function(_NotebookData) _then) = __$NotebookDataCopyWithImpl;
@override @useResult
$Res call({
 List<Notebook> notebooks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$NotebookDataCopyWithImpl<$Res>
    implements _$NotebookDataCopyWith<$Res> {
  __$NotebookDataCopyWithImpl(this._self, this._then);

  final _NotebookData _self;
  final $Res Function(_NotebookData) _then;

/// Create a copy of NotebookData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notebooks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_NotebookData(
notebooks: null == notebooks ? _self._notebooks : notebooks // ignore: cast_nullable_to_non_nullable
as List<Notebook>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
