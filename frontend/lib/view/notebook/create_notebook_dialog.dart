import 'package:flutter/material.dart';
import '../../l10n/localization_helper.dart';

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
    {'name': 'blue', 'color': Colors.blue, 'label': L10n.get('colorBlue')},
    {'name': 'green', 'color': Colors.green, 'label': L10n.get('colorGreen')},
    {'name': 'red', 'color': Colors.red, 'label': L10n.get('colorRed')},
    {'name': 'orange', 'color': Colors.orange, 'label': L10n.get('colorOrange')},
    {'name': 'purple', 'color': Colors.purple, 'label': L10n.get('colorPurple')},
    {'name': 'teal', 'color': Colors.teal, 'label': L10n.get('colorTeal')},
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
      title: Text(isEditing ? L10n.get('editNotebookTitle') : L10n.get('createNewNotebookTitle')),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: L10n.get('notebookTitleLabel'),
                  hintText: L10n.get('notebookTitleHint'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return L10n.get('pleaseEnterTitle');
                  }
                  return null;
                },
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: L10n.get('descriptionOptionalLabel'),
                  hintText: L10n.get('descriptionHint'),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Text(
                L10n.get('coverColorLabel'),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(L10n.get('cancelButton')),
        ),
        FilledButton(
          onPressed: _saveNotebook,
          child: Text(isEditing ? L10n.get('update') : L10n.get('create')),
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