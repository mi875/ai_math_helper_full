// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

 String get id; String get message; DateTime get timestamp; MessageSender get sender; String? get feedbackType;// For AI messages, stores the original feedback type
 String? get threadId;// Conversation thread ID for memory context
 String? get resourceId;// Resource ID for memory scoping
 ConversationState get state;// Message state for streaming
 bool? get isFromMemory;// Whether this message was loaded from conversation history
 int? get tokensConsumed;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.feedbackType, feedbackType) || other.feedbackType == feedbackType)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isFromMemory, isFromMemory) || other.isFromMemory == isFromMemory)&&(identical(other.tokensConsumed, tokensConsumed) || other.tokensConsumed == tokensConsumed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,timestamp,sender,feedbackType,threadId,resourceId,state,isFromMemory,tokensConsumed);

@override
String toString() {
  return 'ChatMessage(id: $id, message: $message, timestamp: $timestamp, sender: $sender, feedbackType: $feedbackType, threadId: $threadId, resourceId: $resourceId, state: $state, isFromMemory: $isFromMemory, tokensConsumed: $tokensConsumed)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String message, DateTime timestamp, MessageSender sender, String? feedbackType, String? threadId, String? resourceId, ConversationState state, bool? isFromMemory, int? tokensConsumed
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,Object? timestamp = null,Object? sender = null,Object? feedbackType = freezed,Object? threadId = freezed,Object? resourceId = freezed,Object? state = null,Object? isFromMemory = freezed,Object? tokensConsumed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,feedbackType: freezed == feedbackType ? _self.feedbackType : feedbackType // ignore: cast_nullable_to_non_nullable
as String?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,resourceId: freezed == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConversationState,isFromMemory: freezed == isFromMemory ? _self.isFromMemory : isFromMemory // ignore: cast_nullable_to_non_nullable
as bool?,tokensConsumed: freezed == tokensConsumed ? _self.tokensConsumed : tokensConsumed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String message,  DateTime timestamp,  MessageSender sender,  String? feedbackType,  String? threadId,  String? resourceId,  ConversationState state,  bool? isFromMemory,  int? tokensConsumed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.message,_that.timestamp,_that.sender,_that.feedbackType,_that.threadId,_that.resourceId,_that.state,_that.isFromMemory,_that.tokensConsumed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String message,  DateTime timestamp,  MessageSender sender,  String? feedbackType,  String? threadId,  String? resourceId,  ConversationState state,  bool? isFromMemory,  int? tokensConsumed)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.message,_that.timestamp,_that.sender,_that.feedbackType,_that.threadId,_that.resourceId,_that.state,_that.isFromMemory,_that.tokensConsumed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String message,  DateTime timestamp,  MessageSender sender,  String? feedbackType,  String? threadId,  String? resourceId,  ConversationState state,  bool? isFromMemory,  int? tokensConsumed)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.message,_that.timestamp,_that.sender,_that.feedbackType,_that.threadId,_that.resourceId,_that.state,_that.isFromMemory,_that.tokensConsumed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.message, required this.timestamp, this.sender = MessageSender.user, this.feedbackType, this.threadId, this.resourceId, this.state = ConversationState.normal, this.isFromMemory, this.tokensConsumed});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String id;
@override final  String message;
@override final  DateTime timestamp;
@override@JsonKey() final  MessageSender sender;
@override final  String? feedbackType;
// For AI messages, stores the original feedback type
@override final  String? threadId;
// Conversation thread ID for memory context
@override final  String? resourceId;
// Resource ID for memory scoping
@override@JsonKey() final  ConversationState state;
// Message state for streaming
@override final  bool? isFromMemory;
// Whether this message was loaded from conversation history
@override final  int? tokensConsumed;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.feedbackType, feedbackType) || other.feedbackType == feedbackType)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId)&&(identical(other.state, state) || other.state == state)&&(identical(other.isFromMemory, isFromMemory) || other.isFromMemory == isFromMemory)&&(identical(other.tokensConsumed, tokensConsumed) || other.tokensConsumed == tokensConsumed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,message,timestamp,sender,feedbackType,threadId,resourceId,state,isFromMemory,tokensConsumed);

@override
String toString() {
  return 'ChatMessage(id: $id, message: $message, timestamp: $timestamp, sender: $sender, feedbackType: $feedbackType, threadId: $threadId, resourceId: $resourceId, state: $state, isFromMemory: $isFromMemory, tokensConsumed: $tokensConsumed)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String message, DateTime timestamp, MessageSender sender, String? feedbackType, String? threadId, String? resourceId, ConversationState state, bool? isFromMemory, int? tokensConsumed
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,Object? timestamp = null,Object? sender = null,Object? feedbackType = freezed,Object? threadId = freezed,Object? resourceId = freezed,Object? state = null,Object? isFromMemory = freezed,Object? tokensConsumed = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,feedbackType: freezed == feedbackType ? _self.feedbackType : feedbackType // ignore: cast_nullable_to_non_nullable
as String?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,resourceId: freezed == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConversationState,isFromMemory: freezed == isFromMemory ? _self.isFromMemory : isFromMemory // ignore: cast_nullable_to_non_nullable
as bool?,tokensConsumed: freezed == tokensConsumed ? _self.tokensConsumed : tokensConsumed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
