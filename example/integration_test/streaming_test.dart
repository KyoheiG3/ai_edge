import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_edge/ai_edge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AiEdge aiEdge;

  setUpAll(() async {
    // Model path is provided via TEST_MODEL_PATH environment variable
    const modelPath = String.fromEnvironment('TEST_MODEL_PATH');
    if (modelPath.isEmpty) {
      throw Exception('TEST_MODEL_PATH environment variable is not set');
    }

    aiEdge = AiEdge.instance;
    await aiEdge.initialize(modelPath: modelPath, maxTokens: 512);
    await aiEdge.addQueryChunk('Keep your response short.');
  });

  tearDownAll(() async {
    await aiEdge.close();
  });

  group('Streaming Integration Tests', () {
    test(
      'Basic streaming with real model',
      () async {
        final stream = aiEdge.generateResponseAsync('What is 2+2?');
        final events = <GenerationEvent>[];

        await for (final event in stream) {
          events.add(event);
        }

        // Simply verify we got a response from the real model
        expect(events, isNotEmpty, reason: 'Should receive streaming events');
        expect(
          events.any((e) => e.done),
          isTrue,
          reason: 'Should have completion event',
        );

        // Verify the model actually responded with something meaningful
        final completeText = events.map((e) => e.partialResult).join();
        expect(
          completeText.toLowerCase(),
          contains('4'),
          reason: 'Model should answer the math question',
        );
      },
      timeout: const Timeout(Duration(seconds: 120)),
    );

    test(
      'Sequential streaming requests',
      () async {
        // Test that multiple streaming requests work in sequence
        const prompts = ['What is 1+1?', 'What is 2+2?'];

        for (final prompt in prompts) {
          final stream = aiEdge.generateResponseAsync(prompt);
          final events = <GenerationEvent>[];

          await for (final event in stream) {
            events.add(event);
          }

          // Verify we got a complete response
          expect(events, isNotEmpty);
          expect(events.any((e) => e.done), isTrue);

          await Future.delayed(const Duration(milliseconds: 500));
        }
      },
      timeout: const Timeout(Duration(seconds: 120)),
    );
  });
}
