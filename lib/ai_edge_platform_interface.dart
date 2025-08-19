import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ai_edge_method_channel.dart';

abstract class AiEdgePlatform extends PlatformInterface {
  /// Constructs a AiEdgePlatform.
  AiEdgePlatform() : super(token: _token);

  static final Object _token = Object();

  static AiEdgePlatform _instance = MethodChannelAiEdge();

  /// The default instance of [AiEdgePlatform] to use.
  ///
  /// Defaults to [MethodChannelAiEdge].
  static AiEdgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiEdgePlatform] when
  /// they register themselves.
  static set instance(AiEdgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
