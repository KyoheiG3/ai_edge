import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge/ai_edge.dart';
import 'package:ai_edge/ai_edge_platform_interface.dart';
import 'package:ai_edge/ai_edge_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiEdgePlatform
    with MockPlatformInterfaceMixin
    implements AiEdgePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AiEdgePlatform initialPlatform = AiEdgePlatform.instance;

  test('$MethodChannelAiEdge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAiEdge>());
  });

  test('getPlatformVersion', () async {
    AiEdge aiEdgePlugin = AiEdge();
    MockAiEdgePlatform fakePlatform = MockAiEdgePlatform();
    AiEdgePlatform.instance = fakePlatform;

    expect(await aiEdgePlugin.getPlatformVersion(), '42');
  });
}
