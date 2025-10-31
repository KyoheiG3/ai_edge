import 'package:ai_edge/ai_edge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ai_edge_rag_platform_interface.dart';

/// An implementation of [AiEdgeRagPlatform] that uses method channels.
class MethodChannelAiEdgeRag extends AiEdgeRagPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ai_edge_rag/methods');
  @visibleForTesting
  final eventChannel = const EventChannel('ai_edge_rag/events');

  @override
  Future<void> createModel(Map<String, dynamic> options) async {
    await methodChannel.invokeMethod('createModel', options);
  }

  @override
  Future<void> createSession(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('createSession', arguments);
  }

  @override
  Future<void> createEmbeddingModel(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('createEmbeddingModel', arguments);
  }

  @override
  Future<void> createGeminiEmbedder(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('createGeminiEmbedder', arguments);
  }

  @override
  Future<void> memorizeChunk(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('memorizeChunk', arguments);
  }

  @override
  Future<void> memorizeChunks(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('memorizeChunks', arguments);
  }

  @override
  Future<void> memorizeChunkedText(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('memorizeChunkedText', arguments);
  }

  @override
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('setSystemInstruction', arguments);
  }

  @override
  Future<void> generateResponseAsync(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('generateResponseAsync', arguments);
  }

  @override
  Stream<GenerationEvent> getPartialResultStream() {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return GenerationEvent.fromMap(Map<String, dynamic>.from(event));
      }
      return GenerationEvent(partialResult: event.toString(), done: false);
    });
  }

  @override
  Future<void> close() async {
    await methodChannel.invokeMethod('close');
  }
}
