import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribble/scribble.dart';
import 'package:ai_math_helper/data/notebook/data/math_problem.dart';
import 'package:ai_math_helper/services/authenticated_image_provider.dart';

class MathInputScreen extends ConsumerStatefulWidget {
  final MathProblem? problem;

  const MathInputScreen({super.key, this.problem});

  @override
  ConsumerState<MathInputScreen> createState() => _MathInputScreenState();
}

class _MathInputScreenState extends ConsumerState<MathInputScreen> {
  late ScribbleNotifier notifier;
  bool _isSheetWidthExpanded = false;
  final double _collapsedSheetWidthFraction = 0.3;
  final double _expandedSheetWidthFraction = 0.5;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier(widths: [2]);
    _transformationController = TransformationController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setThemeAwarePenColor();
  }

  void _setThemeAwarePenColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final penColor = isDark ? Colors.white : Colors.black;

    // Try to set pen color if the method exists
    try {
      notifier.setColor(penColor);
    } catch (e) {
      // If setColor doesn't exist, the pen will use default color
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentSheetWidth =
        screenWidth *
        (_isSheetWidthExpanded
            ? _expandedSheetWidthFraction
            : _collapsedSheetWidthFraction);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Input'), // Reverted to a simple Text widget
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => notifier.undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => notifier.redo(),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed:
                () => _transformationController.value = Matrix4.identity(),
            tooltip: 'Reset zoom and pan',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => notifier.clear(),
          ),
        ],
      ),
      body: Stack(
        // Use Stack to overlay the draggable sheet
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  if (widget.problem?.image != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: AuthenticatedImage(
                          imageUrl: widget.problem!.image!.fileUrl,
                          fit: BoxFit.contain,
                          placeholder: const Center(
                            child: Icon(Icons.image, size: 24),
                          ),
                          errorWidget: const Center(
                            child: Icon(Icons.broken_image, size: 24),
                          ),
                        ),
                      ),
                    ),
                  Scribble(notifier: notifier, drawPen: true),
                ],
              ),
            ),
          ),
          // Problem image in top left

          // Align the entire draggable panel to the bottom-left
          Align(
            alignment: Alignment.bottomLeft,
            // AnimatedContainer controls the width and outer margins of the panel
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: currentSheetWidth,
              margin: const EdgeInsets.only(
                left: 16.0,
                right: 8.0,
              ), // Outer margin for the panel
              child: DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (
                  BuildContext context,
                  ScrollController scrollController,
                ) {
                  // The Material widget is now the direct content of the DraggableScrollableSheet
                  return Material(
                    elevation: 4.0,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.0),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      // Ensure mainAxisSize is not min (default is max)
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                          ),
                        ),
                        // Title and Width Toggle Button
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            top: 8.0,
                            bottom: 4.0,
                            right: 8.0, // Added right padding for the button
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Allow title to take available space
                                child: Text(
                                  'AI Feedback & Tips',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                  overflow:
                                      TextOverflow
                                          .ellipsis, // Handle potential overflow
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isSheetWidthExpanded
                                      ? Icons.width_normal
                                      : Icons.width_wide,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSheetWidthExpanded =
                                        !_isSheetWidthExpanded;
                                  });
                                },
                                tooltip:
                                    _isSheetWidthExpanded
                                        ? 'Collapse width'
                                        : 'Expand width',
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                iconSize: 20.0, // Adjusted icon size
                                padding:
                                    EdgeInsets
                                        .zero, // Reduce padding around icon
                                constraints:
                                    const BoxConstraints(), // Reduce tap target size if needed
                              ),
                            ],
                          ),
                        ),
                        // Main scrollable content area (e.g., for future chat messages)
                        Expanded(
                          child: ListView(
                            // This will be the primary scrollable area of the sheet
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ), // Adjusted for chat bubbles
                            children: [
                              // Sample AI Response
                              _buildChatMessage(
                                context,
                                "Sure, I can help with that! The Pythagorean theorem states that in a right-angled triangle, the square of the hypotenuse (the side opposite the right angle) is equal to the sum of the squares of the other two sides. This is written as: a² + b² = c².",
                              ),
                              // Add more messages here as the chat progresses
                            ],
                          ),
                        ),
                        // Scrollable Row of Common Question Chips
                        _buildCommonQuestionsChipRow(),
                        // User Text Input Field
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Ask a question...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  print('Send button tapped');
                                },
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
          ),
        ],
      ),
      // bottomSheet: _buildAiFeedbackBottomSheet(), // Removed, using DraggableScrollableSheet
    );
  }

  // _buildAiFeedbackBottomSheet() is no longer used for the primary layout.
  // It can be removed if not needed elsewhere.

  // Re-introducing _buildChatMessage helper for styling
  Widget _buildChatMessage(
    BuildContext context,
    String text, {
    bool isUser = false,
  }) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isUser
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.primaryContainer;
    final textColor =
        isUser
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onPrimaryContainer;
    final borderRadius =
        isUser
            ? const BorderRadius.all(
              Radius.circular(16.0),
            ).copyWith(bottomRight: const Radius.circular(4))
            : const BorderRadius.all(
              Radius.circular(16.0),
            ).copyWith(bottomLeft: const Radius.circular(4));

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ), // Max width for bubble
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }

  Widget _buildCommonQuestionsChipRow() {
    final List<String> commonQuestions = [
      "How to solve for x?",
      "Pythagorean theorem?", // Shortened for chips
      "Derivative of x^n?",
      "Integral of 1/x?",
      "Quadratic Formula?",
      "Area of a Circle?",
      "Circumference?", // Shortened
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children:
              commonQuestions.map((question) {
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ), // Spacing between chips
                  child: ActionChip(
                    avatar: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(question),
                    onPressed: () {
                      // Handle chip tap
                      print('Tapped: $question');
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // _buildFeedbackContent is no longer the primary content builder for the Expanded section.
  // It's replaced by _buildCommonQuestionsChipRow and the new Expanded ListView.
  // You can remove _buildFeedbackContent if it's not used elsewhere, or repurpose it.
  // For clarity, I'm removing the old _buildFeedbackContent method.
  /*
  Widget _buildFeedbackContent(ScrollController scrollController) { 
    // ... old content ...
  }
  */
}
