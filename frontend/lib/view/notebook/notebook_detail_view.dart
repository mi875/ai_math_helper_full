import 'dart:io';
import 'package:ai_math_helper/data/notebook/model/notebook_model.dart';
import 'package:ai_math_helper/services/image_import_service.dart';
import 'package:ai_math_helper/view/notebook/add_problem_dialog.dart';
import 'package:ai_math_helper/view/math_input/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotebookDetailView extends ConsumerWidget {
  final String notebookId;

  const NotebookDetailView({
    super.key,
    required this.notebookId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebookState = ref.watch(notebookModelProvider);
    final notebook = notebookState.notebooks
        .where((n) => n.id == notebookId)
        .firstOrNull;

    if (notebook == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notebook Not Found'),
        ),
        body: const Center(
          child: Text('The requested notebook could not be found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(notebook.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search within notebook
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Notebook'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Show edit dialog
              } else if (value == 'share') {
                // TODO: Implement sharing
              }
            },
          ),
        ],
      ),
      body: notebook.problems.isEmpty
          ? _buildEmptyState(context, ref, notebook)
          : _buildProblemsList(context, ref, notebook),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'camera_fab',
            onPressed: () => _importFromCamera(context, ref, notebook),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'gallery_fab',
            onPressed: () => _importFromGallery(context, ref, notebook),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add_fab',
            onPressed: () => _showAddProblemDialog(context, ref, notebook),
            icon: const Icon(Icons.add),
            label: const Text('Add Problem'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, notebook) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Problems Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start adding math problems to organize your learning',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                FilledButton.icon(
                  onPressed: () => _importFromCamera(context, ref, notebook),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Problem'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddProblemDialog(context, ref, notebook),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Manually'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemsList(BuildContext context, WidgetRef ref, notebook) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${notebook.problems.length} problem${notebook.problems.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: notebook.problems.length,
              itemBuilder: (context, index) {
                final problem = notebook.problems[index];
                return _buildProblemCard(context, ref, notebook, problem);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(BuildContext context, WidgetRef ref, notebook, problem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Open problem detail view or math input with this problem
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MathInputScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(context, problem.status),
                ],
              ),
              if (problem.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  problem.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (problem.imagePaths != null && problem.imagePaths!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: problem.imagePaths!.length,
                    itemBuilder: (context, imageIndex) {
                      final imagePath = problem.imagePaths![imageIndex];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (problem.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: problem.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(problem.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditProblemDialog(context, ref, notebook, problem);
                      } else if (value == 'delete') {
                        _showDeleteProblemConfirmation(context, ref, notebook, problem);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, status) {
    Color chipColor;
    String statusText;
    IconData icon;

    switch (status.toString().split('.').last) {
      case 'solved':
        chipColor = Colors.green;
        statusText = 'Solved';
        icon = Icons.check_circle;
        break;
      case 'inProgress':
        chipColor = Colors.orange;
        statusText = 'In Progress';
        icon = Icons.pending;
        break;
      case 'needsHelp':
        chipColor = Colors.red;
        statusText = 'Needs Help';
        icon = Icons.help;
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'Unsolved';
        icon = Icons.radio_button_unchecked;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: chipColor),
      label: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _importFromCamera(BuildContext context, WidgetRef ref, notebook) async {
    try {
      final imagePaths = await ImageImportService.importFromCamera();
      if (imagePaths.isNotEmpty) {
        await _createProblemFromImages(context, ref, notebook, imagePaths);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to scan documents. Please enable camera access in your device settings.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing from camera: $e')),
        );
      }
    }
  }

  Future<void> _importFromGallery(BuildContext context, WidgetRef ref, notebook) async {
    try {
      final imagePaths = await ImageImportService.importFromGallery();
      if (imagePaths.isNotEmpty) {
        await _createProblemFromImages(context, ref, notebook, imagePaths);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing from gallery: $e')),
        );
      }
    }
  }

  Future<void> _createProblemFromImages(
    BuildContext context,
    WidgetRef ref,
    notebook,
    List<String> imagePaths,
  ) async {
    final problemTitle = 'Math Problem ${notebook.problems.length + 1}';
    
    await ref.read(notebookModelProvider.notifier).addProblemToNotebook(
      notebookId: notebook.id,
      title: problemTitle,
      imagePaths: imagePaths,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem added successfully!')),
      );
    }
  }

  void _showAddProblemDialog(BuildContext context, WidgetRef ref, notebook) {
    showDialog(
      context: context,
      builder: (context) => AddProblemDialog(
        onProblemAdded: (title, description, tags, imagePaths) {
          ref.read(notebookModelProvider.notifier).addProblemToNotebook(
            notebookId: notebook.id,
            title: title,
            description: description,
            imagePaths: imagePaths,
            tags: tags,
          );
        },
      ),
    );
  }

  void _showEditProblemDialog(BuildContext context, WidgetRef ref, notebook, problem) {
    showDialog(
      context: context,
      builder: (context) => AddProblemDialog(
        problem: problem,
        onProblemAdded: (title, description, tags, imagePaths) {
          ref.read(notebookModelProvider.notifier).updateProblem(
            notebookId: notebook.id,
            problemId: problem.id,
            title: title,
            description: description,
            imagePaths: imagePaths,
            tags: tags,
          );
        },
      ),
    );
  }

  void _showDeleteProblemConfirmation(
    BuildContext context,
    WidgetRef ref,
    notebook,
    problem,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Problem'),
        content: Text(
          'Are you sure you want to delete "${problem.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notebookModelProvider.notifier).deleteProblem(
                notebook.id,
                problem.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}