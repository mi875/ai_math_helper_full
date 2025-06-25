import 'package:flutter/material.dart';
import 'package:ai_math_helper/services/image_import_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProblemDialog extends StatefulWidget {
  final Function(List<String> tags, XFile? imageFile) onProblemAdded;
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
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _tags = [];
  XFile? _selectedImageFile; // Single image file

  @override
  void initState() {
    super.initState();
    if (widget.problem != null) {
      _tags.addAll(widget.problem.tags ?? []);
      // Note: For editing, existing image will be handled separately
    }
  }

  @override
  void dispose() {
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
              if (_selectedImageFile != null) ...[
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        File(_selectedImageFile!.path),
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
                        onTap: _removeImage,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    final imageFiles = await ImageImportService.importFromCamera();
    if (imageFiles.isNotEmpty) {
      setState(() {
        _selectedImageFile = imageFiles.first;
      });
    }
  }

  Future<void> _importFromGallery() async {
    final imageFiles = await ImageImportService.importFromGallery();
    if (imageFiles.isNotEmpty) {
      setState(() {
        _selectedImageFile = imageFiles.first;
      });
    }
  }

  Future<void> _scanDocument() async {
    final imageFiles = await ImageImportService.scanDocument();
    if (imageFiles.isNotEmpty) {
      setState(() {
        _selectedImageFile = imageFiles.first;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
    });
  }

  void _saveProblem() {
    if (_formKey.currentState!.validate()) {
      widget.onProblemAdded(
        _tags,
        _selectedImageFile,
      );
      Navigator.of(context).pop();
    }
  }
}