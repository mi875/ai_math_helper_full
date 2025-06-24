import 'dart:developer';
import 'package:ai_math_helper/data/user/data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_model.g.dart';

@riverpod
class AuthModel extends _$AuthModel {
  @override
  AuthData build() {
    // Add listener for auth state changes
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    return const AuthData();
  }

  void _onAuthStateChanged(User? user) {
    state = state.copyWith(user: user);
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Begin Google sign in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If user canceled the sign-in
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> getJwtToken() async {
    try {
      final token = await state.user?.getIdTokenResult();
      log(" =======> " + (token?.token ?? ""));
    } catch (e) {}
  }
}
