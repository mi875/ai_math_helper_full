import 'dart:async';
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
import 'package:ai_math_helper/data/notebook/data/chat_message.dart';
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
  late DraggableScrollableController _draggableController;

  // AI feedback state
  List<AiFeedback> _aiFeedbacks = [];
  bool _isGeneratingFeedback = false;
  final GlobalKey _scribbleKey = GlobalKey();

  // Drawing state
  bool _isErasing = false;

  // Chat message state with conversation memory
  final TextEditingController _messageController = TextEditingController();
  bool _isSendingMessage = false;
  List<ChatMessage> _chatMessages =
      []; // Store both user and AI messages with memory context
  String? _threadId; // Current conversation thread ID
  String? _resourceId; // Current resource ID for memory scoping
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    // Fixed canvas size for consistent AI processing and cost reduction
    const fixedCanvasSize = Size(1500, 1024);

    notifier = ScribbleNotifier(
      fixedStrokeWidth: 2,
      canvasSize: fixedCanvasSize,
      allowedPointersMode: ScribblePointerMode.mouseAndPen,
    );
    // Set the color to black immediately
    notifier.setColor(Colors.black);
    _draggableController = DraggableScrollableController();
    // Load conversation history when the widget initializes
    if (widget.problem?.id != null) {
      _loadChatHistory();
      _loadProblemImageAsBackground();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setThemeAwarePenColor();
  }

  @override
  void didUpdateWidget(MathInputScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload background image if problem changed
    if (oldWidget.problem?.id != widget.problem?.id &&
        widget.problem?.id != null) {
      _loadProblemImageAsBackground();
      _loadChatHistory();
    }
  }

  void _setThemeAwarePenColor() {
    // Always use black stroke color
    const penColor = Colors.black;

    // Try to set pen color if the method exists
    try {
      notifier.setColor(penColor);
    } catch (e) {
      // If setColor doesn't exist, the pen will use default color
    }
  }

  void _expandSheet() {
    _draggableController.animateTo(
      0.9, // Expand to maximum size
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleDrawingMode() {
    setState(() {
      _isErasing = !_isErasing;
      if (_isErasing) {
        notifier.setEraser();
      } else {
        notifier.setDrawing();
        notifier.setColor(Colors.black);
      }
    });
  }

  void _resetView() {
    // Reset the scribble view to center and default zoom
    ScribbleInteractive.resetView(context);
  }

  void _checkAnswer() {
    // TODO: Implement answer checking logic
    // This could integrate with the AI system to evaluate the drawn solution
    debugPrint('Check Answer button pressed');

    // Show a snackbar as feedback for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer checking functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Load the problem image as background for the scribble canvas
  Future<void> _loadProblemImageAsBackground() async {
    if (widget.problem?.images.isEmpty ?? true) return;

    try {
      final firstImage = widget.problem!.images.first;
      final imageProvider = AuthenticatedNetworkImage(firstImage.fileUrl);

      // Get the natural image dimensions
      Size naturalSize;
      if (firstImage.width != null && firstImage.height != null) {
        // Use dimensions from the database if available
        naturalSize = Size(firstImage.width!.toDouble(), firstImage.height!.toDouble());
      } else {
        // Fallback: Load the image to get its natural dimensions
        naturalSize = await _getImageNaturalSize(imageProvider);
      }

      // Scale down the image to make it smaller (50% of natural size)
      const double scaleFactor = 0.5;
      final Size scaledSize = Size(
        naturalSize.width * scaleFactor,
        naturalSize.height * scaleFactor,
      );

      // Set the problem image as background with the scaled size
      // The image will be fitted to maintain aspect ratio within the canvas
      notifier.setBackgroundImageWithSizeAndOffset(
        imageProvider,
        scaledSize,
        Offset.zero, // Center the image
      );
    } catch (error) {
      debugPrint('Error loading problem image as background: $error');
    }
  }

  // Helper method to get the natural size of an image
  Future<Size> _getImageNaturalSize(ImageProvider imageProvider) async {
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer<Size>();
    
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      final image = info.image;
      completer.complete(Size(image.width.toDouble(), image.height.toDouble()));
      stream.removeListener(listener);
    }, onError: (exception, stackTrace) {
      // Fallback to a reasonable default size
      completer.complete(const Size(512, 256));
      stream.removeListener(listener);
    });
    
    stream.addListener(listener);
    return completer.future;
  }

  // Load conversation history for the current problem
  Future<void> _loadChatHistory() async {
    if (widget.problem?.id == null) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final historyData = await ApiService.getChatHistory(widget.problem!.id);

      if (historyData != null) {
        final historyMessages = ApiService.parseChatHistory(historyData);

        setState(() {
          _chatMessages =
              historyMessages.reversed.toList(); // Reverse to show newest first
          _threadId = historyData['threadId'] as String?;
          _resourceId = historyData['resourceId'] as String?;
        });

        debugPrint(
          'Loaded ${historyMessages.length} messages from chat history',
        );
      }
    } catch (error) {
      debugPrint('Error loading chat history: $error');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
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

  // Send chat message to AI with conversation memory
  Future<void> _sendChatMessage(String message) async {
    if (message.trim().isEmpty || widget.problem?.id == null) {
      return;
    }

    // Create user message with thread context
    final userMessage = ChatMessage.user(
      message: message,
      threadId: _threadId,
      resourceId: _resourceId,
    );

    // Add user message to chat
    setState(() {
      _isSendingMessage = true;
      _chatMessages.insert(0, userMessage);
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

      // Create temporary streaming AI message
      final streamingMessage = ChatMessage.aiStreaming(
        message: '',
        threadId: _threadId,
        resourceId: _resourceId,
      );

      // Add temporary AI message to chat
      setState(() {
        _aiFeedbacks.insert(0, tempFeedback);
        _chatMessages.insert(0, streamingMessage);
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
                _currentStreamingText =
                    chunk['message'] ?? 'AI is responding...';
                _aiFeedbacks[0] = _aiFeedbacks[0].copyWith(
                  message: _currentStreamingText,
                );
                _chatMessages[0] = _chatMessages[0].copyWith(
                  message: _currentStreamingText,
                );
              });
              break;

            case 'chunk':
              setState(() {
                _currentStreamingText = chunk['fullText'] ?? '';
                _aiFeedbacks[0] = _aiFeedbacks[0].copyWith(
                  message: _currentStreamingText,
                );
                _chatMessages[0] = _chatMessages[0].copyWith(
                  message: _currentStreamingText,
                );
              });
              break;

            case 'complete':
              final completedFeedback = AiFeedback(
                id: chunk['id'],
                message: chunk['message'],
                timestamp: DateTime.parse(chunk['timestamp']),
                type: _parseFeedbackType(chunk['feedbackType']),
              );

              final completedMessage = ChatMessage.ai(
                id: chunk['id'],
                message: chunk['message'],
                timestamp: DateTime.parse(chunk['timestamp']),
                feedbackType: chunk['feedbackType'],
                threadId: _threadId,
                resourceId: _resourceId,
                tokensConsumed: chunk['tokensConsumed'] as int?,
              );

              setState(() {
                _aiFeedbacks[0] = completedFeedback;
                _chatMessages[0] = completedMessage;
                // Update thread info if returned from backend
                _threadId ??= chunk['threadId'] as String?;
                _resourceId ??= chunk['resourceId'] as String?;
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
            _chatMessages[0] = _chatMessages[0].copyWith(
              message: _currentStreamingText,
            );
          });

          final feedback = await ApiService.generateAiFeedback(
            widget.problem!.id,
            canvasImageBytes ?? Uint8List(0),
            customMessage: message,
          );

          if (feedback != null) {
            final fallbackMessage = ChatMessage.ai(
              id: feedback.id,
              message: feedback.message,
              timestamp: feedback.timestamp,
              feedbackType: feedback.type.toString().split('.').last,
              threadId: _threadId,
              resourceId: _resourceId,
            );

            setState(() {
              _aiFeedbacks[0] = feedback;
              _chatMessages[0] = fallbackMessage;
            });
          } else {
            throw Exception('Fallback API also failed');
          }
        } catch (fallbackError) {
          if (_aiFeedbacks.isNotEmpty &&
              _aiFeedbacks[0].id == 'streaming-temp') {
            setState(() {
              _aiFeedbacks.removeAt(0);
            });
          }
          if (_chatMessages.isNotEmpty &&
              _chatMessages[0].state == ConversationState.streaming) {
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
      if (_chatMessages.isNotEmpty &&
          _chatMessages[0].state == ConversationState.streaming) {
        setState(() {
          _chatMessages.removeAt(0);
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $error')));
    } finally {
      setState(() {
        _isSendingMessage = false;
        _currentStreamingText = '';
      });
    }
  }

  // Send text-only message without canvas for pure conversation
  Future<void> _sendTextOnlyMessage(String message) async {
    if (message.trim().isEmpty || widget.problem?.id == null) {
      return;
    }

    // Create user message with thread context
    final userMessage = ChatMessage.user(
      message: message,
      threadId: _threadId,
      resourceId: _resourceId,
    );

    // Add user message to chat
    setState(() {
      _isSendingMessage = true;
      _chatMessages.insert(0, userMessage);
    });

    try {
      // Send text-only message to API
      final responseData = await ApiService.sendTextMessage(
        widget.problem!.id,
        message,
      );

      if (responseData != null) {
        final aiMessage = ApiService.parseMessageResponse(
          responseData,
          threadId: _threadId,
          resourceId: _resourceId,
        );

        setState(() {
          _chatMessages.insert(0, aiMessage);
          // Update thread info if not already set
          _threadId ??= aiMessage.threadId;
          _resourceId ??= aiMessage.resourceId;
        });
      } else {
        throw Exception('Failed to get response from AI');
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $error')));
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  // Capture the scribble canvas as an image (includes background image and drawings)
  Future<Uint8List?> _captureCanvasAsImage() async {
    try {
      // Get the render object of the scribble widget
      final RenderRepaintBoundary boundary =
          _scribbleKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary;

      // Convert to image with fixed canvas size for consistent AI processing
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (error) {
      debugPrint('Error capturing canvas: $error');
      return null;
    }
  }

  @override
  void dispose() {
    notifier.dispose();
    _messageController.dispose();
    _draggableController.dispose();
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
        title: const Text('Math Input'),
        actions: [
          IconButton(
            icon: Icon(_isErasing ? Icons.edit : Icons.auto_fix_high),
            onPressed: _toggleDrawingMode,
            tooltip: _isErasing ? 'Switch to pen' : 'Switch to eraser',
            color: _isErasing ? Colors.red : null,
          ),
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
            onPressed: _resetView,
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
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: RepaintBoundary(
              key: _scribbleKey,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: SizedBox.expand(
                  child: ScribbleInteractive(
                    notifier: notifier,
                    drawPen: true,
                    fixedStrokeWidth: 1.0,

                    backgroundImageFit: BoxFit.contain,
                  ),
                ),
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
                controller: _draggableController,
                initialChildSize: 0.5,
                minChildSize: 0.4,
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Draggable top area (Drag Handle + Title)
                        GestureDetector(
                          onTap: _expandSheet,
                          onPanUpdate: (details) {
                            // Calculate the new position based on pan delta
                            final RenderBox renderBox = context.findRenderObject() as RenderBox;
                            final screenHeight = MediaQuery.of(context).size.height;
                            final currentPosition = _draggableController.size;
                            
                            // Convert pan delta to sheet position change (negative because dragging up decreases position)
                            final deltaY = -details.delta.dy / screenHeight;
                            final newPosition = (currentPosition + deltaY).clamp(0.4, 0.9);
                            
                            _draggableController.jumpTo(newPosition);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag Handle
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Container(
                                    width: 32,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                  ),
                                ),
                              ),
                              // Title and Width Toggle Button
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  top: 0,
                                  bottom: 4.0,
                                  right:
                                      4.0, // Added right padding for the button
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    GestureDetector(
                                      onTap: () {
                                        // Prevent the expand gesture when tapping the width toggle
                                      },
                                      child: IconButton(
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
                                    ),
                                  ],
                                ),
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
                                      mainAxisSize: MainAxisSize.min,
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
                          padding: const EdgeInsets.fromLTRB(
                            8.0,
                            8.0,
                            8.0,
                            32.0,
                          ),
                          child: TextField(
                            controller: _messageController,
                            enabled:
                                !_isSendingMessage &&
                                widget.problem?.id != null,
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
                                icon:
                                    _isSendingMessage
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Icon(
                                          Icons.send,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                onPressed:
                                    _isSendingMessage ||
                                            widget.problem?.id == null
                                        ? null
                                        : () async {
                                          final message =
                                              _messageController.text.trim();
                                          if (message.isNotEmpty) {
                                            _messageController.clear();
                                            // Use text-only message for regular chat input
                                            await _sendTextOnlyMessage(message);
                                          }
                                        },
                              ),
                            ),
                            onSubmitted:
                                _isSendingMessage || widget.problem?.id == null
                                    ? null
                                    : (message) async {
                                      if (message.trim().isNotEmpty) {
                                        _messageController.clear();
                                        // Use text-only message for regular chat input
                                        await _sendTextOnlyMessage(
                                          message.trim(),
                                        );
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
  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    final isStreaming = message.state == ConversationState.streaming;
    final messageText = message.message;
    final timestamp = message.timestamp;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              isUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                mainAxisSize: MainAxisSize.min,
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
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
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
                        label.toString(),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withValues(alpha: 0.7),
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
                color:
                    isUser
                        ? Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                        : Theme.of(context).colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.7),
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
      "How do I find circumference?",
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
                    onPressed:
                        _isSendingMessage || widget.problem?.id == null
                            ? null
                            : () async {
                              // Use text-only message for common questions
                              await _sendTextOnlyMessage(question);
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
