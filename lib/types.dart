/// Preferred hardware backend for model inference execution.
///
/// Specifies the computational backend to use for running AI models,
/// allowing optimization based on device capabilities and performance requirements.
///
/// Example:
/// ```dart
/// final config = ModelConfig(
///   modelPath: 'model.task',
///   maxTokens: 512,
///   preferredBackend: PreferredBackend.gpu,
/// );
/// ```
enum PreferredBackend {
  /// Unknown or unspecified backend.
  ///
  /// The system will automatically select an appropriate backend.
  unknown(0),

  /// CPU-based inference.
  ///
  /// Uses the device's CPU for model execution. This is more compatible
  /// but generally slower than GPU inference.
  cpu(1),

  /// GPU-based inference.
  ///
  /// Uses the device's GPU for accelerated model execution. Provides
  /// better performance for supported models and devices.
  gpu(2);

  /// The numeric value representing this backend type.
  final int value;

  const PreferredBackend(this.value);
}

/// Configuration parameters for loading and initializing an AI model.
///
/// This class encapsulates all necessary settings for creating a MediaPipe GenAI
/// model instance, including the model file location, token limits, hardware
/// preferences, and optional features like LoRA adapters and multi-modal support.
///
/// ## Required Parameters
/// - [modelPath]: Absolute path to the model file
/// - [maxTokens]: Maximum generation length
///
/// ## Optional Parameters
/// - [supportedLoraRanks]: LoRA adapter dimensions for model customization
/// - [preferredBackend]: Hardware acceleration preference
/// - [maxNumImages]: Enable multi-modal input with image support
///
/// Example:
/// ```dart
/// final config = ModelConfig(
///   modelPath: '/storage/models/gemma-2b.task',
///   maxTokens: 1024,
///   preferredBackend: PreferredBackend.gpu,
///   maxNumImages: 3,
/// );
/// await aiEdge.createModel(config);
/// ```
class ModelConfig {
  /// Path to the MediaPipe Task model file.
  ///
  /// Must be an absolute path to a valid `.task` file compatible with
  /// MediaPipe GenAI runtime. The file should be accessible and readable
  /// by the application.
  final String modelPath;

  /// Maximum number of tokens the model can generate in a single response.
  ///
  /// This value should be set based on the model's training configuration
  /// and memory constraints. Typical values range from 256 to 2048.
  final int maxTokens;

  /// Supported LoRA (Low-Rank Adaptation) ranks for model customization.
  ///
  /// LoRA allows efficient fine-tuning of large models by training only
  /// low-rank decomposition matrices. Specify the ranks your LoRA adapters
  /// support, e.g., [4, 8, 16].
  final List<int>? supportedLoraRanks;

  /// Preferred hardware backend for model inference (Android only).
  ///
  /// Specifies whether to use CPU or GPU for computation on Android devices.
  /// This setting is ignored on iOS.
  /// If not specified, the system automatically selects the best available backend.
  final PreferredBackend? preferredBackend;

  /// Maximum number of images that can be processed in multi-modal inference.
  ///
  /// For vision-language models, this parameter enables image input support
  /// and specifies how many images can be included in a single query.
  /// Set to null for text-only models.
  final int? maxNumImages;

  /// Creates a new model configuration.
  ///
  /// Parameters:
  /// - [modelPath]: Required. Path to the model file
  /// - [maxTokens]: Required. Maximum generation length
  /// - [supportedLoraRanks]: Optional. LoRA adapter ranks
  /// - [preferredBackend]: Optional. Hardware backend preference (Android only)
  /// - [maxNumImages]: Optional. Multi-modal image support
  const ModelConfig({
    required this.modelPath,
    required this.maxTokens,
    this.supportedLoraRanks,
    this.preferredBackend,
    this.maxNumImages,
  });

  /// Converts this configuration to a Map for platform channel communication.
  ///
  /// Returns a Map representation suitable for passing through Flutter's
  /// platform channels to native code. Only includes non-null optional
  /// parameters in the output.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'modelPath': modelPath,
      'maxTokens': maxTokens,
    };
    if (supportedLoraRanks != null) {
      map['loraRanks'] = supportedLoraRanks;
    }
    if (preferredBackend != null) {
      map['preferredBackend'] = preferredBackend?.value;
    }
    if (maxNumImages != null) {
      map['maxNumImages'] = maxNumImages;
    }
    return map;
  }
}

/// Configuration parameters for an inference session.
///
/// Controls the behavior of text generation including randomness, sampling
/// strategies, and optional features like LoRA adapters and vision modality.
/// All parameters have sensible defaults for general use cases.
///
/// ## Sampling Parameters
/// The generation process can be controlled through various sampling strategies:
/// - **Temperature**: Controls randomness (0.0 = deterministic, 1.0+ = more random)
/// - **Top-K**: Restricts sampling to K most likely tokens
/// - **Top-P**: Nucleus sampling - cumulative probability threshold
///
/// ## Advanced Features
/// - **LoRA**: Load custom LoRA adapters for specialized behavior
/// - **Vision**: Enable multi-modal processing for vision-language models
///
/// Example:
/// ```dart
/// final session = SessionConfig(
///   temperature: 0.7,
///   topK: 50,
///   topP: 0.95,
///   randomSeed: 42, // For reproducible outputs
/// );
/// await aiEdge.createSession(session);
/// ```
class SessionConfig {
  /// Temperature parameter for controlling generation randomness.
  ///
  /// Range: 0.0 to 1.0 (MediaPipe GenAI constraint)
  /// - Lower values (e.g., 0.2): More deterministic, focused responses
  /// - Higher values (e.g., 0.8-1.0): More creative, diverse responses
  ///
  /// Default: 0.8
  final double temperature;

  /// Random seed for reproducible text generation.
  ///
  /// Using the same seed with identical inputs will produce the same outputs,
  /// useful for testing and debugging. Set to a different value or use
  /// timestamps for varied outputs.
  ///
  /// Default: 1
  final int randomSeed;

  /// Top-K sampling parameter.
  ///
  /// Limits the vocabulary to the K most likely next tokens at each step.
  /// Lower values increase focus but may reduce creativity.
  ///
  /// Range: Must be > 1 (typically 10-100)
  /// Default: 40
  final int topK;

  /// Top-P (nucleus) sampling parameter.
  ///
  /// Dynamically selects the smallest set of tokens whose cumulative
  /// probability exceeds this threshold. Provides a balance between
  /// diversity and quality.
  ///
  /// Range: 0.0 to 1.0 (typically 0.9 to 0.95)
  /// Default: null (not used unless specified)
  final double? topP;

  /// Path to a LoRA (Low-Rank Adaptation) adapter file.
  ///
  /// LoRA adapters allow customizing model behavior without modifying
  /// the base model. The adapter should be compatible with the loaded
  /// model's architecture and trained for specific tasks or styles.
  ///
  /// Default: null (no LoRA adapter)
  final String? loraPath;

  /// Enables vision modality for multi-modal models.
  ///
  /// When enabled, the model can process both text and image inputs.
  /// Requires a model trained with vision capabilities and proper
  /// configuration of [ModelConfig.maxNumImages].
  ///
  /// Default: null (auto-detected based on model)
  final bool? enableVisionModality;

  /// Creates a new session configuration.
  ///
  /// All parameters are optional with sensible defaults:
  /// - [temperature]: 0.8 - Balanced between focused and creative
  /// - [randomSeed]: 1 - Deterministic by default
  /// - [topK]: 40 - Standard vocabulary restriction
  /// - [topP]: null - Disabled unless specified
  /// - [loraPath]: null - No LoRA adapter
  /// - [enableVisionModality]: null - Auto-detected
  const SessionConfig({
    this.temperature = 0.8,
    this.randomSeed = 1,
    this.topK = 40,
    this.topP,
    this.loraPath,
    this.enableVisionModality,
  });

  /// Converts this configuration to a Map for platform channel communication.
  ///
  /// Returns a Map representation suitable for passing through Flutter's
  /// platform channels to native code. Always includes required parameters
  /// (temperature, randomSeed, topK) and conditionally includes optional ones.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'temperature': temperature,
      'randomSeed': randomSeed,
      'topK': topK,
    };
    if (topP != null) {
      map['topP'] = topP;
    }
    if (loraPath != null) {
      map['loraPath'] = loraPath;
    }
    if (enableVisionModality != null) {
      map['enableVisionModality'] = enableVisionModality;
    }
    return map;
  }
}

/// Event emitted during asynchronous text generation.
///
/// Represents a single update in the streaming generation process, containing
/// both the incremental text generated so far and a flag indicating whether
/// generation has completed.
///
/// ## Stream Lifecycle
/// During generation, multiple events are emitted:
/// 1. Initial events contain partial text chunks as they're generated
/// 2. Intermediate events accumulate more text
/// 3. Final event has [done] set to true with complete text
///
/// ## Usage Pattern
/// ```dart
/// final stream = aiEdge.generateResponseAsync('Tell me a story');
/// final fullText = StringBuffer();
///
/// await for (final event in stream) {
///   // Process partial result
///   fullText.write(event.partialResult);
///
///   // Check if generation is complete
///   if (event.done) {
///     print('Final response: ${fullText.toString()}');
///   }
/// }
/// ```
///
/// ## Error Handling
/// If an error occurs during generation, the stream will emit an error
/// rather than a GenerationEvent, which should be handled appropriately:
/// ```dart
/// stream.listen(
///   (event) => print(event.partialResult),
///   onError: (error) => print('Generation failed: $error'),
/// );
/// ```
class GenerationEvent {
  /// The partial text result generated so far.
  ///
  /// For streaming responses, this contains the incremental text chunk
  /// generated in this event. The complete response is built by
  /// concatenating all partial results.
  final String partialResult;

  /// Indicates whether text generation has completed.
  ///
  /// When `true`, this is the final event in the stream and [partialResult]
  /// contains the last chunk of generated text. The stream will close
  /// after this event.
  final bool done;

  /// Creates a new generation event.
  ///
  /// Parameters:
  /// - [partialResult]: The incremental text generated
  /// - [done]: Whether this is the final event
  const GenerationEvent({required this.partialResult, required this.done});

  /// Creates a GenerationEvent from a platform channel map.
  ///
  /// This factory constructor is used internally to deserialize events
  /// received from the native platform implementation.
  ///
  /// Parameters:
  /// - [map]: The map containing event data from platform channel
  ///
  /// The map should contain:
  /// - 'partialResult': String with the text chunk
  /// - 'done': Boolean completion flag
  factory GenerationEvent.fromMap(Map<String, dynamic> map) {
    return GenerationEvent(
      partialResult: map['partialResult'] as String? ?? '',
      done: map['done'] as bool? ?? false,
    );
  }

  /// Returns a string representation of this event for debugging.
  ///
  /// Includes both the partial result and done status in a readable format.
  @override
  String toString() {
    return 'GenerationEvent(partialResult: $partialResult, done: $done)';
  }
}
