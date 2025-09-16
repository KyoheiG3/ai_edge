import 'dart:async';
import 'dart:typed_data';

import 'ai_edge_platform_interface.dart';
import 'types.dart';

/// A Flutter plugin for on-device AI inference using MediaPipe GenAI.
///
/// The `AiEdge` class provides a unified interface for running large language models
/// directly on mobile devices, supporting both iOS and Android platforms through
/// MediaPipe's GenAI framework.
///
/// ## Features
/// - On-device inference for enhanced privacy and offline capability
/// - Support for text generation with streaming responses
/// - Multi-modal input support (text and images)
/// - Configurable inference parameters (temperature, top-k, top-p)
/// - Hardware acceleration support (CPU/GPU backend selection)
/// - Session-based conversation management
///
/// ## Usage
///
/// ### Basic Initialization
/// ```dart
/// final aiEdge = AiEdge.instance;
/// await aiEdge.initialize(
///   modelPath: '/path/to/model.task',
///   maxTokens: 512,
/// );
/// ```
///
/// ### Generate Text Response
/// ```dart
/// // Synchronous generation
/// final response = await aiEdge.generateResponse('What is Flutter?');
///
/// // Streaming generation
/// final stream = aiEdge.generateResponseAsync('Explain AI');
/// await for (final event in stream) {
///   print(event.partialResult);
///   if (event.done) {
///     print('Generation completed');
///   }
/// }
/// ```
///
/// ### Multi-turn Conversation
/// ```dart
/// // Add context incrementally
/// await aiEdge.addQueryChunk('Previous context...');
/// final response = await aiEdge.generateResponse('Follow-up question');
/// ```
///
/// ## Platform Requirements
/// - iOS: Requires iOS 15.0 or later with MediaPipe GenAI iOS framework
/// - Android: Requires Android API level 24 or later with MediaPipe GenAI Android library
///
/// ## Model Format
/// Supports MediaPipe Task models (.task files) compatible with the GenAI runtime.
/// Models must be optimized for mobile inference with appropriate quantization.
class AiEdge {
  static final AiEdge _instance = AiEdge._();

  AiEdge._();

  /// Returns the singleton instance of [AiEdge].
  ///
  /// This plugin uses a singleton pattern to ensure only one model and session
  /// are active at a time, managing resources efficiently on mobile devices.
  ///
  /// Example:
  /// ```dart
  /// final aiEdge = AiEdge.instance;
  /// ```
  static AiEdge get instance => _instance;

  /// Creates and loads an AI model with the specified configuration.
  ///
  /// This method initializes the MediaPipe GenAI inference engine with the provided
  /// model file and configuration parameters. The model must be in MediaPipe Task
  /// format (.task file).
  ///
  /// Parameters:
  /// - [config]: The model configuration including path, token limits, and backend preferences
  ///
  /// Throws:
  /// - [PlatformException] if the model file cannot be loaded or is incompatible
  /// - [ArgumentError] if the configuration parameters are invalid
  ///
  /// Example:
  /// ```dart
  /// await aiEdge.createModel(ModelConfig(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 1024,
  ///   preferredBackend: PreferredBackend.gpu,
  /// ));
  /// ```
  Future<void> createModel(ModelConfig config) {
    return AiEdgePlatform.instance.createModel(config.toMap());
  }

  /// Creates a new inference session with the specified configuration.
  ///
  /// A session manages the conversation context and generation parameters.
  /// Multiple sessions can be created sequentially, but only one session
  /// is active at a time.
  ///
  /// Parameters:
  /// - [config]: Session configuration for generation parameters
  ///
  /// The session configuration controls:
  /// - Temperature: Controls randomness (0.0 = deterministic, 1.0 = more random)
  /// - Top-K: Limits vocabulary to K most likely tokens
  /// - Top-P: Nucleus sampling threshold
  /// - Random seed: For reproducible generation
  ///
  /// Example:
  /// ```dart
  /// await aiEdge.createSession(SessionConfig(
  ///   temperature: 0.7,
  ///   topK: 40,
  ///   topP: 0.95,
  /// ));
  /// ```
  Future<void> createSession(SessionConfig config) {
    return AiEdgePlatform.instance.createSession(config.toMap());
  }

  /// Convenience method to initialize both model and session in a single call.
  ///
  /// This method combines [createModel] and [createSession] for simplified setup.
  /// It's the recommended way to initialize the AI Edge plugin for most use cases.
  ///
  /// Parameters:
  /// - [modelPath]: Path to the MediaPipe Task model file
  /// - [maxTokens]: Maximum number of tokens the model can generate
  /// - [supportedLoraRanks]: Optional LoRA adapter ranks for model customization
  /// - [preferredBackend]: Hardware acceleration preference (CPU/GPU) - Android only, ignored on iOS
  /// - [maxNumImages]: Maximum number of images supported in multi-modal input
  /// - [sessionConfig]: Optional session configuration; uses defaults if not provided
  ///
  /// Returns a [Future] that completes when both model and session are ready.
  ///
  /// Example:
  /// ```dart
  /// await AiEdge.instance.initialize(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 512,
  ///   preferredBackend: PreferredBackend.gpu,
  ///   sessionConfig: SessionConfig(temperature: 0.8),
  /// );
  /// ```
  Future<void> initialize({
    required String modelPath,
    required int maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
    SessionConfig? sessionConfig,
  }) async {
    // Create model
    await createModel(
      ModelConfig(
        modelPath: modelPath,
        maxTokens: maxTokens,
        supportedLoraRanks: supportedLoraRanks,
        preferredBackend: preferredBackend,
        maxNumImages: maxNumImages,
      ),
    );

    // Create session with default or provided config
    await createSession(sessionConfig ?? const SessionConfig());
  }

  /// Releases all resources associated with the model and session.
  ///
  /// This method should be called when the AI Edge functionality is no longer needed,
  /// typically in the widget's dispose method or when switching between different models.
  /// It ensures proper cleanup of native resources and memory.
  ///
  /// After calling [close], you must call [initialize] or [createModel]/[createSession]
  /// again before using any generation methods.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   AiEdge.instance.close();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> close() {
    return AiEdgePlatform.instance.close();
  }

  /// Adds a text query chunk to the current session context.
  ///
  /// This method allows incremental building of the input prompt, useful for:
  /// - Adding system prompts or instructions
  /// - Building multi-part queries
  /// - Maintaining conversation context
  ///
  /// The chunks are concatenated in the order they are added and processed
  /// together when [generateResponse] or [generateResponseAsync] is called.
  ///
  /// Parameters:
  /// - [prompt]: The text chunk to add to the session
  ///
  /// Example:
  /// ```dart
  /// await aiEdge.addQueryChunk('You are a helpful assistant.');
  /// await aiEdge.addQueryChunk('User question: What is Flutter?');
  /// final response = await aiEdge.generateResponse();
  /// ```
  Future<void> addQueryChunk(String prompt) {
    return AiEdgePlatform.instance.addQueryChunk(prompt);
  }

  /// Adds an image to the current session for multi-modal inference.
  ///
  /// This method enables vision-language model capabilities, allowing the model
  /// to process and respond to image inputs alongside text. The image should be
  /// provided as raw bytes in a supported format (JPEG, PNG).
  ///
  /// Parameters:
  /// - [imageBytes]: The image data as a byte array
  ///
  /// Note: The model must support multi-modal input, and [maxNumImages] should be
  /// configured in the model initialization.
  ///
  /// Example:
  /// ```dart
  /// final imageBytes = await File('image.jpg').readAsBytes();
  /// await aiEdge.addImage(imageBytes);
  /// final response = await aiEdge.generateResponse('What is in this image?');
  /// ```
  Future<void> addImage(Uint8List imageBytes) {
    return AiEdgePlatform.instance.addImage(imageBytes);
  }

  /// Generates a complete text response synchronously.
  ///
  /// This method blocks until the entire response is generated and returns
  /// the complete text. Use this when you need the full response at once
  /// and don't need streaming capabilities.
  ///
  /// Parameters:
  /// - [prompt]: Optional prompt to generate a response for. If provided,
  ///   it's added to the session before generation. If null, generates
  ///   based on previously added query chunks.
  ///
  /// Returns the complete generated text response.
  ///
  /// Throws:
  /// - [PlatformException] if generation fails or the model encounters an error
  ///
  /// Example:
  /// ```dart
  /// // Direct generation
  /// final response = await aiEdge.generateResponse('Explain quantum computing');
  ///
  /// // Using pre-added context
  /// await aiEdge.addQueryChunk('Context: Flutter is a UI framework');
  /// final response = await aiEdge.generateResponse('What is it used for?');
  /// ```
  Future<String> generateResponse([String? prompt]) {
    return AiEdgePlatform.instance.generateResponse(prompt);
  }

  /// Generates a text response asynchronously with streaming support.
  ///
  /// This method returns a [Stream] that emits [GenerationEvent] objects as
  /// the response is generated. This enables real-time display of partial
  /// results, providing a better user experience for long responses.
  ///
  /// Parameters:
  /// - [prompt]: Optional prompt to generate a response for. If provided,
  ///   it's added to the session before generation begins.
  ///
  /// Returns a [Stream] of [GenerationEvent] objects containing:
  /// - `partialResult`: The incremental text generated so far
  /// - `done`: Boolean flag indicating if generation is complete
  ///
  /// The stream automatically manages the underlying platform event channel
  /// and closes when generation completes or an error occurs.
  ///
  /// Example:
  /// ```dart
  /// final stream = aiEdge.generateResponseAsync('Write a story');
  /// final buffer = StringBuffer();
  ///
  /// await for (final event in stream) {
  ///   buffer.write(event.partialResult);
  ///   print('Partial: ${event.partialResult}');
  ///
  ///   if (event.done) {
  ///     print('Generation completed!');
  ///     print('Full response: ${buffer.toString()}');
  ///   }
  /// }
  /// ```
  Stream<GenerationEvent> generateResponseAsync([String? prompt]) {
    // First get the stream (which sets up the event listener)
    final controller = StreamController<GenerationEvent>.broadcast(sync: true)
      ..onListen = () {
        // When the stream is listened to, we can start the async generation
        AiEdgePlatform.instance.generateResponseAsync(prompt);
      };

    final stream = AiEdgePlatform.instance.getPartialResultStream();
    controller.addStream(stream).then((_) {
      // If the stream completes, we can close the controller
      if (!controller.isClosed) {
        controller.close();
      }
    });

    return controller.stream;
  }
}
