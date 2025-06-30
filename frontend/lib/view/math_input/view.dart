import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/custom_widgets/selectable_adapter.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:scribble/scribble.dart';
import 'package:ai_math_helper/data/notebook/data/math_problem.dart';
import 'package:ai_math_helper/services/authenticated_image_provider.dart';
import 'package:ai_math_helper/services/api_service.dart';
import 'package:ai_math_helper/data/notebook/data/ai_feedback.dart';
import 'package:ai_math_helper/data/notebook/data/problem_status.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

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

  // AI feedback state
  List<AiFeedback> _aiFeedbacks = [];
  bool _isGeneratingFeedback = false;
  final GlobalKey _scribbleKey = GlobalKey();
  
  // Chat message state
  final TextEditingController _messageController = TextEditingController();
  bool _isSendingMessage = false;
  List<Map<String, dynamic>> _chatMessages = []; // Store both user and AI messages

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

  void _checkAnswer() {
    // TODO: Implement answer checking logic
    // This could integrate with the AI system to evaluate the drawn solution
    print('Check Answer button pressed');

    // Show a snackbar as feedback for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer checking functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Generate AI feedback from canvas drawing
  String _currentStreamingText = '';

  Future<void> _generateAiFeedback() async {
    // Use the chat message system for AI feedback
    await _sendChatMessage("Please analyze my solution and provide feedback");
  }

  FeedbackType _parseFeedbackType(String typeString) {
    switch (typeString) {
      case 'correction':
        return FeedbackType.correction;
      case 'explanation':
        return FeedbackType.explanation;
      case 'encouragement':
        return FeedbackType.encouragement;
      case 'suggestion':
      default:
        return FeedbackType.suggestion;
    }
  }

  // Send chat message to AI
  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty || widget.problem?.id == null) {
      return;
    }

    // Add user message to chat
    setState(() {
      _isSendingMessage = true;
      _chatMessages.insert(0, {
        'id': 'user-${DateTime.now().millisecondsSinceEpoch}',
        'message': message,
        'timestamp': DateTime.now(),
        'sender': 'user',
      });
    });

    try {
      // Get canvas image if available
      final canvasImageBytes = await _captureCanvasAsImage();

      // Create a temporary feedback object for streaming display
      final tempFeedback = AiFeedback(
        id: 'streaming-temp',
        message: '',
        timestamp: DateTime.now(),
        type: FeedbackType.suggestion,
      );

      // Add temporary AI message to chat
      setState(() {
        _aiFeedbacks.insert(0, tempFeedback);
        _chatMessages.insert(0, {
          'id': 'ai-streaming-temp',
          'message': '',
          'timestamp': DateTime.now(),
          'sender': 'ai',
          'isStreaming': true,
        });
      });

      // Start streaming AI response to the chat message
      try {
        await for (final chunk in ApiService.streamAiFeedback(
          widget.problem!.id,
          canvasImageBytes ?? Uint8List(0),
          customMessage: message,
        )) {
          if (!mounted) break;

          switch (chunk['type']) {
            case 'start':
              setState(() {
                _currentStreamingText = chunk['message'] ?? 'AI is responding...';
                _aiFeedbacks[0] = _aiFeedbacks[0].copyWith(
                  message: _currentStreamingText,
                );
                _chatMessages[0] = {
                  ..._chatMessages[0],
                  'message': _currentStreamingText,
                };
              });
              break;

            case 'chunk':
              setState(() {
                _currentStreamingText = chunk['fullText'] ?? '';
                _aiFeedbacks[0] = _aiFeedbacks[0].copyWith(
                  message: _currentStreamingText,
                );
                _chatMessages[0] = {
                  ..._chatMessages[0],
                  'message': _currentStreamingText,
                };
              });
              break;

            case 'complete':
              final completedFeedback = AiFeedback(
                id: chunk['id'],
                message: chunk['message'],
                timestamp: DateTime.parse(chunk['timestamp']),
                type: _parseFeedbackType(chunk['feedbackType']),
              );
              
              setState(() {
                _aiFeedbacks[0] = completedFeedback;
                _chatMessages[0] = {
                  'id': chunk['id'],
                  'message': chunk['message'],
                  'timestamp': DateTime.parse(chunk['timestamp']),
                  'sender': 'ai',
                  'feedbackType': chunk['feedbackType'],
                  'isStreaming': false,
                };
              });
              break;

            case 'error':
              setState(() {
                _aiFeedbacks.removeAt(0);
                _chatMessages.removeAt(0);
              });
              throw Exception(chunk['error'] ?? 'Unknown streaming error');
          }
        }
      } catch (streamingError) {
        debugPrint('Streaming failed: $streamingError');
        
        // Fallback to original non-streaming API
        try {
          setState(() {
            _currentStreamingText = 'Streaming failed. Using regular API...';
            _aiFeedbacks[0] = _aiFeedbacks[0].copyWith(
              message: _currentStreamingText,
            );
            _chatMessages[0] = {
              ..._chatMessages[0],
              'message': _currentStreamingText,
            };
          });

          final feedback = await ApiService.generateAiFeedback(
            widget.problem!.id,
            canvasImageBytes ?? Uint8List(0),
            customMessage: message,
          );

          if (feedback != null) {
            setState(() {
              _aiFeedbacks[0] = feedback;
              _chatMessages[0] = {
                'id': feedback.id,
                'message': feedback.message,
                'timestamp': feedback.timestamp,
                'sender': 'ai',
                'feedbackType': feedback.type.toString().split('.').last,
                'isStreaming': false,
              };
            });
          } else {
            throw Exception('Fallback API also failed');
          }
        } catch (fallbackError) {
          if (_aiFeedbacks.isNotEmpty && _aiFeedbacks[0].id == 'streaming-temp') {
            setState(() {
              _aiFeedbacks.removeAt(0);
            });
          }
          if (_chatMessages.isNotEmpty && _chatMessages[0]['id'] == 'ai-streaming-temp') {
            setState(() {
              _chatMessages.removeAt(0);
            });
          }
          throw Exception('Both streaming and fallback failed: $fallbackError');
        }
      }
    } catch (error) {
      if (_aiFeedbacks.isNotEmpty && _aiFeedbacks[0].id == 'streaming-temp') {
        setState(() {
          _aiFeedbacks.removeAt(0);
        });
      }
      if (_chatMessages.isNotEmpty && _chatMessages[0]['id'] == 'ai-streaming-temp') {
        setState(() {
          _chatMessages.removeAt(0);
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $error')),
      );
    } finally {
      setState(() {
        _isSendingMessage = false;
        _currentStreamingText = '';
      });
    }
  }

  // Capture the scribble canvas as an image
  Future<Uint8List?> _captureCanvasAsImage() async {
    try {
      // Get the render object of the scribble widget
      final RenderRepaintBoundary boundary =
          _scribbleKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (error) {
      print('Error capturing canvas: $error');
      return null;
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    _transformationController.dispose();
    _messageController.dispose();
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
          ElevatedButton.icon(
            onPressed: _checkAnswer,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Check'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed:
                _isGeneratingFeedback || widget.problem?.id == null
                    ? null
                    : _generateAiFeedback,
            icon:
                _isGeneratingFeedback
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.psychology),
            label: const Text('AI Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(width: 8),
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
                  RepaintBoundary(
                    key: _scribbleKey,
                    child: Scribble(notifier: notifier, drawPen: true),
                  ),
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
                                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
                              // Display Chat Messages
                              if (_chatMessages.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.chat_outlined,
                                          size: 48,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ask a question or tap "AI Help" for feedback',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ..._chatMessages.map(
                                  (message) => _buildChatBubble(message),
                                ),
                            ],
                          ),
                        ),
                        // Scrollable Row of Common Question Chips
                        _buildCommonQuestionsChipRow(),
                        // User Text Input Field
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                          child: TextField(
                            controller: _messageController,
                            enabled: !_isSendingMessage && widget.problem?.id != null,
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
                                icon: _isSendingMessage
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(
                                        Icons.send,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                onPressed: _isSendingMessage || widget.problem?.id == null
                                    ? null
                                    : () async {
                                        final message = _messageController.text.trim();
                                        if (message.isNotEmpty) {
                                          _messageController.clear();
                                          await _sendChatMessage(message);
                                        }
                                      },
                              ),
                            ),
                            onSubmitted: _isSendingMessage || widget.problem?.id == null
                                ? null
                                : (message) async {
                                    if (message.trim().isNotEmpty) {
                                      _messageController.clear();
                                      await _sendChatMessage(message.trim());
                                    }
                                  },
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

  // Build feedback card with TeX rendering
  Widget _buildFeedbackCard(AiFeedback feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getFeedbackIcon(feedback.type),
                  size: 16,
                  color: _getFeedbackColor(feedback.type),
                ),
                const SizedBox(width: 8),
                Text(
                  _getFeedbackTypeLabel(feedback.type),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getFeedbackColor(feedback.type),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(feedback.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Render AI feedback with TeX support using gpt_markdown
            Builder(
              builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GptMarkdown(
                      feedback.message,
                  onLinkTap: (url, title) {
                    debugPrint(url);
                    debugPrint(title);
                  },
                  useDollarSignsForLatex: true,
                  textAlign: TextAlign.justify,
                  textScaler: const TextScaler.linear(1),
                  style: const TextStyle(fontSize: 15),
                  highlightBuilder: (context, text, style) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize:
                              style.fontSize != null
                                  ? style.fontSize! * 0.9
                                  : 13.5,
                          height: style.height,
                        ),
                      ),
                    );
                  },
                  latexWorkaround: (tex) {
                    List<String> stack = [];
                    tex = tex.splitMapJoin(
                      RegExp(r"\\text\{|\{|\}|\_"),
                      onMatch: (p) {
                        String input = p[0] ?? "";
                        if (input == r"\text{") {
                          stack.add(input);
                        }
                        if (stack.isNotEmpty) {
                          if (input == r"{") {
                            stack.add(input);
                          }
                          if (input == r"}") {
                            stack.removeLast();
                          }
                          if (input == r"_") {
                            return r"\_";
                          }
                        }
                        return input;
                      },
                    );
                    return tex.replaceAllMapped(
                      RegExp(r"align\*"),
                      (match) => "aligned",
                    );
                  },
                  imageBuilder: (context, url) {
                    return Image.network(url, width: 100, height: 100);
                  },
                  latexBuilder: (context, tex, textStyle, inline) {
                    if (tex.contains(r"\begin{tabular}")) {
                      // return table.
                      String tableString =
                          "|${(RegExp(r"^\\begin\{tabular\}\{.*?\}(.*?)\\end\{tabular\}$", multiLine: true, dotAll: true).firstMatch(tex)?[1] ?? "").trim()}|";
                      tableString = tableString
                          .replaceAll(r"\\", "|\n|")
                          .replaceAll(r"\hline", "")
                          .replaceAll(RegExp(r"(?<!\\)&"), "|");
                      var tableStringList = tableString.split("\n")
                        ..insert(1, "|---|");
                      tableString = tableStringList.join("\n");
                      return GptMarkdown(tableString);
                    }
                    var controller = ScrollController();
                    Widget child = Math.tex(tex, textStyle: textStyle);
                    if (!inline) {
                      child = Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Material(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Scrollbar(
                              controller: controller,
                              child: SingleChildScrollView(
                                controller: controller,
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(tex, textStyle: textStyle),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    child = SelectableAdapter(
                      selectedText: tex,
                      child: Math.tex(tex),
                    );
                    child = InkWell(
                      onTap: () {
                        debugPrint("Hello world");
                      },
                      child: child,
                    );
                    return child;
                  },
                  sourceTagBuilder: (buildContext, string, textStyle) {
                    var value = int.tryParse(string);
                    value ??= -1;
                    value += 1;
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text("$value")),
                      ),
                    );
                  },
                  linkBuilder: (context, label, path, style) {
                    return Text(
                      label,
                      style: style.copyWith(color: Colors.blue),
                    );
                  },
                ),
                    // Show typing indicator if this is the streaming feedback
                    if (feedback.id == 'streaming-temp' && _isGeneratingFeedback)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AIが回答を生成中...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFeedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.correction:
        return Icons.edit;
      case FeedbackType.explanation:
        return Icons.lightbulb;
      case FeedbackType.encouragement:
        return Icons.thumb_up;
      case FeedbackType.suggestion:
        return Icons.tips_and_updates;
    }
  }

  Color _getFeedbackColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.correction:
        return Colors.orange;
      case FeedbackType.explanation:
        return Colors.blue;
      case FeedbackType.encouragement:
        return Colors.green;
      case FeedbackType.suggestion:
        return Colors.purple;
    }
  }

  String _getFeedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.correction:
        return '訂正';
      case FeedbackType.explanation:
        return '説明';
      case FeedbackType.encouragement:
        return '励まし';
      case FeedbackType.suggestion:
        return '提案';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  // _buildAiFeedbackBottomSheet() is no longer used for the primary layout.
  // It can be removed if not needed elsewhere.

  // Build chat bubble for both user and AI messages
  Widget _buildChatBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    final isStreaming = message['isStreaming'] == true;
    final messageText = message['message'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                messageText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            else
              // For AI messages, use GptMarkdown for proper markdown and LaTeX rendering
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GptMarkdown(
                    messageText,
                    onLinkTap: (url, title) {
                      debugPrint(url);
                      debugPrint(title);
                    },
                    useDollarSignsForLatex: true,
                    textAlign: TextAlign.start,
                    textScaler: const TextScaler.linear(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    highlightBuilder: (context, text, style) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: style.fontSize != null ? style.fontSize! * 0.9 : 13.5,
                            height: style.height,
                          ),
                        ),
                      );
                    },
                    latexWorkaround: (tex) {
                      List<String> stack = [];
                      tex = tex.splitMapJoin(
                        RegExp(r"\\text\{|\{|\}|\_"),
                        onMatch: (p) {
                          String input = p[0] ?? "";
                          if (input == r"\text{") {
                            stack.add(input);
                          }
                          if (stack.isNotEmpty) {
                            if (input == r"{") {
                              stack.add(input);
                            }
                            if (input == r"}") {
                              stack.removeLast();
                            }
                            if (input == r"_") {
                              return r"\_";
                            }
                          }
                          return input;
                        },
                      );
                      return tex.replaceAllMapped(
                        RegExp(r"align\*"),
                        (match) => "aligned",
                      );
                    },
                    imageBuilder: (context, url) {
                      return Image.network(url, width: 100, height: 100);
                    },
                    latexBuilder: (context, tex, textStyle, inline) {
                      if (tex.contains(r"\begin{tabular}")) {
                        // return table.
                        String tableString =
                            "|${(RegExp(r"^\\begin\{tabular\}\{.*?\}(.*?)\\end\{tabular\}$", multiLine: true, dotAll: true).firstMatch(tex)?[1] ?? "").trim()}|";
                        tableString = tableString
                            .replaceAll(r"\\", "|\n|")
                            .replaceAll(r"\hline", "")
                            .replaceAll(RegExp(r"(?<!\\)&"), "|");
                        var tableStringList = tableString.split("\n")
                          ..insert(1, "|---|");
                        tableString = tableStringList.join("\n");
                        return GptMarkdown(tableString);
                      }
                      var controller = ScrollController();
                      Widget child = Math.tex(tex, textStyle: textStyle);
                      if (!inline) {
                        child = Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Material(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Scrollbar(
                                controller: controller,
                                child: SingleChildScrollView(
                                  controller: controller,
                                  scrollDirection: Axis.horizontal,
                                  child: Math.tex(tex, textStyle: textStyle),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      child = SelectableAdapter(
                        selectedText: tex,
                        child: Math.tex(tex),
                      );
                      child = InkWell(
                        onTap: () {
                          debugPrint("Hello world");
                        },
                        child: child,
                      );
                      return child;
                    },
                    sourceTagBuilder: (buildContext, string, textStyle) {
                      var value = int.tryParse(string);
                      value ??= -1;
                      value += 1;
                      return SizedBox(
                        height: 20,
                        width: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text("$value")),
                        ),
                      );
                    },
                    linkBuilder: (context, label, path, style) {
                      return Text(
                        label,
                        style: style.copyWith(color: Colors.blue),
                      );
                    },
                  ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Typing...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCommonQuestionsChipRow() {
    final List<String> commonQuestions = [
      "How do I solve for x?",
      "What is the Pythagorean theorem?",
      "What's the derivative of x^n?",
      "What's the integral of 1/x?",
      "What's the quadratic formula?",
      "How do I find the area of a circle?",
      "How do I find circumference?"
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
                    onPressed: _isSendingMessage || widget.problem?.id == null
                        ? null
                        : () async {
                            await _sendChatMessage(question);
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
