import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge/ai_edge.dart';

/// Validates AI model responses for integration testing
class ResponseValidator {
  /// Validates that a response is not empty and appears valid
  static void validateBasicResponse(String response, {String? testDescription}) {
    expect(
      response,
      isNotEmpty,
      reason: testDescription ?? 'Response should not be empty',
    );
    
    expect(
      response.trim(),
      isNotEmpty,
      reason: 'Response should not be only whitespace',
    );
    
    // Check for common error patterns
    expect(
      response.toLowerCase(),
      isNot(contains('error loading')),
      reason: 'Response should not contain loading errors',
    );
    
    expect(
      response.toLowerCase(),
      isNot(contains('failed to')),
      reason: 'Response should not contain failure messages',
    );
  }
  
  /// Validates streaming response events
  static void validateStreamingEvent(GenerationEvent event) {
    expect(
      event.partialResult,
      isNotNull,
      reason: 'Event partial result should not be null',
    );
    
    // If the event is done, the partial result should have content
    if (event.done) {
      expect(
        event.partialResult,
        isNotEmpty,
        reason: 'Complete event should have text',
      );
    }
  }
  
  /// Validates a complete streaming response
  static void validateStreamingResponse(List<GenerationEvent> events) {
    expect(
      events,
      isNotEmpty,
      reason: 'Should receive at least one streaming event',
    );
    
    // Check for at least one non-done event (partial result)
    final hasPartialResults = events.any((e) => !e.done);
    expect(
      hasPartialResults,
      isTrue,
      reason: 'Streaming should include partial results',
    );
    
    // Check for completion
    final hasComplete = events.any((e) => e.done);
    expect(
      hasComplete,
      isTrue,
      reason: 'Streaming should end with a complete result',
    );
    
    // Validate order: partials should come before complete
    var foundComplete = false;
    for (final event in events) {
      if (event.done) {
        foundComplete = true;
      } else if (!event.done && foundComplete) {
        fail('Received partial result after complete result');
      }
    }
    
    // Build complete text from events
    final completeText = events
        .map((e) => e.partialResult)
        .join();
    
    validateBasicResponse(completeText, 
      testDescription: 'Complete streamed response should be valid');
  }
  
  /// Validates response time is within acceptable limits
  static void validateResponseTime(
    Duration elapsed, {
    Duration? maxDuration,
    String? testDescription,
  }) {
    final limit = maxDuration ?? const Duration(seconds: 30);
    
    expect(
      elapsed.inMilliseconds,
      lessThanOrEqualTo(limit.inMilliseconds),
      reason: testDescription ?? 
        'Response time (${elapsed.inSeconds}s) should not exceed ${limit.inSeconds}s',
    );
  }
  
  /// Validates that a response contains expected content
  static void validateResponseContent(
    String response,
    List<String> expectedKeywords, {
    bool caseSensitive = false,
    bool requireAll = false,
  }) {
    final checkResponse = caseSensitive ? response : response.toLowerCase();
    final checkKeywords = caseSensitive 
      ? expectedKeywords 
      : expectedKeywords.map((k) => k.toLowerCase()).toList();
    
    if (requireAll) {
      for (final keyword in checkKeywords) {
        expect(
          checkResponse,
          contains(keyword),
          reason: 'Response should contain "$keyword"',
        );
      }
    } else {
      final containsAny = checkKeywords.any((k) => checkResponse.contains(k));
      expect(
        containsAny,
        isTrue,
        reason: 'Response should contain at least one of: ${expectedKeywords.join(", ")}',
      );
    }
  }
  
  /// Validates response length is within expected bounds
  static void validateResponseLength(
    String response, {
    int? minLength,
    int? maxLength,
  }) {
    if (minLength != null) {
      expect(
        response.length,
        greaterThanOrEqualTo(minLength),
        reason: 'Response should be at least $minLength characters',
      );
    }
    
    if (maxLength != null) {
      expect(
        response.length,
        lessThanOrEqualTo(maxLength),
        reason: 'Response should not exceed $maxLength characters',
      );
    }
  }
  
  /// Checks if response appears to be truncated unexpectedly
  static void validateResponseCompleteness(String response) {
    final lastChar = response.isNotEmpty ? response[response.length - 1] : '';
    final endsWithPunctuation = '.!?;:,)"\''.contains(lastChar);
    final endsWithNewline = response.endsWith('\n');
    
    // Response should end naturally
    expect(
      endsWithPunctuation || endsWithNewline || response.endsWith(' '),
      isTrue,
      reason: 'Response appears to be truncated mid-word',
    );
    
    // Check for common truncation patterns
    expect(
      response,
      isNot(endsWith('...')),
      reason: 'Response should not end with ellipsis (possible truncation)',
    );
  }
}