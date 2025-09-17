import 'package:ai_edge/ai_edge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Plugin Integration Tests', () {
    test(
      'Model initialization and cleanup',
      () async {
        final aiEdge = AiEdge.instance;
        const modelPath = String.fromEnvironment('TEST_MODEL_PATH');
        if (modelPath.isEmpty) {
          throw Exception('TEST_MODEL_PATH environment variable is not set');
        }

        // Initialize model
        await aiEdge.initialize(modelPath: modelPath, maxTokens: 512);
        await aiEdge.addQueryChunk('Keep your response short.');

        // Test basic functionality
        final response = await aiEdge.generateResponse('Hello');
        expect(response, isNotEmpty);

        // Clean up
        await aiEdge.close();
      },
      timeout: const Timeout(Duration(seconds: 240)),
    );

    test('Multiple session creation', () async {
      final aiEdge = AiEdge.instance;
      const modelPath = String.fromEnvironment('TEST_MODEL_PATH');
      if (modelPath.isEmpty) {
        throw Exception('TEST_MODEL_PATH environment variable is not set');
      }

      // Initialize first session
      await aiEdge.initialize(
        modelPath: modelPath,
        maxTokens: 512,
        temperature: 0.5,
      );
      await aiEdge.addQueryChunk('Keep your response short.');

      final response1 = await aiEdge.generateResponse('Hi');
      expect(response1, isNotEmpty);

      // Create new session with different config
      await aiEdge.createSession(temperature: 0.9);
      await aiEdge.addQueryChunk('Keep your response short.');

      final response2 = await aiEdge.generateResponse('Hello');
      expect(response2, isNotEmpty);

      await aiEdge.close();
    }, timeout: const Timeout(Duration(seconds: 240)));
  });
}
