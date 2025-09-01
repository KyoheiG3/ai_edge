part of 'ai_edge.dart';

/// An implementation of [MethodChannelAiEdge] that uses
/// a [MethodChannel] and an [EventChannel] for communicating with native code.
class MethodChannelAiEdge extends AiEdgePlatform {
  final MethodChannel _methodChannel = const MethodChannel('ai_edge/methods');
  final EventChannel _eventChannel = const EventChannel('ai_edge/events');

  @override
  Future<void> createModel(InferenceModelConfig config) async {
    await _methodChannel.invokeMethod('createModel', config.toMap());
  }

  @override
  Future<void> createSession(InferenceSessionConfig config) async {
    await _methodChannel.invokeMethod('createSession', config.toMap());
  }

  @override
  Future<void> close() async {
    await _methodChannel.invokeMethod('close');
  }

  @override
  Future<void> addQueryChunk(String prompt) async {
    await _methodChannel.invokeMethod('addQueryChunk', {'prompt': prompt});
  }

  @override
  Future<void> addImage(Uint8List imageBytes) async {
    await _methodChannel.invokeMethod('addImage', {'imageBytes': imageBytes});
  }

  @override
  Future<String> generateResponse(String? prompt) async {
    final result = await _methodChannel.invokeMethod('generateResponse', {
      'prompt': prompt,
    });
    return result ?? '';
  }

  @override
  Future<void> generateResponseAsync(String? prompt) async {
    await _methodChannel.invokeMethod('generateResponseAsync', {
      'prompt': prompt,
    });
  }

  @override
  Stream<Map<String, dynamic>> getPartialResultStream() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return {'partialResult': event.toString(), 'done': false};
    });
  }
}
