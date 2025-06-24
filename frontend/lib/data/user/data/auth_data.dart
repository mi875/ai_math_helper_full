import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_data.freezed.dart';

@freezed
abstract class AuthData with _$AuthData {
  const factory AuthData({
    User? user,
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
  }) = _AuthData;
}
