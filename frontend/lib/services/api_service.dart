import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:ai_math_helper/data/notebook/data/ai_feedback.dart';
import 'package:ai_math_helper/data/notebook/data/problem_status.dart';

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
        final data = json.decode(utf8.decode(response.bodyBytes));
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
      debugPrint('Updating profile with body: $body');

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
      const supportedFormats = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
      ];

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
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('Failed to get token status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting token status: $e');
      return null;
    }
  }

  // Notebook Management
  static Future<List<Map<String, dynamic>>?> getNotebooks() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/notebooks'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        debugPrint('Failed to get notebooks: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting notebooks: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getNotebook(String notebookUid) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/notebooks/$notebookUid'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'];
      } else {
        debugPrint('Failed to get notebook: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting notebook: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createNotebook({
    required String title,
    String? description,
    String? coverColor,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final body = {
        'title': title,
        if (description != null) 'description': description,
        if (coverColor != null) 'coverColor': coverColor,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/notebooks'),
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'];
      } else {
        debugPrint('Failed to create notebook: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating notebook: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateNotebook({
    required String notebookUid,
    String? title,
    String? description,
    String? coverColor,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (coverColor != null) body['coverColor'] = coverColor;

      final response = await http.put(
        Uri.parse('$baseUrl/api/notebooks/$notebookUid'),
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['data'];
      } else {
        debugPrint('Failed to update notebook: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error updating notebook: $e');
      return null;
    }
  }

  static Future<bool> deleteNotebook(String notebookUid) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/notebooks/$notebookUid'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        debugPrint('Notebook deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete notebook: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting notebook: $e');
      return false;
    }
  }

  // Problem Image Management
  static Future<List<Map<String, dynamic>>?> uploadProblemImages(
    List<XFile> imageFiles,
    String problemId,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      if (imageFiles.isEmpty) {
        return [];
      }

      if (imageFiles.length > 10) {
        debugPrint('Too many images: ${imageFiles.length} (max 10)');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/problems/images/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add problemId field
      request.fields['problemId'] = problemId;

      // Add each image file
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];

        // Validate file size (10MB limit as per backend)
        final file = File(imageFile.path);
        final fileSize = await file.length();
        const maxSizeBytes = 10 * 1024 * 1024; // 10MB

        if (fileSize > maxSizeBytes) {
          debugPrint(
            'File too large: ${fileSize / (1024 * 1024)}MB (max 10MB)',
          );
          return null;
        }

        // Detect MIME type from file
        String? mimeType = lookupMimeType(imageFile.path);

        // Validate and set MIME type for supported formats
        const supportedFormats = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'image/webp',
        ];

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
            case 'heic':
            case 'heif':
              mimeType = 'image/heic';
              break;
            default:
              debugPrint('Unsupported image format: $extension');
              return null;
          }
        }

        // Add the image file with correct MIME type
        final multipartFile = await http.MultipartFile.fromPath(
          'images', // Backend expects 'images' field name
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      debugPrint('Uploading ${imageFiles.length} problem images');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        debugPrint('Problem images uploaded successfully');
        final images = List<Map<String, dynamic>>.from(data['data']['images']);
        return images;
      } else {
        debugPrint('Failed to upload problem images: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading problem images: $e');
      return null;
    }
  }

  // Math Problem Management
  static Future<Map<String, dynamic>?> createProblem({
    required String notebookUid,
    String? title,
    String? description,
    List<XFile>? imageFiles,
    String? scribbleData,
    List<String>? tags,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        debugPrint('Error: No authentication token available');
        return null;
      }

      // First create the problem without images
      final body = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (scribbleData != null) 'scribbleData': scribbleData,
        if (tags != null) 'tags': tags,
      };

      debugPrint('Creating problem with ${title ?? 'no title'}');
      final response = await http.post(
        Uri.parse('$baseUrl/api/notebooks/$notebookUid/problems'),
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final problemData = data['data'];
        debugPrint('Problem created successfully: ${problemData['uid']}');

        // Upload images if provided
        if (imageFiles != null && imageFiles.isNotEmpty) {
          debugPrint('Uploading ${imageFiles.length} images for problem');
          final uploadedImages = await uploadProblemImages(
            imageFiles,
            problemData['uid'],
          );
          if (uploadedImages != null) {
            // Add uploaded images to the problem data
            problemData['images'] = uploadedImages;
            debugPrint('Images uploaded successfully');
          } else {
            debugPrint(
              'Warning: Failed to upload images, but problem was created',
            );
            // Problem was created successfully, but images failed
            // Still return the problem data, but with empty images
            problemData['images'] = [];
          }
        } else {
          // No images to upload
          problemData['images'] = [];
        }

        return problemData;
      } else {
        debugPrint('Failed to create problem: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating problem: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProblem({
    required String problemUid,
    String? title,
    String? description,
    List<XFile>? newImageFiles,
    String? scribbleData,
    String? status,
    List<String>? tags,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      // Update the problem (without images)
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (scribbleData != null) body['scribbleData'] = scribbleData;
      if (status != null) body['status'] = status;
      if (tags != null) body['tags'] = tags;

      final response = await http.put(
        Uri.parse('$baseUrl/api/problems/$problemUid'),
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final problemData = data['data'];

        // Upload new images if provided
        if (newImageFiles != null && newImageFiles.isNotEmpty) {
          final uploadedImages = await uploadProblemImages(
            newImageFiles,
            problemUid,
          );
          if (uploadedImages != null) {
            // Add new images to existing ones
            final existingImages = List<Map<String, dynamic>>.from(
              problemData['images'] ?? [],
            );
            problemData['images'] = [...existingImages, ...uploadedImages];
          }
        }

        return problemData;
      } else {
        debugPrint('Failed to update problem: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error updating problem: $e');
      return null;
    }
  }

  static Future<bool> deleteProblem(String problemUid) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/problems/$problemUid'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        debugPrint('Problem deleted successfully');
        return true;
      } else {
        debugPrint('Failed to delete problem: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting problem: $e');
      return false;
    }
  }

  // AI Feedback Methods
  static Future<AiFeedback?> generateAiFeedback(
    String problemUid,
    Uint8List canvasImageBytes, {
    String? customMessage,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/problems/$problemUid/feedback/generate'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add canvas image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          canvasImageBytes,
          filename: 'canvas.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Add custom message if provided
      if (customMessage != null) {
        request.fields['customMessage'] = customMessage;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final feedbackData = data['data'];

        return AiFeedback(
          id: feedbackData['id'],
          message: feedbackData['message'],
          timestamp: DateTime.parse(feedbackData['timestamp']),
          type: _parseFeedbackType(feedbackData['type']),
        );
      } else {
        debugPrint('Failed to generate AI feedback: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating AI feedback: $e');
      return null;
    }
  }

  // Stream AI feedback generation in real-time
  static Stream<Map<String, dynamic>> streamAiFeedback(
    String problemUid,
    Uint8List canvasImageBytes, {
    String? customMessage,
  }) async* {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        yield {'type': 'error', 'error': 'No authentication token available'};
        return;
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/problems/$problemUid/feedback/stream'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add canvas image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          canvasImageBytes,
          filename: 'canvas.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Add custom message if provided
      if (customMessage != null) {
        request.fields['customMessage'] = customMessage;
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        yield {
          'type': 'error',
          'error': 'Failed to start streaming: ${streamedResponse.statusCode}',
        };
        return;
      }

      // Parse Server-Sent Events stream
      await for (final chunk in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final jsonData = chunk.substring(6); // Remove 'data: ' prefix
          if (jsonData.trim().isNotEmpty) {
            try {
              final data = json.decode(jsonData);
              yield data;
            } catch (e) {
              debugPrint('Error parsing SSE data: $e');
              yield {
                'type': 'error',
                'error': 'Failed to parse streaming data',
              };
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in streaming AI feedback: $e');
      yield {'type': 'error', 'error': 'Failed to stream AI feedback: $e'};
    }
  }

  static Future<List<AiFeedback>?> getProblemFeedbacks(
    String problemUid,
  ) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/problems/$problemUid/feedbacks'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final feedbacksList = data['data'] as List;

        return feedbacksList
            .map(
              (feedbackData) => AiFeedback(
                id: feedbackData['id'],
                message: feedbackData['message'],
                timestamp: DateTime.parse(feedbackData['timestamp']),
                type: _parseFeedbackType(feedbackData['type']),
              ),
            )
            .toList();
      } else {
        debugPrint('Failed to get problem feedbacks: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting problem feedbacks: $e');
      return null;
    }
  }

  static FeedbackType _parseFeedbackType(String typeString) {
    switch (typeString) {
      case 'correction':
        return FeedbackType.correction;
      case 'explanation':
        return FeedbackType.explanation;
      case 'encouragement':
        return FeedbackType.encouragement;
      case 'suggestion':
      default:
        return FeedbackType.suggestion;
    }
  }
}
