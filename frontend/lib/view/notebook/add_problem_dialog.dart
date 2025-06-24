import 'package:flutter/material.dart';

class AddProblemDialog extends StatefulWidget {
  final Function(String title, String? description, List<String> tags) onProblemAdded;
  final dynamic problem; // For editing existing problem

  const AddProblemDialog({
    super.key,
    required this.onProblemAdded,
    this.problem,
  });

  @override
  State<AddProblemDialog> createState() => _AddProblemDialogState();
}

class _AddProblemDialogState extends State<AddProblemDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.problem != null) {
      _titleController.text = widget.problem.title;
      _descriptionController.text = widget.problem.description ?? '';
      _tags.addAll(widget.problem.tags ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.problem != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Problem' : 'Add New Problem'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Problem Title',
                  hintText: 'e.g., Quadratic Equation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the problem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add a tag (e.g., algebra)',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _addTag(_tagController.text),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Common tags: algebra, geometry, calculus, trigonometry',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveProblem,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _addTag(String tagText) {
    final tag = tagText.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _saveProblem() {
    if (_formKey.currentState!.validate()) {
      widget.onProblemAdded(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _tags,
      );
      Navigator.of(context).pop();
    }
  }
}