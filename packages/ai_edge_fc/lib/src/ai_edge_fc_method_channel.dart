import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ai_edge_fc_platform_interface.dart';

/// An implementation of [AiEdgeFcPlatform] that uses method channels.
class MethodChannelAiEdgeFc extends AiEdgeFcPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ai_edge_fc');

  @override
  Future<void> createModel(Map<String, dynamic> options) async {
    await methodChannel.invokeMethod('createModel', options);
  }

  @override
  Future<void> createSession(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('createSession', arguments);
  }

  @override
  Future<void> cloneSession() async {
    await methodChannel.invokeMethod('cloneSession');
  }

  @override
  Future<void> enableConstraint(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('enableConstraint', arguments);
  }

  @override
  Future<void> disableConstraint() async {
    await methodChannel.invokeMethod('disableConstraint');
  }

  @override
  Future<void> setTools(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('setTools', arguments);
  }

  @override
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) async {
    await methodChannel.invokeMethod('setSystemInstruction', arguments);
  }

  @override
  Future<Uint8List> sendMessage(Map<String, dynamic> arguments) async {
    final result = await methodChannel.invokeMethod<Uint8List>(
      'sendMessage',
      arguments,
    );
    if (result == null) {
      throw Exception('sendMessage returned null');
    }
    return result;
  }

  @override
  Future<Iterable<Uint8List>> getHistory() async {
    final result = await methodChannel.invokeMethod<List<Object?>>(
      'getHistory',
    );
    if (result == null) {
      throw Exception('getHistory returned null');
    }
    return result.map((item) => item as Uint8List).toList();
  }

  @override
  Future<Uint8List?> getLast() async {
    return methodChannel.invokeMethod<Uint8List>('getLast');
  }

  @override
  Future<void> close() async {
    await methodChannel.invokeMethod('close');
  }
}
