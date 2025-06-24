import 'package:ai_math_helper/data/notebook/model/notebook_model.dart';
import 'package:ai_math_helper/view/notebook/notebook_detail_view.dart';
import 'package:ai_math_helper/view/notebook/create_notebook_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotebooksView extends ConsumerWidget {
  const NotebooksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebookState = ref.watch(notebookModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notebooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: notebookState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notebookState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notebooks',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notebookState.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          ref.refresh(notebookModelProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : notebookState.notebooks.isEmpty
                  ? _buildEmptyState(context, ref)
                  : _buildNotebooksList(context, notebookState.notebooks, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNotebookDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Notebook'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Notebooks Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first notebook to start organizing your math problems',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreateNotebookDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create First Notebook'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotebooksList(BuildContext context, notebooks, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: notebooks.length,
        itemBuilder: (context, index) {
          final notebook = notebooks[index];
          return _buildNotebookCard(context, notebook, ref);
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 400) return 2;
    return 1;
  }

  Widget _buildNotebookCard(BuildContext context, notebook, WidgetRef ref) {
    final coverColor = _getCoverColor(context, notebook.coverColor);
    final problemCount = notebook.problems.length;

    return Card(
      elevation: 0,
      color: coverColor.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotebookDetailView(notebookId: notebook.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              color: coverColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notebook.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                              _showEditNotebookDialog(context, ref, notebook);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, ref, notebook);
                            }
                          },
                        ),
                      ],
                    ),
                    if (notebook.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        notebook.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$problemCount problem${problemCount == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(notebook.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoverColor(BuildContext context, String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
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

  void _showCreateNotebookDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateNotebookDialog(
        onNotebookCreated: (title, description, color) {
          ref.read(notebookModelProvider.notifier).createNotebook(
                title: title,
                description: description,
                coverColor: color,
              );
        },
      ),
    );
  }

  void _showEditNotebookDialog(BuildContext context, WidgetRef ref, notebook) {
    showDialog(
      context: context,
      builder: (context) => CreateNotebookDialog(
        notebook: notebook,
        onNotebookCreated: (title, description, color) {
          ref.read(notebookModelProvider.notifier).updateNotebook(
                notebook.id,
                title: title,
                description: description,
                coverColor: color,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, notebook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notebook'),
        content: Text(
          'Are you sure you want to delete "${notebook.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notebookModelProvider.notifier).deleteNotebook(notebook.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}