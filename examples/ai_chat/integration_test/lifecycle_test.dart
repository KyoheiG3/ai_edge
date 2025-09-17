import 'package:ai_edge/ai_edge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Lifecycle Tests', () {
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

        // Verify it works
        final response = await aiEdge.generateResponse('Hello');
        expect(response, isNotEmpty);

        // Clean up
        await aiEdge.close();

        // Reinitialize to verify cleanup was successful
        await aiEdge.initialize(modelPath: modelPath, maxTokens: 512);
        await aiEdge.addQueryChunk('Keep your response short.');

        final response2 = await aiEdge.generateResponse('Hi');
        expect(response2, isNotEmpty);

        await aiEdge.close();
      },
      timeout: const Timeout(Duration(seconds: 240)),
    );

    test('Multiple session lifecycle', () async {
      final aiEdge = AiEdge.instance;
      const modelPath = String.fromEnvironment('TEST_MODEL_PATH');
      if (modelPath.isEmpty) {
        throw Exception('TEST_MODEL_PATH environment variable is not set');
      }

      // Create model once
      await aiEdge.createModel(modelPath: modelPath, maxTokens: 512);

      // Create first session
      await aiEdge.createSession(temperature: 0.5);
      await aiEdge.addQueryChunk('Keep your response short.');

      final response1 = await aiEdge.generateResponse('Count to 3');
      expect(response1, isNotEmpty);

      // Create new session (replaces previous)
      await aiEdge.createSession(temperature: 0.9);
      await aiEdge.addQueryChunk('Keep your response short.');

      final response2 = await aiEdge.generateResponse('Count to 3');
      expect(response2, isNotEmpty);

      // Sessions are independent (no shared context)
      final response3 = await aiEdge.generateResponse('What did I ask before?');
      expect(response3, isNotEmpty);
      // Should not remember previous session's context

      await aiEdge.close();
    }, timeout: const Timeout(Duration(seconds: 240)));

    test(
      'Resource cleanup verification',
      () async {
        final aiEdge = AiEdge.instance;
        const modelPath = String.fromEnvironment('TEST_MODEL_PATH');
        if (modelPath.isEmpty) {
          throw Exception('TEST_MODEL_PATH environment variable is not set');
        }

        // Multiple init/close cycles to verify no resource leaks
        for (int i = 0; i < 3; i++) {
          await aiEdge.initialize(modelPath: modelPath, maxTokens: 512);
          await aiEdge.addQueryChunk('Keep your response short.');

          final response = await aiEdge.generateResponse('Hi');
          expect(response, isNotEmpty);

          await aiEdge.close();

          await Future.delayed(const Duration(milliseconds: 500));
        }
      },
      timeout: const Timeout(Duration(seconds: 240)),
    );
  });
}
