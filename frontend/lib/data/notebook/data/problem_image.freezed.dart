// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProblemImage {

 int get id; String get uid; String get originalFilename; String get filename; String get fileUrl; String get mimeType; int get fileSize; int? get width; int? get height; int get displayOrder; DateTime get createdAt;
/// Create a copy of ProblemImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProblemImageCopyWith<ProblemImage> get copyWith => _$ProblemImageCopyWithImpl<ProblemImage>(this as ProblemImage, _$identity);

  /// Serializes this ProblemImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProblemImage&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.originalFilename, originalFilename) || other.originalFilename == originalFilename)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,originalFilename,filename,fileUrl,mimeType,fileSize,width,height,displayOrder,createdAt);

@override
String toString() {
  return 'ProblemImage(id: $id, uid: $uid, originalFilename: $originalFilename, filename: $filename, fileUrl: $fileUrl, mimeType: $mimeType, fileSize: $fileSize, width: $width, height: $height, displayOrder: $displayOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProblemImageCopyWith<$Res>  {
  factory $ProblemImageCopyWith(ProblemImage value, $Res Function(ProblemImage) _then) = _$ProblemImageCopyWithImpl;
@useResult
$Res call({
 int id, String uid, String originalFilename, String filename, String fileUrl, String mimeType, int fileSize, int? width, int? height, int displayOrder, DateTime createdAt
});




}
/// @nodoc
class _$ProblemImageCopyWithImpl<$Res>
    implements $ProblemImageCopyWith<$Res> {
  _$ProblemImageCopyWithImpl(this._self, this._then);

  final ProblemImage _self;
  final $Res Function(ProblemImage) _then;

/// Create a copy of ProblemImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? originalFilename = null,Object? filename = null,Object? fileUrl = null,Object? mimeType = null,Object? fileSize = null,Object? width = freezed,Object? height = freezed,Object? displayOrder = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,originalFilename: null == originalFilename ? _self.originalFilename : originalFilename // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ProblemImage implements ProblemImage {
  const _ProblemImage({required this.id, required this.uid, required this.originalFilename, required this.filename, required this.fileUrl, required this.mimeType, required this.fileSize, this.width, this.height, required this.displayOrder, required this.createdAt});
  factory _ProblemImage.fromJson(Map<String, dynamic> json) => _$ProblemImageFromJson(json);

@override final  int id;
@override final  String uid;
@override final  String originalFilename;
@override final  String filename;
@override final  String fileUrl;
@override final  String mimeType;
@override final  int fileSize;
@override final  int? width;
@override final  int? height;
@override final  int displayOrder;
@override final  DateTime createdAt;

/// Create a copy of ProblemImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProblemImageCopyWith<_ProblemImage> get copyWith => __$ProblemImageCopyWithImpl<_ProblemImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProblemImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProblemImage&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.originalFilename, originalFilename) || other.originalFilename == originalFilename)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,originalFilename,filename,fileUrl,mimeType,fileSize,width,height,displayOrder,createdAt);

@override
String toString() {
  return 'ProblemImage(id: $id, uid: $uid, originalFilename: $originalFilename, filename: $filename, fileUrl: $fileUrl, mimeType: $mimeType, fileSize: $fileSize, width: $width, height: $height, displayOrder: $displayOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProblemImageCopyWith<$Res> implements $ProblemImageCopyWith<$Res> {
  factory _$ProblemImageCopyWith(_ProblemImage value, $Res Function(_ProblemImage) _then) = __$ProblemImageCopyWithImpl;
@override @useResult
$Res call({
 int id, String uid, String originalFilename, String filename, String fileUrl, String mimeType, int fileSize, int? width, int? height, int displayOrder, DateTime createdAt
});




}
/// @nodoc
class __$ProblemImageCopyWithImpl<$Res>
    implements _$ProblemImageCopyWith<$Res> {
  __$ProblemImageCopyWithImpl(this._self, this._then);

  final _ProblemImage _self;
  final $Res Function(_ProblemImage) _then;

/// Create a copy of ProblemImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? originalFilename = null,Object? filename = null,Object? fileUrl = null,Object? mimeType = null,Object? fileSize = null,Object? width = freezed,Object? height = freezed,Object? displayOrder = null,Object? createdAt = null,}) {
  return _then(_ProblemImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,originalFilename: null == originalFilename ? _self.originalFilename : originalFilename // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
