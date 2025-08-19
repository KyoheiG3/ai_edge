import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ai_edge_platform_interface.dart';

/// An implementation of [AiEdgePlatform] that uses method channels.
class MethodChannelAiEdge extends AiEdgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ai_edge');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
