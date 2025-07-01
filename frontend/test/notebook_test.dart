import 'package:flutter_test/flutter_test.dart';
import 'package:ai_math_helper/data/notebook/data/notebook_data.dart';
import 'package:ai_math_helper/data/notebook/data/math_problem.dart';
import 'package:ai_math_helper/data/notebook/data/problem_image.dart';
import 'package:ai_math_helper/data/notebook/data/problem_status.dart';

void main() {
  group('Notebook Data Tests', () {
    test('should create a notebook with default values', () {
      final notebook = Notebook(
        id: 'test-id',
        title: 'Test Notebook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(notebook.id, 'test-id');
      expect(notebook.title, 'Test Notebook');
      expect(notebook.description, null);
      expect(notebook.problems, []);
      expect(notebook.coverColor, 'default');
    });

    test('should create a notebook with custom values', () {
      final now = DateTime.now();
      final notebook = Notebook(
        id: 'test-id',
        title: 'Math Notebook',
        description: 'Algebra problems',
        createdAt: now,
        updatedAt: now,
        problems: [],
        coverColor: 'blue',
      );

      expect(notebook.id, 'test-id');
      expect(notebook.title, 'Math Notebook');
      expect(notebook.description, 'Algebra problems');
      expect(notebook.coverColor, 'blue');
    });

    test('should create a math problem with default values', () {
      final problem = MathProblem(
        id: 'problem-id',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(problem.id, 'problem-id');
      expect(problem.images, []);
      expect(problem.scribbleData, null);
      expect(problem.status, ProblemStatus.unsolved);
      expect(problem.tags, []);
      expect(problem.aiFeedbacks, []);
    });

    test('should create a math problem with custom values', () {
      final now = DateTime.now();
      final testImages = [
        ProblemImage(
          id: 1,
          uid: 'img-1',
          originalFilename: 'test1.jpg',
          filename: 'test1.jpg',
          fileUrl: 'https://example.com/test1.jpg',
          mimeType: 'image/jpeg',
          fileSize: 12345,
          displayOrder: 0,
          createdAt: now,
        ),
        ProblemImage(
          id: 2,
          uid: 'img-2',
          originalFilename: 'test2.jpg',
          filename: 'test2.jpg',
          fileUrl: 'https://example.com/test2.jpg',
          mimeType: 'image/jpeg',
          fileSize: 67890,
          displayOrder: 1,
          createdAt: now,
        ),
      ];
      
      final problem = MathProblem(
        id: 'problem-id',
        createdAt: now,
        updatedAt: now,
        images: testImages,
        scribbleData: 'scribble-data',
        status: ProblemStatus.inProgress,
        tags: ['algebra', 'linear'],
      );

      expect(problem.id, 'problem-id');
      expect(problem.images.first.fileUrl, 'https://example.com/test1.jpg');
      expect(problem.scribbleData, 'scribble-data');
      expect(problem.status, ProblemStatus.inProgress);
      expect(problem.tags, ['algebra', 'linear']);
    });

    test('should create notebook data with default values', () {
      const notebookData = NotebookData();

      expect(notebookData.notebooks, []);
      expect(notebookData.isLoading, false);
      expect(notebookData.errorMessage, null);
    });

    test('should create notebook data with custom values', () {
      const notebookData = NotebookData(
        notebooks: [],
        isLoading: true,
        errorMessage: 'Error loading notebooks',
      );

      expect(notebookData.notebooks, []);
      expect(notebookData.isLoading, true);
      expect(notebookData.errorMessage, 'Error loading notebooks');
    });

    test('should handle problem status enum correctly', () {
      expect(ProblemStatus.unsolved.toString(), 'ProblemStatus.unsolved');
      expect(ProblemStatus.inProgress.toString(), 'ProblemStatus.inProgress');
      expect(ProblemStatus.solved.toString(), 'ProblemStatus.solved');
      expect(ProblemStatus.needsHelp.toString(), 'ProblemStatus.needsHelp');
    });

    test('should copy notebook with updated values', () {
      final now = DateTime.now();
      final original = Notebook(
        id: 'test-id',
        title: 'Original Title',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        description: 'New description',
      );

      expect(updated.id, 'test-id');
      expect(updated.title, 'Updated Title');
      expect(updated.description, 'New description');
      expect(updated.createdAt, now);
    });

    test('should copy math problem with updated values', () {
      final now = DateTime.now();
      final original = MathProblem(
        id: 'problem-id',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        status: ProblemStatus.solved,
        tags: ['geometry'],
      );

      expect(updated.id, 'problem-id');
      expect(updated.status, ProblemStatus.solved);
      expect(updated.tags, ['geometry']);
      expect(updated.createdAt, now);
    });
  });
}