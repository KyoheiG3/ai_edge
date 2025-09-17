import 'dart:math';

import 'package:ai_edge_fc/ai_edge_fc.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/gemma_model.dart';

class ChatScreen extends StatefulWidget {
  final GemmaModel model;
  final String modelPath;

  const ChatScreen({super.key, required this.model, required this.modelPath});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AiEdgeFc _aiEdgeFc = AiEdgeFc.instance;
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
      // Initialize model with configuration
      await _initializeModel();

      // Set up system instruction
      await _configureSystemInstruction();

      // Register available functions
      await _registerFunctions();

      // Create chat session
      await _aiEdgeFc.createSession();

      // Update UI state
      _onModelLoadSuccess();
    } catch (e, stackTrace) {
      _onModelLoadError(e, stackTrace);
    }
  }

  Future<void> _initializeModel() async {
    await _aiEdgeFc.createModel(
      modelPath: widget.modelPath,
      maxTokens: 4096,
      // preferredBackend: PreferredBackend.gpu,
    );
  }

  Future<void> _configureSystemInstruction() async {
    await _aiEdgeFc.setSystemInstruction(
      SystemInstruction(
        instruction:
            'You are a helpful assistant with access to functions. '
            'When asked about time, use get_current_time function. '
            'When asked about weather, use get_weather function. '
            'When asked to calculate, use calculate function. '
            'Always use the appropriate function to answer questions.',
      ),
    );
  }

  Future<void> _registerFunctions() async {
    final functions = _createFunctionDeclarations();
    await _aiEdgeFc.setFunctions(functions);
  }

  void _onModelLoadSuccess() {
    setState(() {
      _isModelLoaded = true;
      _isLoading = false;
      _messages.add(
        ChatMessage(
          content:
              'Model "${widget.model.name}" loaded successfully. '
              'I can check time, weather, and do calculations for you. '
              'How can I assist you today?',
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

  List<FunctionDeclaration> _createFunctionDeclarations() {
    return [
      FunctionDeclaration(
        name: 'get_current_time',
        description: 'Get the current date and time',
        properties: [],
      ),
      FunctionDeclaration(
        name: 'get_weather',
        description: 'Get current weather for a location',
        properties: [
          FunctionProperty(
            name: 'location',
            description: 'City name',
            type: PropertyType.string,
            required: true,
          ),
        ],
      ),
      FunctionDeclaration(
        name: 'calculate',
        description: 'Perform math calculations',
        properties: [
          FunctionProperty(
            name: 'expression',
            description: 'Math expression like "2+2" or "10*5"',
            type: PropertyType.string,
            required: true,
          ),
        ],
      ),
    ];
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (!_canSendMessage(message)) return;

    _prepareMessageSend(message);

    try {
      _addAssistantPlaceholder();

      final response = await _aiEdgeFc.sendMessage(
        Message(role: 'user', text: message),
      );

      await _processResponse(response);
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

  Future<void> _processResponse(GenerateContentResponse response) async {
    final functionCall = response.functionCall;
    String finalResponse = response.text ?? '';

    if (functionCall != null) {
      finalResponse = await _handleFunctionCall(functionCall);
    }

    _updateAssistantMessage(finalResponse);
    _scrollToBottom();
  }

  Future<String> _handleFunctionCall(FunctionCall functionCall) async {
    // Execute the function
    final result = _executeFunction(functionCall);

    // Show function call in UI
    _showFunctionCallIndicator(functionCall.name);

    // Send result back to model
    final functionResponse = FunctionResponse(
      role: 'user',
      functionCall: functionCall,
      response: result,
    );

    final followUp = await _aiEdgeFc.sendFunctionResponse(functionResponse);

    // Check for chained function calls
    if (followUp.functionCall != null) {
      return await _handleFunctionCall(followUp.functionCall!);
    }

    return followUp.text ?? 'Function executed successfully';
  }

  void _showFunctionCallIndicator(String functionName) {
    setState(() {
      _messages.insert(
        _messages.length - 1,
        ChatMessage(
          content: '🔧 Calling function: $functionName',
          type: MessageType.system,
        ),
      );
    });
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

  Map<String, dynamic> _executeFunction(FunctionCall functionCall) {
    try {
      final args = functionCall.args.fields;

      return switch (functionCall.name) {
        'get_current_time' => _getCurrentTime(),
        'get_weather' => _getWeather(args),
        'calculate' => _calculate(args),
        _ => {'error': 'Unknown function: ${functionCall.name}'},
      };
    } catch (e) {
      return {'error': 'Failed to execute function: ${e.toString()}'};
    }
  }

  Map<String, dynamic> _getCurrentTime() {
    final now = DateTime.now();
    return {'time': now.toIso8601String(), 'formatted': now.toString()};
  }

  Map<String, dynamic> _getWeather(Map<String, dynamic> args) {
    final location = args['location'] ?? 'Unknown';
    final unit = args['unit'] ?? 'celsius';

    // Simulate weather data (in a real app, this would call a weather API)
    final random = Random();
    final temperature = 15 + random.nextInt(20);
    final conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy', 'Clear'];
    final condition = conditions[random.nextInt(conditions.length)];
    final humidity = 40 + random.nextInt(40);
    final windSpeed = 5 + random.nextInt(15);

    final tempValue = unit == 'fahrenheit'
        ? (temperature * 9 / 5 + 32).round()
        : temperature;
    final tempUnit = unit == 'fahrenheit' ? '°F' : '°C';

    return {
      'location': location,
      'temperature': tempValue,
      'unit': tempUnit,
      'condition': condition,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'description':
          'Current weather in $location: $condition, $tempValue$tempUnit, '
          'Humidity: $humidity%, Wind: ${windSpeed}km/h',
    };
  }

  Map<String, dynamic> _calculate(Map<String, dynamic> args) {
    final expression = args['expression'] ?? '';

    try {
      // Simple calculator implementation
      final result = _evaluateExpression(expression);

      return {
        'expression': expression,
        'result': result,
        'formatted': '$expression = $result',
      };
    } catch (e) {
      return {
        'error': 'Invalid expression: $expression',
        'details': e.toString(),
      };
    }
  }

  double _evaluateExpression(String expression) {
    // Very basic expression evaluator for demo purposes
    expression = expression.replaceAll(' ', '');

    // Handle sqrt
    if (expression.startsWith('sqrt(') && expression.endsWith(')')) {
      final value = double.parse(
        expression.substring(5, expression.length - 1),
      );
      return sqrt(value);
    }

    // Handle basic arithmetic
    if (expression.contains('+')) {
      final parts = expression.split('+');
      return double.parse(parts[0]) + double.parse(parts[1]);
    }
    if (expression.contains('-')) {
      final parts = expression.split('-');
      return double.parse(parts[0]) - double.parse(parts[1]);
    }
    if (expression.contains('*')) {
      final parts = expression.split('*');
      return double.parse(parts[0]) * double.parse(parts[1]);
    }
    if (expression.contains('/')) {
      final parts = expression.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }

    // If no operation, try to parse as number
    return double.parse(expression);
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
    _aiEdgeFc.close();
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
                          label: '🕐 What time is it?',
                          onTap: () => _sendQuickMessage('What time is it?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🌤️ Weather in Tokyo',
                          onTap: () => _sendQuickMessage(
                            'What\'s the weather in Tokyo?',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🧮 Calculate 15% tip on \$85',
                          onTap: () => _sendQuickMessage(
                            'Calculate 15% tip on 85 dollars',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '➕ 25 + 37',
                          onTap: () => _sendQuickMessage('What is 25 + 37?'),
                        ),
                        const SizedBox(width: 8),
                        _QuickActionChip(
                          label: '🌡️ Weather in New York',
                          onTap: () => _sendQuickMessage(
                            'How\'s the weather in New York?',
                          ),
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
