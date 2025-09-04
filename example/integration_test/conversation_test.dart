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

  group('Conversation Tests', () {
    test('Basic question and answer', () async {
      final response = await aiEdge.generateResponse('What is 2+2?');

      expect(response, isNotEmpty);
      expect(
        response.toLowerCase(),
        contains('4'),
        reason: 'Model should answer the math question',
      );
    }, timeout: const Timeout(Duration(seconds: 120)));

    test(
      'Conversation context retention',
      () async {
        // Provide context
        await aiEdge.addQueryChunk('My name is Alice and I like cats.');

        // First question using context
        final response1 = await aiEdge.generateResponse('What is my name?');
        expect(response1, isNotEmpty);
        expect(
          response1.toLowerCase(),
          contains('alice'),
          reason: 'Model should remember the name from context',
        );

        // Follow-up question in same conversation
        final response2 = await aiEdge.generateResponse(
          'What animal do I like?',
        );
        expect(response2, isNotEmpty);
        expect(
          response2.toLowerCase(),
          contains('cat'),
          reason: 'Model should remember the preference from context',
        );
      },
      timeout: const Timeout(Duration(seconds: 120)),
    );

    test('Different types of prompts', () async {
      final testCases = [
        ('What is the capital of Japan?', 'tokyo'),
        ('Translate "hello" to Spanish', ['hola', 'buenos']),
        ('What color is the sky?', ['blue', 'gray']),
      ];

      for (final (prompt, expectedKeywords) in testCases) {
        final response = await aiEdge.generateResponse(prompt);

        expect(response, isNotEmpty);

        final keywords = expectedKeywords is List
            ? expectedKeywords
            : [expectedKeywords];
        final containsKeyword = keywords.any(
          (keyword) => response.toLowerCase().contains(keyword),
        );

        expect(
          containsKeyword,
          isTrue,
          reason: 'Response for "$prompt" should contain one of: $keywords',
        );

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}
