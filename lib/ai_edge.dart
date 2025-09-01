import 'dart:async';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'model_config.dart';
part 'ai_edge_platform_interface.dart';
part 'ai_edge_method_channel.dart';

/// The main class for using the AiEdge plugin.
class AiEdge {
  static final AiEdge _instance = AiEdge._();

  AiEdge._();

  /// Returns the singleton instance of AiEdge
  static AiEdge get instance => _instance;

  /// Creates a new model with the given configuration
  Future<void> createModel({
    required String modelPath,
    required int maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
  }) {
    final config = InferenceModelConfig(
      modelPath: modelPath,
      maxTokens: maxTokens,
      supportedLoraRanks: supportedLoraRanks,
      preferredBackend: preferredBackend,
      maxNumImages: maxNumImages,
    );
    return AiEdgePlatform.instance.createModel(config);
  }

  /// Creates a new session with the given configuration
  Future<void> createSession({
    double temperature = 0.8,
    int randomSeed = 1,
    int topK = 40,
    double? topP,
    String? loraPath,
    bool? enableVisionModality,
  }) {
    final config = InferenceSessionConfig(
      temperature: temperature,
      randomSeed: randomSeed,
      topK: topK,
      topP: topP,
      loraPath: loraPath,
      enableVisionModality: enableVisionModality,
    );
    return AiEdgePlatform.instance.createSession(config);
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
  Stream<Map<String, dynamic>> generateResponseAsync([String? prompt]) {
    // First get the stream (which sets up the event listener)
    final controller = StreamController<Map<String, dynamic>>.broadcast()
      ..onListen = () {
        // When the stream is listened to, we can start the async generation
        AiEdgePlatform.instance.generateResponseAsync(prompt);
      };

    final stream = AiEdgePlatform.instance.getPartialResultStream();
    controller
        .addStream(stream)
        .then(
          (_) {
            // If the stream completes, we can close the controller
            if (!controller.isClosed) {
              controller.close();
            }
          },
          onError: (error) {
            // If there's an error, we can add it to the controller
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );

    return controller.stream;
  }
}
