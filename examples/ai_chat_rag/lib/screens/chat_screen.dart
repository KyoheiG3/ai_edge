import 'dart:convert';

import 'package:ai_edge_rag/ai_edge_rag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/chat_message.dart';
import '../models/gemma_model.dart';

class ChatScreen extends StatefulWidget {
  final GemmaModel model;
  final String modelPath;
  final String tokenizerModelPath;
  final String embeddingModelPath;

  const ChatScreen({
    super.key,
    required this.model,
    required this.modelPath,
    required this.tokenizerModelPath,
    required this.embeddingModelPath,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AiEdgeRag _aiEdgeRag = AiEdgeRag.instance;
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
    setState(() => _isLoading = true);

    try {
      // Set up system instruction
      await _configureSystemInstruction();

      // Initialize model
      await _initializeModel();

      // Create embedding model
      await _createEmbeddingModel();

      // Load and memorize context
      await _loadAndMemorizeContext();

      // Update UI state
      _onModelLoadSuccess();
    } catch (e, stackTrace) {
      _onModelLoadError(e, stackTrace);
    }
  }

  Future<void> _configureSystemInstruction() async {
    await _aiEdgeRag.setSystemInstruction(
      SystemInstruction(
        instruction:
            'You are an assistant for question-answering tasks. '
            'Here are the things I want to remember: {0} Use the things I want to remember, '
            'answer the following question the user has: {1}',
      ),
    );
  }

  Future<void> _initializeModel() async {
    await _aiEdgeRag.initialize(
      modelPath: widget.modelPath,
      maxTokens: 256,
      temperature: 0.7,
      randomSeed: 42,
      topK: 20,
      // preferredBackend: PreferredBackend.gpu,
    );
  }

  Future<void> _createEmbeddingModel() async {
    await _aiEdgeRag.createEmbeddingModel(
      tokenizerModelPath: widget.tokenizerModelPath,
      embeddingModelPath: widget.embeddingModelPath,
    );
  }

  Future<void> _loadAndMemorizeContext() async {
    const chunkSeparator = '<chunk_splitter>';

    // Load sample context from assets
    final assetContent = await rootBundle.loadString(
      'assets/sample_context.txt',
    );
    final lines = const LineSplitter().convert(assetContent);

    final sb = StringBuffer();
    String text = '';

    for (final line in lines) {
      if (line.startsWith(chunkSeparator)) {
        if (sb.isNotEmpty) {
          final chunk = sb.toString();
          text += chunk;
        }
        sb.clear();
        sb.write(line.substring(chunkSeparator.length).trim());
      } else {
        sb.write(' ');
        sb.write(line);
      }
    }

    if (sb.isNotEmpty) {
      text += sb.toString();
    }

    await _aiEdgeRag.memorizeChunkedText(text, chunkSize: 50);
  }

  void _onModelLoadSuccess() {
    setState(() {
      _isModelLoaded = true;
      _isLoading = false;
      _messages.add(
        ChatMessage(
          content:
              'Model "${widget.model.name}" loaded successfully. '
              'Ask me questions about your interests, hobbies, and preferences!',
          type: MessageType.system,
        ),
      );
    });
  }

  void _onModelLoadError(Object error, StackTrace stackTrace) {
    debugPrint('[ChatScreen] Failed to load model: $error');
    debugPrint('[ChatScreen] Stack trace: $stackTrace');
    setState(() {
      _isLoading = false;
      _messages.add(
        ChatMessage(
          content: 'Failed to load model: $error',
          type: MessageType.system,
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (!_canSendMessage(message)) return;

    _prepareMessageSend(message);

    try {
      _addAssistantPlaceholder();
      await _processStreamingResponse(message);
    } catch (e, stackTrace) {
      _handleMessageError(e, stackTrace);
    } finally {
      _finalizeMessageSend();
    }
  }

  bool _canSendMessage(String message) {
    return message.isNotEmpty && _isModelLoaded && !_isGenerating;
  }

  void _prepareMessageSend(String message) {
    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(content: message, type: MessageType.user));
      _isGenerating = true;
    });
    _scrollToBottom();
  }

  void _addAssistantPlaceholder() {
    setState(() {
      _messages.add(ChatMessage(content: '', type: MessageType.assistant));
    });
  }

  Future<void> _processStreamingResponse(String message) async {
    final responseStream = _aiEdgeRag.generateResponseAsync(message);

    await for (final event in responseStream) {
      if (!mounted) return;

      _updateAssistantMessage(event.partialResult);
      _scrollToBottom();

      if (event.done) break;
    }
  }

  void _updateAssistantMessage(String content) {
    setState(() {
      _messages[_messages.length - 1] = ChatMessage(
        content: content,
        type: MessageType.assistant,
      );
    });
  }

  void _handleMessageError(Object error, StackTrace stackTrace) {
    debugPrint('[ChatScreen] Error generating response: $error');
    debugPrint('[ChatScreen] Stack trace: $stackTrace');
    setState(() {
      _messages[_messages.length - 1] = ChatMessage(
        content: 'Error generating response: $error',
        type: MessageType.system,
      );
    });
  }

  void _finalizeMessageSend() {
    if (mounted) {
      setState(() => _isGenerating = false);
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

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Clean up model and session when disposing
    _aiEdgeRag.close();
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick action chips
                if (_isModelLoaded && !_isGenerating)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionChip(
                          label: '🎬 What do I like?',
                          onTap: () =>
                              _sendQuickMessage('What do I like to do?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🧗 Tell me about my hobbies',
                          onTap: () =>
                              _sendQuickMessage('What are my hobbies?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '✈️ Where have I traveled?',
                          onTap: () => _sendQuickMessage(
                            'How many countries have I traveled to?',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🏀 What sports do I like?',
                          onTap: () =>
                              _sendQuickMessage('What sports do I enjoy?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '😨 What am I afraid of?',
                          onTap: () =>
                              _sendQuickMessage('What am I afraid of?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🎓 What did I study?',
                          onTap: () =>
                              _sendQuickMessage('What did I study in college?'),
                        ),
                      ],
                    ),
                  ),
                // Input field and send button
                Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 14,
            ),
          ),
        ),
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
