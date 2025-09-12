import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ai_edge_method_channel.dart';
import 'types.dart';

/// The base platform interface for AiEdge.
abstract class AiEdgePlatform extends PlatformInterface {
  AiEdgePlatform() : super(token: _token);

  static final Object _token = Object();
  static AiEdgePlatform _instance = MethodChannelAiEdge();

  /// The default instance of [AiEdgePlatform] to use.
  static AiEdgePlatform get instance => _instance;

  static set instance(AiEdgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Creates a new model with the given configuration
  Future<void> createModel(ModelConfig config);

  /// Creates a new session with the given configuration
  Future<void> createSession(SessionConfig config);

  /// Closes both model and session
  Future<void> close();

  /// Adds a query chunk to the current session
  Future<void> addQueryChunk(String prompt);

  /// Adds an image to the current session
  Future<void> addImage(Uint8List imageBytes);

  /// Generates a synchronous response
  Future<String> generateResponse(String? prompt);

  /// Generates an async response
  Future<void> generateResponseAsync(String? prompt);

  /// Returns a stream of partial results
  Stream<GenerationEvent> getPartialResultStream();
}
