import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000'; // Update for production

  static Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // User Profile Management
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['profile'];
      } else {
        debugPrint('Failed to get user profile: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile({
    String? displayName,
    String? grade,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (grade != null) body['grade'] = grade;

      final response = await http.put(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('Profile updated successfully');
        return true;
      } else {
        debugPrint('Failed to update profile: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Profile Image Management
  static Future<Map<String, dynamic>?> uploadProfileImage(
    XFile imageFile,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      // Validate file size (5MB limit as per API guide)
      final file = File(imageFile.path);
      final fileSize = await file.length();
      const maxSizeBytes = 5 * 1024 * 1024; // 5MB
      
      if (fileSize > maxSizeBytes) {
        debugPrint('File too large: ${fileSize / (1024 * 1024)}MB (max 5MB)');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/user/profile/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Detect MIME type from file
      String? mimeType = lookupMimeType(imageFile.path);
      
      // Validate and set MIME type for supported formats
      const supportedFormats = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
      
      if (mimeType == null || !supportedFormats.contains(mimeType)) {
        final extension = imageFile.path.toLowerCase().split('.').last;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            debugPrint('Unsupported image format: $extension');
            return null;
        }
      }
      
      // Final validation that we have a supported format
      if (!supportedFormats.contains(mimeType)) {
        debugPrint('Invalid MIME type detected: $mimeType');
        return null;
      }

      // Add the image file with correct MIME type
      final multipartFile = await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      debugPrint('Uploading image with MIME type: $mimeType');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Profile image uploaded successfully');
        return data['data'];
      } else {
        debugPrint('Failed to upload profile image: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  static Future<bool> deleteProfileImage() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/user/profile/image'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        debugPrint('Profile image deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete profile image: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      return false;
    }
  }

  // Grade Options
  static Future<List<Map<String, dynamic>>?> getGradeOptions() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/grades'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['grades']);
      } else {
        debugPrint('Failed to get grade options: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting grade options: $e');
      return null;
    }
  }

  // Token Management
  static Future<Map<String, dynamic>?> getTokenStatus() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/tokens/status'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get token status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting token status: $e');
      return null;
    }
  }
}
