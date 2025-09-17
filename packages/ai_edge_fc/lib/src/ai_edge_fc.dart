import 'package:ai_edge/ai_edge.dart';
import 'package:ai_edge_fc/src/model/content.dart';
import 'package:ai_edge_fc/src/model/model_formatter.dart';
import 'package:ai_edge_fc/src/model/models.dart';
import 'package:flutter/services.dart';

import 'ai_edge_fc_platform_interface.dart';

export 'package:ai_edge/ai_edge.dart'
    show ModelConfig, SessionConfig, PreferredBackend;

/// A Flutter plugin for on-device AI inference with function calling support.
///
/// The `AiEdgeFc` class extends the capabilities of the base [AiEdge] plugin
/// by adding support for function calling, system instructions, constraints,
/// and conversation history management. It provides a unified interface for
/// running large language models with tool use capabilities directly on mobile
/// devices through MediaPipe's GenAI framework.
///
/// ## Features
/// - All features from the base [AiEdge] plugin
/// - Function calling with tool declarations
/// - System instructions for behavior customization
/// - Conversation history tracking and management
/// - Output constraints for controlled generation
/// - Session cloning for branching conversations
///
/// ## Usage
///
/// ### Basic Initialization
/// ```dart
/// final aiEdgeFc = AiEdgeFc.instance;
/// await aiEdgeFc.initialize(
///   modelPath: '/path/to/model.task',
///   maxTokens: 512,
/// );
/// ```
///
/// ### Function Calling
/// ```dart
/// // Declare functions
/// final functions = [
///   FunctionDeclaration(
///     name: 'get_weather',
///     description: 'Get the current weather',
///     properties: [
///       FunctionProperty(
///         name: 'location',
///         description: 'City name',
///         required: true,
///       ),
///     ],
///   ),
/// ];
///
/// await aiEdgeFc.setFunctions(functions);
///
/// // Send message and handle function calls
/// final response = await aiEdgeFc.sendMessage(
///   Message(role: 'user', text: 'What\'s the weather in Tokyo?'),
/// );
/// ```
///
/// ### System Instructions
/// ```dart
/// await aiEdgeFc.setSystemInstruction(
///   SystemInstruction(
///     instruction: 'You are a helpful assistant. Be concise.',
///   ),
/// );
/// ```
///
/// ## Platform Requirements
/// - iOS: Requires iOS 15.0 or later with MediaPipe GenAI iOS framework
/// - Android: Requires Android API level 24 or later with MediaPipe GenAI Android library
///
/// ## Model Format
/// Supports MediaPipe Task models (.task files) compatible with the GenAI runtime.
/// Models must be optimized for mobile inference with appropriate quantization.
class AiEdgeFc {
  static final AiEdgeFc _instance = AiEdgeFc._();

  AiEdgeFc._();

  /// Returns the singleton instance of [AiEdgeFc].
  ///
  /// This plugin uses a singleton pattern to ensure only one model and session
  /// are active at a time, managing resources efficiently on mobile devices.
  ///
  /// Example:
  /// ```dart
  /// final aiEdgeFc = AiEdgeFc.instance;
  /// ```
  static AiEdgeFc get instance => _instance;

  /// Creates and loads an AI model with the specified configuration.
  ///
  /// This method initializes the MediaPipe GenAI inference engine with the provided
  /// model file and configuration parameters. The model must be in MediaPipe Task
  /// format (.task file).
  ///
  /// Parameters:
  /// - [modelPath]: Path to the MediaPipe Task model file (required)
  /// - [maxTokens]: Maximum number of tokens the model can generate. Default: 1024
  /// - [supportedLoraRanks]: Optional LoRA adapter ranks. Default: null
  /// - [preferredBackend]: Hardware acceleration preference (Android only). Default: null
  /// - [maxNumImages]: Maximum number of images for multi-modal input. Default: null
  ///
  /// Throws an exception if the model file cannot be loaded or is incompatible.
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.createModel(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 1024,
  ///   preferredBackend: PreferredBackend.gpu,
  /// );
  /// ```
  Future<void> createModel({
    required String modelPath,
    int? maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
  }) {
    final config = ModelConfig(
      modelPath: modelPath,
      maxTokens: maxTokens,
      supportedLoraRanks: supportedLoraRanks,
      preferredBackend: preferredBackend,
      maxNumImages: maxNumImages,
    );
    return AiEdgeFcPlatform.instance.createModel(config.toMap());
  }

  /// Creates a new inference session with the specified configuration.
  ///
  /// A session manages the conversation context and generation parameters.
  /// Multiple sessions can be created sequentially, but only one session
  /// is active at a time.
  ///
  /// Parameters (all optional with defaults):
  /// - [temperature]: Controls randomness (0.0-1.0). Default: 0.8
  /// - [randomSeed]: For reproducible outputs. Default: 1
  /// - [topK]: Top-K sampling parameter. Default: 40
  /// - [topP]: Top-P nucleus sampling. Default: null
  /// - [loraPath]: Path to LoRA adapter. Default: null
  /// - [enableVisionModality]: Enable vision features. Default: null
  /// - [formatter]: Model formatter type. Default: ModelFormatter.gemma
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.createSession(
  ///   temperature: 0.7,
  ///   topK: 40,
  ///   topP: 0.95,
  ///   formatter: ModelFormatter.llama,
  /// );
  /// ```
  Future<void> createSession({
    double? temperature,
    int? randomSeed,
    int? topK,
    double? topP,
    String? loraPath,
    bool? enableVisionModality,
    ModelFormatter? formatter,
  }) {
    final config = SessionConfig(
      temperature: temperature,
      randomSeed: randomSeed,
      topK: topK,
      topP: topP,
      loraPath: loraPath,
      enableVisionModality: enableVisionModality,
    );
    final args = config.toMap();
    args['formatter'] = (formatter ?? ModelFormatter.gemma).value;
    return AiEdgeFcPlatform.instance.createSession(args);
  }

  /// Convenience method to initialize both model and session in a single call.
  ///
  /// This method combines [createModel] and [createSession] for simplified setup.
  /// It's the recommended way to initialize the AI Edge FC plugin for most use cases.
  ///
  /// Parameters:
  /// - [modelPath]: Path to the MediaPipe Task model file (required)
  /// - [maxTokens]: Maximum number of tokens the model can generate. Default: 1024
  /// - [supportedLoraRanks]: Optional LoRA adapter ranks for model customization
  /// - [preferredBackend]: Hardware acceleration preference (CPU/GPU) - Android only, ignored on iOS
  /// - [maxNumImages]: Maximum number of images supported in multi-modal input
  /// - [temperature]: Session temperature for randomness. Default: 0.8
  /// - [randomSeed]: Session random seed. Default: 1
  /// - [topK]: Session top-K sampling. Default: 40
  /// - [topP]: Session top-P nucleus sampling. Default: null
  /// - [loraPath]: Session LoRA adapter path. Default: null
  /// - [enableVisionModality]: Enable vision features. Default: null
  /// - [formatter]: Model formatter type. Default: ModelFormatter.gemma
  ///
  /// Returns a [Future] that completes when both model and session are ready.
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeFc.instance.initialize(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 512,
  ///   preferredBackend: PreferredBackend.gpu,
  ///   temperature: 0.8,
  ///   topK: 50,
  ///   formatter: ModelFormatter.llama,
  /// );
  /// ```
  Future<void> initialize({
    required String modelPath,
    int? maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
    double? temperature,
    int? randomSeed,
    int? topK,
    double? topP,
    String? loraPath,
    bool? enableVisionModality,
    ModelFormatter? formatter,
  }) async {
    // Create model
    await createModel(
      modelPath: modelPath,
      maxTokens: maxTokens,
      supportedLoraRanks: supportedLoraRanks,
      preferredBackend: preferredBackend,
      maxNumImages: maxNumImages,
    );

    // Create session with provided parameters
    await createSession(
      temperature: temperature,
      randomSeed: randomSeed,
      topK: topK,
      topP: topP,
      loraPath: loraPath,
      enableVisionModality: enableVisionModality,
      formatter: formatter,
    );
  }

  /// Creates a copy of the current session with the same configuration.
  ///
  /// This method clones the active session, preserving its configuration
  /// but starting with a fresh conversation context. Useful for:
  /// - Creating conversation branches
  /// - Resetting the context while keeping settings
  /// - Testing different conversation paths
  ///
  /// The cloned session becomes the active session.
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.cloneSession();
  /// // New session with same config but fresh context
  /// ```
  Future<void> cloneSession() {
    return AiEdgeFcPlatform.instance.cloneSession();
  }

  /// Enables output constraints for controlled text generation.
  ///
  /// Constraints guide the model's output format, such as forcing tool-only
  /// responses or stopping at specific phrases. Only one constraint can be
  /// active at a time.
  ///
  /// Parameters:
  /// - [constraints]: The constraint configuration to apply
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.enableConstraint(
  ///   ConstraintOptions(
  ///     toolCallOnly: ToolCallOnly(
  ///       constraintPrefix: 'Function: ',
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<void> enableConstraint(ConstraintOptions constraints) {
    final constraintsBytes = constraints.writeToBuffer();
    return AiEdgeFcPlatform.instance.enableConstraint({
      'constraints': constraintsBytes,
    });
  }

  /// Disables any active output constraints.
  ///
  /// After calling this method, the model will generate responses without
  /// any format constraints, returning to its default behavior.
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.disableConstraint();
  /// ```
  Future<void> disableConstraint() {
    return AiEdgeFcPlatform.instance.disableConstraint();
  }

  /// Sets the functions available for the model to call.
  ///
  /// This is a convenience method that wraps the functions in a single [Tool].
  /// The model can invoke these functions when it determines they're needed
  /// to fulfill a user request.
  ///
  /// Parameters:
  /// - [functions]: List of function declarations the model can use
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.setFunctions([
  ///   FunctionDeclaration(
  ///     name: 'calculate',
  ///     description: 'Perform calculations',
  ///     properties: [...],
  ///   ),
  /// ]);
  /// ```
  Future<void> setFunctions(List<FunctionDeclaration> functions) {
    return setTools([Tool(functionDeclarations: functions)]);
  }

  /// Sets the tools (groups of functions) available for the model.
  ///
  /// Tools allow organizing related functions together. Each tool can contain
  /// multiple function declarations. The model can invoke any function from
  /// any provided tool.
  ///
  /// Parameters:
  /// - [tools]: List of tools containing function declarations
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.setTools([
  ///   Tool(functionDeclarations: weatherFunctions),
  ///   Tool(functionDeclarations: mathFunctions),
  /// ]);
  /// ```
  Future<void> setTools(List<Tool> tools) {
    return AiEdgeFcPlatform.instance.setTools({
      'tools': tools.map((tool) => tool.writeToBuffer()).toList(),
    });
  }

  /// Sets the system instruction for the model.
  ///
  /// System instructions provide high-level guidance about the model's behavior,
  /// personality, and response style. Unlike regular messages, system instructions
  /// persist across the entire conversation.
  ///
  /// Parameters:
  /// - [systemInstruction]: The system-level instruction to set
  ///
  /// Example:
  /// ```dart
  /// await aiEdgeFc.setSystemInstruction(
  ///   SystemInstruction(
  ///     instruction: 'You are a helpful coding assistant. '
  ///                 'Provide clear, concise code examples.',
  ///   ),
  /// );
  /// ```
  Future<void> setSystemInstruction(SystemInstruction systemInstruction) {
    return AiEdgeFcPlatform.instance.setSystemInstruction({
      'systemInstruction': systemInstruction.writeToBuffer(),
    });
  }

  /// Sends a message to the model and receives a response.
  ///
  /// This method sends a user message to the model and waits for the complete
  /// response, which may include text, function calls, or both depending on
  /// the model's decision and available tools.
  ///
  /// Parameters:
  /// - [message]: The message to send to the model
  ///
  /// Returns a [GenerateContentResponse] containing the model's response,
  /// which may include text content and/or function calls.
  ///
  /// Example:
  /// ```dart
  /// final response = await aiEdgeFc.sendMessage(
  ///   Message(role: 'user', text: 'What is the weather in Tokyo?'),
  /// );
  ///
  /// // Check for function calls in the response
  /// final functionCall = response.getFunctionCall();
  /// if (functionCall != null) {
  ///   // Execute the function and send back the result
  /// }
  /// ```
  Future<GenerateContentResponse> sendMessage(Message message) {
    final contentBytes = message.writeToBuffer();
    return AiEdgeFcPlatform.instance
        .sendMessage({'message': contentBytes})
        .then(GenerateContentResponse.fromBuffer);
  }

  /// Sends a function execution result back to the model.
  ///
  /// After the model requests a function call and the application executes it,
  /// use this method to send the result back. The model will then continue
  /// the conversation incorporating the function's output.
  ///
  /// Parameters:
  /// - [response]: The function execution result to send
  ///
  /// Returns a [GenerateContentResponse] with the model's continuation,
  /// which may include additional text or more function calls.
  ///
  /// Example:
  /// ```dart
  /// // After executing a function call
  /// final functionResult = await executeFunction(functionCall);
  ///
  /// final response = await aiEdgeFc.sendFunctionResponse(
  ///   FunctionResponse(
  ///     functionCall: functionCall,
  ///     response: {'result': functionResult},
  ///   ),
  /// );
  /// ```
  Future<GenerateContentResponse> sendFunctionResponse(
    FunctionResponse response,
  ) {
    final contentBytes = response.writeToBuffer();
    return AiEdgeFcPlatform.instance
        .sendMessage({'message': contentBytes})
        .then(GenerateContentResponse.fromBuffer);
  }

  /// Retrieves the complete conversation history.
  ///
  /// Returns all messages in the current session, including user messages,
  /// model responses, function calls, and function responses. The history
  /// is ordered chronologically from oldest to newest.
  ///
  /// Returns an [Iterable] of [Content] objects representing the conversation.
  ///
  /// Example:
  /// ```dart
  /// final history = await aiEdgeFc.getHistory();
  /// for (final content in history) {
  ///   print('${content.role}: ${content.parts}');
  /// }
  /// ```
  Future<Iterable<Content>> getHistory() {
    return AiEdgeFcPlatform.instance.getHistory().then(
      (result) => result.map(Content.fromBuffer),
    );
  }

  /// Gets the last message in the conversation history.
  ///
  /// Returns the most recent content in the session, which could be a user
  /// message, model response, or function-related content. Returns null if
  /// the conversation history is empty.
  ///
  /// Example:
  /// ```dart
  /// final lastMessage = await aiEdgeFc.getLast();
  /// if (lastMessage != null) {
  ///   print('Last message role: ${lastMessage.role}');
  /// }
  /// ```
  Future<Content?> getLast() {
    return AiEdgeFcPlatform.instance.getLast().then(
      (result) => result != null ? Content.fromBuffer(result) : null,
    );
  }

  /// Releases all resources associated with the model and session.
  ///
  /// This method should be called when the AI Edge FC functionality is no longer needed,
  /// typically in the widget's dispose method or when switching between different models.
  /// It ensures proper cleanup of native resources and memory.
  ///
  /// After calling [close], you must call [initialize] or [createModel]/[createSession]
  /// again before using any other methods.
  ///
  /// Note: This method silently ignores platform exceptions that may occur during
  /// cleanup, as the native implementation logs warnings but doesn't throw errors.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   AiEdgeFc.instance.close();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> close() async {
    try {
      await AiEdgeFcPlatform.instance.close();
    } on PlatformException {
      // Ignore errors when closing, as per Android implementation
      // which logs warnings but doesn't throw
    }
  }
}
