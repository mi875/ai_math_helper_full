import 'dart:io';
import 'package:ai_math_helper/data/user/data/user_profile.dart';
import 'package:ai_math_helper/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    UserProfile? profile,
    @Default([]) List<GradeOption> gradeOptions,
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? errorMessage,
  }) = _ProfileState;
}

@riverpod
class ProfileModel extends _$ProfileModel {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final profileData = await ApiService.getUserProfile();
      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        state = state.copyWith(
          profile: profile,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load profile',
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading profile: $e',
      );
    }
  }

  Future<void> loadGradeOptions() async {
    // Always use default grade options for now
    state = state.copyWith(gradeOptions: _getDefaultGradeOptions());
  }

  List<GradeOption> _getDefaultGradeOptions() {
    return [
      const GradeOption(
        key: 'junior_high_1',
        displayName: '中学1年生',
        category: 'junior_high',
      ),
      const GradeOption(
        key: 'junior_high_2',
        displayName: '中学2年生',
        category: 'junior_high',
      ),
      const GradeOption(
        key: 'junior_high_3',
        displayName: '中学3年生',
        category: 'junior_high',
      ),
      const GradeOption(
        key: 'senior_high_1',
        displayName: '高校1年生',
        category: 'senior_high',
      ),
      const GradeOption(
        key: 'senior_high_2',
        displayName: '高校2年生',
        category: 'senior_high',
      ),
      const GradeOption(
        key: 'senior_high_3',
        displayName: '高校3年生',
        category: 'senior_high',
      ),
      const GradeOption(
        key: 'kosen_1',
        displayName: '高専1年生',
        category: 'kosen',
      ),
      const GradeOption(
        key: 'kosen_2',
        displayName: '高専2年生',
        category: 'kosen',
      ),
      const GradeOption(
        key: 'kosen_3',
        displayName: '高専3年生',
        category: 'kosen',
      ),
      const GradeOption(
        key: 'kosen_4',
        displayName: '高専4年生',
        category: 'kosen',
      ),
      const GradeOption(
        key: 'kosen_5',
        displayName: '高専5年生',
        category: 'kosen',
      ),
    ];
  }

  Future<bool> updateProfile({
    String? displayName,
    String? grade,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final success = await ApiService.updateUserProfile(
        displayName: displayName,
        grade: grade,
      );

      if (success) {
        // Reload profile to get updated data
        await loadProfile();
        state = state.copyWith(isUpdating: false);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'Failed to update profile',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Error updating profile: $e',
      );
      return false;
    }
  }

  Future<bool> checkRegistrationStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await ApiService.checkRegistrationStatus();
      if (response != null) {
        final needsRegistration = response['needsRegistration'] ?? false;
        state = state.copyWith(isLoading: false);
        return needsRegistration;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to check registration status',
        );
        return true; // Assume needs registration if we can't check
      }
    } catch (e) {
      debugPrint('Error checking registration status: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error checking registration status: $e',
      );
      return true; // Assume needs registration if error occurs
    }
  }

  Future<bool> completeRegistration({
    required String displayName,
    required String grade,
  }) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final response = await ApiService.completeUserRegistration(
        displayName: displayName,
        grade: grade,
      );

      if (response != null && response['success'] == true) {
        // Update profile with the returned data
        if (response['profile'] != null) {
          final profile = UserProfile.fromJson(response['profile']);
          state = state.copyWith(
            profile: profile,
            isUpdating: false,
          );
        }
        return true;
      } else {
        String errorMessage = 'Failed to complete registration';
        if (response != null && response['error'] != null) {
          errorMessage = response['error'];
        }
        state = state.copyWith(
          isUpdating: false,
          errorMessage: errorMessage,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error completing registration: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Error completing registration: $e',
      );
      return false;
    }
  }

  Future<bool> uploadProfileImage(XFile imageFile) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      // Pre-validate file size
      final file = File(imageFile.path);
      final fileSize = await file.length();
      const maxSizeBytes = 5 * 1024 * 1024; // 5MB
      
      if (fileSize > maxSizeBytes) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'Image file is too large. Maximum size is 5MB.',
        );
        return false;
      }

      final imageData = await ApiService.uploadProfileImage(imageFile);
      if (imageData != null) {
        // Reload profile to get updated image URLs
        await loadProfile();
        state = state.copyWith(isUpdating: false);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'Failed to upload profile image. Please check the file format and size.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      String errorMessage = 'Error uploading profile image';
      
      if (e.toString().contains('format')) {
        errorMessage = 'Unsupported image format. Please use JPEG, PNG, GIF, or WebP.';
      } else if (e.toString().contains('size')) {
        errorMessage = 'Image file is too large. Maximum size is 5MB.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      }
      
      state = state.copyWith(
        isUpdating: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> deleteProfileImage() async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final success = await ApiService.deleteProfileImage();
      if (success) {
        // Reload profile to get updated data
        await loadProfile();
        state = state.copyWith(isUpdating: false);
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'Failed to delete profile image',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Error deleting profile image: $e',
      );
      return false;
    }
  }

  Future<TokenStatus?> getTokenStatus() async {
    try {
      final tokenData = await ApiService.getTokenStatus();
      if (tokenData != null) {
        return TokenStatus.fromJson(tokenData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting token status: $e');
      return null;
    }
  }
}