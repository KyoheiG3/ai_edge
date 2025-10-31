import 'package:ai_edge/ai_edge.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ai_edge_rag_method_channel.dart';

abstract class AiEdgeRagPlatform extends PlatformInterface {
  /// Constructs a AiEdgeRagPlatform.
  AiEdgeRagPlatform() : super(token: _token);

  static final Object _token = Object();

  static AiEdgeRagPlatform _instance = MethodChannelAiEdgeRag();

  /// The default instance of [AiEdgeRagPlatform] to use.
  ///
  /// Defaults to [MethodChannelAiEdgeRag].
  static AiEdgeRagPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiEdgeRagPlatform] when
  /// they register themselves.
  static set instance(AiEdgeRagPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Creates a new model with the given configuration.
  Future<void> createModel(Map<String, dynamic> options) {
    throw UnimplementedError('createModel() has not been implemented.');
  }

  /// Creates a new session with the given configuration.
  Future<void> createSession(Map<String, dynamic> arguments) {
    throw UnimplementedError('createSession() has not been implemented.');
  }

  /// Creates a local embedding model for converting text to vector representations.
  Future<void> createEmbeddingModel(Map<String, dynamic> arguments) {
    throw UnimplementedError(
      'createEmbeddingModel() has not been implemented.',
    );
  }

  /// Creates a Gemini API-based embedder for generating embeddings.
  Future<void> createGeminiEmbedder(Map<String, dynamic> arguments) {
    throw UnimplementedError(
      'createGeminiEmbedder() has not been implemented.',
    );
  }

  /// Stores a single text chunk in the vector store.
  Future<void> memorizeChunk(Map<String, dynamic> arguments) {
    throw UnimplementedError('memorizeChunk() has not been implemented.');
  }

  /// Stores multiple text chunks in the vector store.
  Future<void> memorizeChunks(Map<String, dynamic> arguments) {
    throw UnimplementedError('memorizeChunks() has not been implemented.');
  }

  /// Automatically chunks and stores a large text document in the vector store.
  Future<void> memorizeChunkedText(Map<String, dynamic> arguments) {
    throw UnimplementedError('memorizeChunkedText() has not been implemented.');
  }

  /// Sets the system instruction for the model.
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) {
    throw UnimplementedError(
      'setSystemInstruction() has not been implemented.',
    );
  }

  /// Generates an async response
  Future<void> generateResponseAsync(Map<String, dynamic> arguments);

  /// Returns a stream of partial results
  Stream<GenerationEvent> getPartialResultStream();

  /// Releases all resources associated with the model and session.
  Future<void> close() {
    throw UnimplementedError('close() has not been implemented.');
  }
}
