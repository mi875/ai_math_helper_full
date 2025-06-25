import 'dart:io';
import 'package:ai_math_helper/data/notebook/data/notebook_data.dart';
import 'package:ai_math_helper/data/notebook/data/math_problem.dart';
import 'package:ai_math_helper/data/notebook/data/problem_image.dart';
import 'package:ai_math_helper/data/notebook/data/ai_feedback.dart';
import 'package:ai_math_helper/data/notebook/data/problem_status.dart';
import 'package:ai_math_helper/services/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_helper;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

part 'notebook_model.g.dart';

@riverpod
class NotebookModel extends _$NotebookModel {
  static const _uuid = Uuid();

  @override
  NotebookData build() {
    // Initialize with empty state, notebooks will be loaded from API
    return const NotebookData();
  }

  // Load notebooks from API
  Future<void> loadNotebooks() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final notebooksData = await ApiService.getNotebooks();
      if (notebooksData != null) {
        final notebooks = notebooksData.map((data) => _parseNotebookFromApi(data)).toList();
        state = state.copyWith(
          notebooks: notebooks,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load notebooks',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading notebooks: $e',
      );
    }
  }

  // Parse notebook data from API response
  Notebook _parseNotebookFromApi(Map<String, dynamic> data) {
    return Notebook(
      id: data['uid'] ?? data['id'].toString(),
      title: data['title'] ?? '',
      description: data['description'],
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      problems: (data['problems'] as List<dynamic>?)?.map((problemData) => 
        _parseProblemFromApi(problemData as Map<String, dynamic>)
      ).toList() ?? [],
      coverColor: data['coverColor'] ?? 'default',
    );
  }

  // Parse problem data from API response
  MathProblem _parseProblemFromApi(Map<String, dynamic> data) {
    // Parse images from the new API structure
    final List<ProblemImage> images = [];
    if (data['images'] is List) {
      for (final imageData in data['images'] as List) {
        if (imageData is Map<String, dynamic>) {
          images.add(ProblemImage(
            id: imageData['id'] ?? 0,
            uid: imageData['uid'] ?? '',
            originalFilename: imageData['originalFilename'] ?? '',
            filename: imageData['filename'] ?? '',
            fileUrl: imageData['fileUrl'] ?? '',
            mimeType: imageData['mimeType'] ?? '',
            fileSize: imageData['fileSize'] ?? 0,
            width: imageData['width'],
            height: imageData['height'],
            displayOrder: imageData['displayOrder'] ?? 0,
            createdAt: DateTime.tryParse(imageData['createdAt'] ?? '') ?? DateTime.now(),
          ));
        }
      }
    }
    
    return MathProblem(
      id: data['uid'] ?? data['id'].toString(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      image: images.isNotEmpty ? images.first : null,
      scribbleData: data['scribbleData'],
      status: _parseStatusFromString(data['status'] ?? 'unsolved'),
      tags: List<String>.from(data['tags'] ?? []),
      aiFeedbacks: [], // AI feedbacks would be loaded separately
    );
  }

  // Parse status from string
  ProblemStatus _parseStatusFromString(String status) {
    switch (status) {
      case 'in_progress':
        return ProblemStatus.inProgress;
      case 'solved':
        return ProblemStatus.solved;
      case 'needs_help':
        return ProblemStatus.needsHelp;
      default:
        return ProblemStatus.unsolved;
    }
  }

  // Convert status to string
  String _statusToString(ProblemStatus status) {
    switch (status) {
      case ProblemStatus.inProgress:
        return 'in_progress';
      case ProblemStatus.solved:
        return 'solved';
      case ProblemStatus.needsHelp:
        return 'needs_help';
      default:
        return 'unsolved';
    }
  }

  Future<Notebook?> createNotebook({
    required String title,
    String? description,
    String coverColor = 'default',
  }) async {
    try {
      final notebookData = await ApiService.createNotebook(
        title: title,
        description: description,
        coverColor: coverColor,
      );

      if (notebookData != null) {
        final notebook = _parseNotebookFromApi(notebookData);
        final updatedNotebooks = [...state.notebooks, notebook];
        state = state.copyWith(notebooks: updatedNotebooks);
        return notebook;
      }
      return null;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create notebook: $e');
      return null;
    }
  }

  Future<bool> updateNotebook(String notebookId, {
    String? title,
    String? description,
    String? coverColor,
  }) async {
    try {
      final updatedData = await ApiService.updateNotebook(
        notebookUid: notebookId,
        title: title,
        description: description,
        coverColor: coverColor,
      );

      if (updatedData != null) {
        final notebooks = state.notebooks.map((notebook) {
          if (notebook.id == notebookId) {
            return _parseNotebookFromApi(updatedData);
          }
          return notebook;
        }).toList();

        state = state.copyWith(notebooks: notebooks);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update notebook: $e');
      return false;
    }
  }

  Future<bool> deleteNotebook(String notebookId) async {
    try {
      final success = await ApiService.deleteNotebook(notebookId);
      
      if (success) {
        final updatedNotebooks = state.notebooks
            .where((notebook) => notebook.id != notebookId)
            .toList();
        
        state = state.copyWith(notebooks: updatedNotebooks);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete notebook: $e');
      return false;
    }
  }

  Future<MathProblem?> addProblemToNotebook({
    required String notebookId,
    List<XFile>? imageFiles,
    String? scribbleData,
    List<String>? tags,
  }) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final problemData = await ApiService.createProblem(
        notebookUid: notebookId,
        imageFiles: imageFiles,
        scribbleData: scribbleData,
        tags: tags,
      );

      if (problemData != null) {
        // Instead of just updating local state, reload the complete notebook from server
        // to ensure we have accurate data including properly uploaded images
        await _reloadNotebook(notebookId);
        
        final problem = _parseProblemFromApi(problemData);
        state = state.copyWith(isLoading: false);
        return problem;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create problem. Please try again.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create problem: $e',
      );
      return null;
    }
  }

  // Helper method to reload a specific notebook from the server
  Future<void> _reloadNotebook(String notebookId) async {
    try {
      final notebookData = await ApiService.getNotebook(notebookId);
      if (notebookData != null) {
        final updatedNotebook = _parseNotebookFromApi(notebookData);
        
        final notebooks = state.notebooks.map((notebook) {
          if (notebook.id == notebookId) {
            return updatedNotebook;
          }
          return notebook;
        }).toList();
        
        state = state.copyWith(notebooks: notebooks);
      }
    } catch (e) {
      debugPrint('Error reloading notebook: $e');
    }
  }

  Future<bool> updateProblem({
    required String notebookId,
    required String problemId,
    List<XFile>? imageFiles,
    String? scribbleData,
    ProblemStatus? status,
    List<String>? tags,
  }) async {
    try {
      final updatedData = await ApiService.updateProblem(
        problemUid: problemId,
        newImageFiles: imageFiles,
        scribbleData: scribbleData,
        status: status != null ? _statusToString(status) : null,
        tags: tags,
      );

      if (updatedData != null) {
        final updatedProblem = _parseProblemFromApi(updatedData);
        
        final notebooks = state.notebooks.map((notebook) {
          if (notebook.id == notebookId) {
            final problems = notebook.problems.map((problem) {
              if (problem.id == problemId) {
                return updatedProblem;
              }
              return problem;
            }).toList();
            
            return notebook.copyWith(
              problems: problems,
              updatedAt: DateTime.now(),
            );
          }
          return notebook;
        }).toList();

        state = state.copyWith(notebooks: notebooks);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update problem: $e');
      return false;
    }
  }

  Future<bool> deleteProblem(String notebookId, String problemId) async {
    try {
      final success = await ApiService.deleteProblem(problemId);
      
      if (success) {
        final notebooks = state.notebooks.map((notebook) {
          if (notebook.id == notebookId) {
            final problems = notebook.problems
                .where((problem) => problem.id != problemId)
                .toList();
            
            return notebook.copyWith(
              problems: problems,
              updatedAt: DateTime.now(),
            );
          }
          return notebook;
        }).toList();

        state = state.copyWith(notebooks: notebooks);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete problem: $e');
      return false;
    }
  }

  Future<String> saveImageFromCamera(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path_helper.join(directory.path, 'math_images'));
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}.png';
      final filePath = path_helper.join(imagesDir.path, fileName);
      
      await imageFile.copy(filePath);
      return filePath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> addAiFeedback({
    required String notebookId,
    required String problemId,
    required String message,
    FeedbackType type = FeedbackType.suggestion,
    String? relatedImagePath,
  }) async {
    final feedback = AiFeedback(
      id: _uuid.v4(),
      message: message,
      timestamp: DateTime.now(),
      type: type,
      relatedImagePath: relatedImagePath,
    );

    final notebooks = state.notebooks.map((notebook) {
      if (notebook.id == notebookId) {
        final problems = notebook.problems.map((problem) {
          if (problem.id == problemId) {
            final updatedFeedbacks = [...problem.aiFeedbacks, feedback];
            return problem.copyWith(
              aiFeedbacks: updatedFeedbacks,
              updatedAt: DateTime.now(),
            );
          }
          return problem;
        }).toList();
        
        return notebook.copyWith(
          problems: problems,
          updatedAt: DateTime.now(),
        );
      }
      return notebook;
    }).toList();

    state = state.copyWith(notebooks: notebooks);
  }

  Notebook? getNotebook(String notebookId) {
    try {
      return state.notebooks.firstWhere((notebook) => notebook.id == notebookId);
    } catch (e) {
      return null;
    }
  }

  // Public method to refresh a specific notebook
  Future<bool> refreshNotebook(String notebookId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _reloadNotebook(notebookId);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh notebook: $e',
      );
      return false;
    }
  }

  MathProblem? getProblem(String notebookId, String problemId) {
    final notebook = getNotebook(notebookId);
    if (notebook == null) return null;
    
    try {
      return notebook.problems.firstWhere((problem) => problem.id == problemId);
    } catch (e) {
      return null;
    }
  }
}