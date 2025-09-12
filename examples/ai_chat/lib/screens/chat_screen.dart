import 'package:flutter/material.dart';
import 'package:ai_edge/ai_edge.dart';
import '../models/gemma_model.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final GemmaModel model;
  final String modelPath;

  const ChatScreen({super.key, required this.model, required this.modelPath});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AiEdge _aiEdge = AiEdge.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isModelLoaded = false;
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize model and session with new unified method
      await _aiEdge.initialize(
        modelPath: widget.modelPath,
        maxTokens: 256, // Reduced for testing
        // preferredBackend: PreferredBackend.gpu,
        sessionConfig: SessionConfig(
          temperature: 0.7,
          randomSeed: 42,
          topK: 20, // Reduced for testing
        ),
      );

      setState(() {
        _isModelLoaded = true;
        _isLoading = false;
        _messages.add(
          ChatMessage(
            content:
                'Model "${widget.model.name}" loaded successfully. How can I help you today?',
            type: MessageType.system,
          ),
        );
      });
    } catch (e, stackTrace) {
      debugPrint('[ChatScreen] Failed to load model: $e');
      debugPrint('[ChatScreen] Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            content: 'Failed to load model: $e',
            type: MessageType.system,
          ),
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || !_isModelLoaded || _isGenerating) return;

    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(content: message, type: MessageType.user));
      _isGenerating = true;
    });

    _scrollToBottom();

    try {
      // Add a placeholder for the AI response
      setState(() {
        _messages.add(ChatMessage(content: '', type: MessageType.assistant));
      });

      // Use streaming response
      // Note: We need to listen to the stream before calling generateResponseAsync
      final responseStream = _aiEdge.generateResponseAsync(message);
      String fullResponse = '';

      await for (final event in responseStream) {
        if (!mounted) {
          return;
        }

        // Accumulate the response tokens
        fullResponse += event.partialResult;

        // Update UI with accumulated response
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            content: fullResponse,
            type: MessageType.assistant,
          );
        });
        _scrollToBottom();

        // Check if response is complete
        if (event.done) {
          break;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[ChatScreen] Error generating response: $e');
      debugPrint('[ChatScreen] Stack trace: $stackTrace');
      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          content: 'Error generating response: $e',
          type: MessageType.system,
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Clean up model and session when disposing
    _aiEdge.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator()
          else if (!_isModelLoaded)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Model not loaded'),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: _isModelLoaded && !_isGenerating,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isModelLoaded && !_isGenerating
                      ? _sendMessage
                      : null,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: isSystem
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                isSystem ? Icons.info : Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : isSystem
                    ? Colors.grey.shade200
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
