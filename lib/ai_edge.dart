
import 'ai_edge_platform_interface.dart';

class AiEdge {
  Future<String?> getPlatformVersion() {
    return AiEdgePlatform.instance.getPlatformVersion();
  }
}
