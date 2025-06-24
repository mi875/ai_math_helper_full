import 'dart:io';
import 'package:ai_math_helper/data/notebook/data/notebook_data.dart';
import 'package:ai_math_helper/data/notebook/data/math_problem.dart';
import 'package:ai_math_helper/data/notebook/data/ai_feedback.dart';
import 'package:ai_math_helper/data/notebook/data/problem_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_helper;

part 'notebook_model.g.dart';

@riverpod
class NotebookModel extends _$NotebookModel {
  static const _uuid = Uuid();

  @override
  NotebookData build() {
    // Initialize with sample data immediately
    final sampleNotebooks = [
      Notebook(
        id: _uuid.v4(),
        title: 'Algebra Basics',
        description: 'Linear equations and basic algebra problems',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        problems: [],
        coverColor: 'blue',
      ),
      Notebook(
        id: _uuid.v4(),
        title: 'Geometry',
        description: 'Shapes, angles, and geometric calculations',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        problems: [],
        coverColor: 'green',
      ),
    ];
    
    return NotebookData(notebooks: sampleNotebooks);
  }

  Future<Notebook> createNotebook({
    required String title,
    String? description,
    String coverColor = 'default',
  }) async {
    final notebook = Notebook(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      coverColor: coverColor,
    );

    final updatedNotebooks = [...state.notebooks, notebook];
    state = state.copyWith(notebooks: updatedNotebooks);
    
    // TODO: Persist to storage
    return notebook;
  }

  Future<void> updateNotebook(String notebookId, {
    String? title,
    String? description,
    String? coverColor,
  }) async {
    final notebooks = state.notebooks.map((notebook) {
      if (notebook.id == notebookId) {
        return notebook.copyWith(
          title: title ?? notebook.title,
          description: description ?? notebook.description,
          coverColor: coverColor ?? notebook.coverColor,
          updatedAt: DateTime.now(),
        );
      }
      return notebook;
    }).toList();

    state = state.copyWith(notebooks: notebooks);
  }

  Future<void> deleteNotebook(String notebookId) async {
    final updatedNotebooks = state.notebooks
        .where((notebook) => notebook.id != notebookId)
        .toList();
    
    state = state.copyWith(notebooks: updatedNotebooks);
    // TODO: Clean up associated files and persist changes
  }

  Future<MathProblem> addProblemToNotebook({
    required String notebookId,
    required String title,
    String? description,
    List<String>? imagePaths,
    String? scribbleData,
    List<String>? tags,
  }) async {
    final problem = MathProblem(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imagePaths: imagePaths,
      scribbleData: scribbleData,
      tags: tags ?? [],
    );

    final notebooks = state.notebooks.map((notebook) {
      if (notebook.id == notebookId) {
        final updatedProblems = [...notebook.problems, problem];
        return notebook.copyWith(
          problems: updatedProblems,
          updatedAt: DateTime.now(),
        );
      }
      return notebook;
    }).toList();

    state = state.copyWith(notebooks: notebooks);
    return problem;
  }

  Future<void> updateProblem({
    required String notebookId,
    required String problemId,
    String? title,
    String? description,
    List<String>? imagePaths,
    String? scribbleData,
    ProblemStatus? status,
    List<String>? tags,
  }) async {
    final notebooks = state.notebooks.map((notebook) {
      if (notebook.id == notebookId) {
        final problems = notebook.problems.map((problem) {
          if (problem.id == problemId) {
            return problem.copyWith(
              title: title ?? problem.title,
              description: description ?? problem.description,
              imagePaths: imagePaths ?? problem.imagePaths,
              scribbleData: scribbleData ?? problem.scribbleData,
              status: status ?? problem.status,
              tags: tags ?? problem.tags,
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

  Future<void> deleteProblem(String notebookId, String problemId) async {
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