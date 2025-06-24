import 'package:flutter/material.dart';
import 'package:ai_math_helper/services/image_import_service.dart';
import 'dart:io';

class AddProblemDialog extends StatefulWidget {
  final Function(String title, String? description, List<String> tags, List<String> imagePaths) onProblemAdded;
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
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    if (widget.problem != null) {
      _titleController.text = widget.problem.title;
      _descriptionController.text = widget.problem.description ?? '';
      _tags.addAll(widget.problem.tags ?? []);
      _imagePaths.addAll(widget.problem.imagePaths ?? []);
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
              const SizedBox(height: 16),
              Text(
                'Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _importFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _importFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _scanDocument,
                      icon: const Icon(Icons.document_scanner),
                      label: const Text('Scanner'),
                    ),
                  ),
                ],
              ),
              if (_imagePaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(
                                File(_imagePaths[index]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image);
                                },
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  Future<void> _importFromCamera() async {
    final imagePaths = await ImageImportService.importFromCamera();
    setState(() {
      _imagePaths.addAll(imagePaths);
    });
  }

  Future<void> _importFromGallery() async {
    final imagePaths = await ImageImportService.importFromGallery();
    setState(() {
      _imagePaths.addAll(imagePaths);
    });
  }

  Future<void> _scanDocument() async {
    final imagePaths = await ImageImportService.scanDocument();
    setState(() {
      _imagePaths.addAll(imagePaths);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _saveProblem() {
    if (_formKey.currentState!.validate()) {
      widget.onProblemAdded(
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _tags,
        _imagePaths,
      );
      Navigator.of(context).pop();
    }
  }
}