import 'package:flutter/material.dart';

class CreateNotebookDialog extends StatefulWidget {
  final Function(String title, String? description, String color) onNotebookCreated;
  final dynamic notebook; // For editing existing notebook

  const CreateNotebookDialog({
    super.key,
    required this.onNotebookCreated,
    this.notebook,
  });

  @override
  State<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends State<CreateNotebookDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedColor = 'blue';

  final List<Map<String, dynamic>> _availableColors = [
    {'name': 'blue', 'color': Colors.blue, 'label': 'Blue'},
    {'name': 'green', 'color': Colors.green, 'label': 'Green'},
    {'name': 'red', 'color': Colors.red, 'label': 'Red'},
    {'name': 'orange', 'color': Colors.orange, 'label': 'Orange'},
    {'name': 'purple', 'color': Colors.purple, 'label': 'Purple'},
    {'name': 'teal', 'color': Colors.teal, 'label': 'Teal'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.notebook != null) {
      _titleController.text = widget.notebook.title;
      _descriptionController.text = widget.notebook.description ?? '';
      _selectedColor = widget.notebook.coverColor;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.notebook != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Notebook' : 'Create New Notebook'),
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
                  labelText: 'Notebook Title',
                  hintText: 'e.g., Algebra Basics',
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
                  hintText: 'Brief description of this notebook',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Text(
                'Cover Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((colorInfo) {
                  final isSelected = _selectedColor == colorInfo['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorInfo['name'];
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorInfo['color'],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              )
                            : Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
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
          onPressed: _saveNotebook,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _saveNotebook() {
    if (_formKey.currentState!.validate()) {
      widget.onNotebookCreated(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedColor,
      );
      Navigator.of(context).pop();
    }
  }
}