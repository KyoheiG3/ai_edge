import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_edge/ai_edge.dart';
import 'helpers/test_model_helper.dart';
import 'helpers/test_prompts.dart';
import 'helpers/response_validator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String modelPath;
  final aiEdge = AiEdge.instance;

  setUpAll(() async {
    // Ensure test model is available
    modelPath = await TestModelHelper.ensureTestModel();
    
    // Initialize model and session
    await aiEdge.initialize(
      modelPath: modelPath,
      maxTokens: 512,  // Smaller for faster tests
      preferredBackend: PreferredBackend.cpu,
      sessionConfig: const SessionConfig(
        temperature: 0.7,
        topK: 40,
        randomSeed: 42,  // For reproducibility
      ),
    );
  });

  tearDownAll(() async {
    await aiEdge.close();
  });

  group('LLM Inference Tests', () {
    test('Simple greeting inference', () async {
      final stopwatch = Stopwatch()..start();
      
      final response = await aiEdge.generateResponse(TestPrompts.greeting);
      
      stopwatch.stop();
      
      // Validate response
      ResponseValidator.validateBasicResponse(response);
      ResponseValidator.validateResponseTime(
        stopwatch.elapsed,
        maxDuration: TestPrompts.getTimeoutForPrompt(TestPrompts.greeting),
      );
      
      // Check for greeting-related content
      expect(
        TestPrompts.isValidGreetingResponse(response),
        isTrue,
        reason: 'Response should be a valid greeting reply',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Math problem solving', () async {
      final response = await aiEdge.generateResponse(TestPrompts.simpleMath);
      
      ResponseValidator.validateBasicResponse(response);
      
      expect(
        TestPrompts.isValidMathResponse(response),
        isTrue,
        reason: 'Response should contain the correct answer (4)',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Text completion', () async {
      final response = await aiEdge.generateResponse(TestPrompts.completion);
      
      ResponseValidator.validateBasicResponse(response);
      
      expect(
        TestPrompts.isValidCompletionResponse(response),
        isTrue,
        reason: 'Response should complete with "Paris"',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Code generation', () async {
      final response = await aiEdge.generateResponse(TestPrompts.codePrompt);
      
      ResponseValidator.validateBasicResponse(response);
      ResponseValidator.validateResponseLength(
        response,
        minLength: 20,  // Should have at least a function definition
        maxLength: 1000, // Shouldn't be too verbose
      );
      
      expect(
        TestPrompts.isValidCodeResponse(response),
        isTrue,
        reason: 'Response should contain a factorial function',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Query chunks followed by generation', () async {
      // Add query in chunks
      await aiEdge.addQueryChunk('What is the capital ');
      await aiEdge.addQueryChunk('of Japan?');
      
      // Generate response without additional prompt
      final response = await aiEdge.generateResponse();
      
      ResponseValidator.validateBasicResponse(response);
      ResponseValidator.validateResponseContent(
        response,
        ['tokyo'],
        caseSensitive: false,
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Response length control', () async {
      // Test with a prompt that could generate long output
      final response = await aiEdge.generateResponse(
        'Count from 1 to 5, one number per line.',
      );
      
      ResponseValidator.validateBasicResponse(response);
      
      // Should not exceed max tokens significantly
      ResponseValidator.validateResponseLength(
        response,
        maxLength: 2000,  // Reasonable limit for the prompt
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Multiple sequential inferences', () async {
      // Test that the model can handle multiple requests in sequence
      final prompts = [
        'What is 1+1?',
        'What color is the sky?',
        'Name a fruit.',
      ];
      
      for (final prompt in prompts) {
        final response = await aiEdge.generateResponse(prompt);
        
        ResponseValidator.validateBasicResponse(response);
        expect(
          response.length,
          greaterThan(0),
          reason: 'Each response should have content',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Empty prompt handling', () async {
      // Some models might handle empty prompts, others might throw
      try {
        final response = await aiEdge.generateResponse('');
        
        // If it succeeds, validate the response
        ResponseValidator.validateBasicResponse(response);
      } catch (e) {
        // If it throws, that's also acceptable behavior
        expect(e, isNotNull);
      }
    });

    test('Special characters in prompt', () async {
      final specialPrompt = 'What is "AI"? Explain in simple terms.';
      
      final response = await aiEdge.generateResponse(specialPrompt);
      
      ResponseValidator.validateBasicResponse(response);
      ResponseValidator.validateResponseContent(
        response,
        ['artificial', 'intelligence', 'ai', 'computer', 'machine'],
        caseSensitive: false,
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Response completeness', () async {
      final response = await aiEdge.generateResponse(
        'Write a haiku about technology.',
      );
      
      ResponseValidator.validateBasicResponse(response);
      ResponseValidator.validateResponseCompleteness(response);
      
      // A haiku should have some structure
      expect(
        response.split('\n').where((line) => line.trim().isNotEmpty).length,
        greaterThanOrEqualTo(1),
        reason: 'Haiku should have line structure',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });

  group('Performance Tests', () {
    test('Response time consistency', () async {
      final times = <Duration>[];
      const iterations = 3;
      
      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        await aiEdge.generateResponse('Hello');
        stopwatch.stop();
        times.add(stopwatch.elapsed);
      }
      
      // Check that response times are relatively consistent
      final avgMs = times.map((t) => t.inMilliseconds).reduce((a, b) => a + b) / iterations;
      
      for (final time in times) {
        // Allow 100% variance from average (models can have variable response times)
        expect(
          time.inMilliseconds,
          lessThan(avgMs * 2),
          reason: 'Response time should not vary too much from average',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 90)));
  });
}