import 'dart:async';
import 'dart:typed_data';

import 'ai_edge_platform_interface.dart';
import 'types.dart';

export 'types.dart';

/// The main class for using the AiEdge plugin.
class AiEdge {
  static final AiEdge _instance = AiEdge._();

  AiEdge._();

  /// Returns the singleton instance of AiEdge
  static AiEdge get instance => _instance;

  /// Creates a new model with the given configuration
  Future<void> createModel(ModelConfig config) {
    return AiEdgePlatform.instance.createModel(config);
  }

  /// Creates a new session with the given configuration
  Future<void> createSession(SessionConfig config) {
    return AiEdgePlatform.instance.createSession(config);
  }

  /// Initialize the AI Edge with model and session configurations
  /// This is a convenience method that calls createModel and createSession
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

  /// Closes both model and session
  Future<void> close() {
    return AiEdgePlatform.instance.close();
  }

  /// Adds a query chunk to the current session
  Future<void> addQueryChunk(String prompt) {
    return AiEdgePlatform.instance.addQueryChunk(prompt);
  }

  /// Adds an image to the current session
  Future<void> addImage(Uint8List imageBytes) {
    return AiEdgePlatform.instance.addImage(imageBytes);
  }

  /// Generates a synchronous response
  Future<String> generateResponse([String? prompt]) {
    return AiEdgePlatform.instance.generateResponse(prompt);
  }

  /// Generates an async response and returns a stream of partial results
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
