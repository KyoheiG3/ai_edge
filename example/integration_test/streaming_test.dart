import 'dart:async';
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
      maxTokens: 512,
      preferredBackend: PreferredBackend.cpu,
      sessionConfig: const SessionConfig(
        temperature: 0.7,
        topK: 40,
        randomSeed: 42,
      ),
    );
  });

  tearDownAll(() async {
    await aiEdge.close();
  });

  group('Streaming Response Tests', () {
    test('Basic streaming functionality', () async {
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync(TestPrompts.greeting);
      
      await for (final event in stream) {
        events.add(event);
        ResponseValidator.validateStreamingEvent(event);
      }
      
      // Validate the complete stream
      ResponseValidator.validateStreamingResponse(events);
      
      // Build complete response
      final completeText = events
          .map((e) => e.partialResult)
          .join();
      
      expect(
        TestPrompts.isValidGreetingResponse(completeText),
        isTrue,
        reason: 'Streamed response should be a valid greeting',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Streaming with longer content', () async {
      final events = <GenerationEvent>[];
      final stopwatch = Stopwatch()..start();
      
      final stream = aiEdge.generateResponseAsync(TestPrompts.streamingPrompt);
      
      await for (final event in stream) {
        events.add(event);
      }
      
      stopwatch.stop();
      
      ResponseValidator.validateStreamingResponse(events);
      
      // Should have multiple partial results for longer content
      expect(
        events.where((e) => !e.done).length,
        greaterThan(1),
        reason: 'Longer content should produce multiple partial results',
      );
      
      // Build and validate complete response
      final completeText = events
          .map((e) => e.partialResult)
          .join();
      
      expect(
        TestPrompts.isValidStreamingResponse(completeText),
        isTrue,
        reason: 'Response should contain multiple facts about AI',
      );
    }, timeout: const Timeout(Duration(seconds: 45)));

    test('Stream cancellation', () async {
      final events = <GenerationEvent>[];
      final completer = Completer<void>();
      
      final stream = aiEdge.generateResponseAsync(TestPrompts.shortStory);
      final subscription = stream.listen(
        (event) {
          events.add(event);
          
          // Cancel after receiving first few events
          if (events.length >= 3 && !completer.isCompleted) {
            completer.complete();
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );
      
      // Wait for a few events or timeout
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );
      
      // Cancel the subscription
      await subscription.cancel();
      
      // We should have received some events
      expect(
        events,
        isNotEmpty,
        reason: 'Should receive some events before cancellation',
      );
    });

    test('Streaming with query chunks', () async {
      // Add query in chunks
      await aiEdge.addQueryChunk('Tell me about ');
      await aiEdge.addQueryChunk('the weather');
      
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync();
      
      await for (final event in stream) {
        events.add(event);
      }
      
      ResponseValidator.validateStreamingResponse(events);
      
      final completeText = events
          .map((e) => e.partialResult)
          .join();
      
      ResponseValidator.validateBasicResponse(completeText);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Multiple streaming requests', () async {
      // Test that we can make multiple streaming requests
      for (int i = 0; i < 3; i++) {
        final events = <GenerationEvent>[];
        
        final stream = aiEdge.generateResponseAsync('Say hello $i');
        
        await for (final event in stream) {
          events.add(event);
        }
        
        expect(
          events,
          isNotEmpty,
          reason: 'Each streaming request should produce events',
        );
        
        final hasComplete = events.any((e) => e.done);
        expect(
          hasComplete,
          isTrue,
          reason: 'Each stream should complete',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('Stream event ordering', () async {
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync(TestPrompts.completion);
      
      await for (final event in stream) {
        events.add(event);
      }
      
      // Check that events are properly ordered
      var foundDone = false;
      for (final event in events) {
        if (foundDone) {
          fail('Received event after done event');
        }
        if (event.done) {
          foundDone = true;
        }
      }
      
      expect(
        foundDone,
        isTrue,
        reason: 'Stream should end with a done event',
      );
    });

    test('Stream partial result accumulation', () async {
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync(
        'Count from 1 to 3',
      );
      
      await for (final event in stream) {
        events.add(event);
      }
      
      // Build text progressively as it would appear to user
      var accumulatedText = '';
      for (final event in events) {
        accumulatedText += event.partialResult;
        
        // Each accumulation should be valid text
        expect(
          accumulatedText,
          isNotEmpty,
          reason: 'Accumulated text should grow with each event',
        );
      }
      
      // Final accumulated text should contain the numbers
      expect(
        accumulatedText.contains('1') &&
        accumulatedText.contains('2') &&
        accumulatedText.contains('3'),
        isTrue,
        reason: 'Response should contain the requested numbers',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Stream error handling', () async {
      // Test with potentially problematic input
      final events = <GenerationEvent>[];
      var hasError = false;
      
      try {
        final stream = aiEdge.generateResponseAsync(TestPrompts.errorPrompt);
        
        await for (final event in stream) {
          events.add(event);
          
          // Limit how many events we collect for error case
          if (events.length > 100) {
            break;
          }
        }
      } catch (e) {
        hasError = true;
        expect(e, isNotNull, reason: 'Error should have details');
      }
      
      // Either we got an error or we got some response
      expect(
        hasError || events.isNotEmpty,
        isTrue,
        reason: 'Should either handle error or produce output',
      );
    });

    test('Stream timing characteristics', () async {
      final eventTimes = <DateTime>[];
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync(
        'Write three sentences about space.',
      );
      
      await for (final event in stream) {
        eventTimes.add(DateTime.now());
        events.add(event);
      }
      
      if (events.length > 1) {
        // Calculate time between events
        final delays = <Duration>[];
        for (int i = 1; i < eventTimes.length; i++) {
          delays.add(eventTimes[i].difference(eventTimes[i - 1]));
        }
        
        // Events should come at reasonable intervals
        for (final delay in delays) {
          expect(
            delay.inSeconds,
            lessThan(10),
            reason: 'Events should not be delayed by more than 10 seconds',
          );
        }
      }
    }, timeout: const Timeout(Duration(seconds: 45)));
  });

  group('Streaming Edge Cases', () {
    test('Empty prompt streaming', () async {
      try {
        final events = <GenerationEvent>[];
        final stream = aiEdge.generateResponseAsync('');
        
        await for (final event in stream) {
          events.add(event);
        }
        
        // If it works, validate the response
        if (events.isNotEmpty) {
          ResponseValidator.validateStreamingResponse(events);
        }
      } catch (e) {
        // Empty prompt might throw, which is acceptable
        expect(e, isNotNull);
      }
    });

    test('Very short prompt streaming', () async {
      final events = <GenerationEvent>[];
      
      final stream = aiEdge.generateResponseAsync('Hi');
      
      await for (final event in stream) {
        events.add(event);
      }
      
      ResponseValidator.validateStreamingResponse(events);
      
      // Even short prompts should produce valid streaming
      expect(
        events.any((e) => e.done),
        isTrue,
        reason: 'Stream should complete even for short prompts',
      );
    });
  });
}