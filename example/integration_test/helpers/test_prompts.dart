/// Test prompts for integration testing
/// These prompts are designed to be reproducible and testable
class TestPrompts {
  /// Simple greeting prompt for basic functionality test
  static const String greeting = "Hello, how are you?";
  
  /// Math problem for testing logical reasoning
  static const String simpleMath = "What is 2 + 2?";
  
  /// Completion prompt for testing generation
  static const String completion = "The capital of France is";
  
  /// Short story prompt for testing longer generation
  static const String shortStory = "Once upon a time, there was a";
  
  /// JSON generation prompt for structured output (future tool calling)
  static const String jsonPrompt = '''
Generate a JSON object with the following fields:
- name: a person's name
- age: a number between 20 and 50
- city: a city name

Respond only with valid JSON.
''';
  
  /// Code generation prompt
  static const String codePrompt = "Write a Python function that returns the factorial of a number. Only provide the code without explanation.";
  
  /// Streaming test prompt - designed to generate longer output
  static const String streamingPrompt = "List 5 interesting facts about artificial intelligence. Be detailed in your response.";
  
  /// Error handling test - intentionally problematic prompt
  static String get errorPrompt => String.fromCharCodes(
    List.generate(10000, (i) => 65 + (i % 26)), // Very long repetitive prompt
  );
  
  /// Tool calling preparation prompt (for future implementation)
  static const String toolCallingPrompt = '''
You have access to the following tools:
- calculate(expression: string): Evaluates a mathematical expression
- get_weather(city: string): Gets current weather for a city

User: What's 15 * 23 and what's the weather in Tokyo?

Use the tools to answer this question.
''';
  
  /// Validation helpers
  static bool isValidGreetingResponse(String response) {
    final lowerResponse = response.toLowerCase();
    return lowerResponse.contains('hello') || 
           lowerResponse.contains('hi') || 
           lowerResponse.contains('good') ||
           lowerResponse.contains('fine') ||
           lowerResponse.contains('well');
  }
  
  static bool isValidMathResponse(String response) {
    return response.contains('4') || response.contains('four');
  }
  
  static bool isValidCompletionResponse(String response) {
    final lowerResponse = response.toLowerCase();
    return lowerResponse.contains('paris');
  }
  
  static bool isValidStoryResponse(String response) {
    // Should continue the story in some way
    return response.length > 10 && !response.toLowerCase().contains('error');
  }
  
  static bool isValidJsonResponse(String response) {
    try {
      // Try to find JSON in the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      
      if (jsonStart == -1 || jsonEnd == -1) return false;
      
      // Would normally use json.decode here, but keeping it simple for test
      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      return jsonStr.contains('"name"') && 
             jsonStr.contains('"age"') && 
             jsonStr.contains('"city"');
    } catch (e) {
      return false;
    }
  }
  
  static bool isValidCodeResponse(String response) {
    final lowerResponse = response.toLowerCase();
    return lowerResponse.contains('def') && 
           lowerResponse.contains('factorial') &&
           (lowerResponse.contains('return') || lowerResponse.contains('yield'));
  }
  
  static bool isValidStreamingResponse(String response) {
    // Should have multiple facts/points
    final lines = response.split('\n').where((line) => line.trim().isNotEmpty);
    return lines.length >= 3 && response.length > 100;
  }
  
  /// Get a timeout duration based on prompt type
  static Duration getTimeoutForPrompt(String prompt) {
    if (prompt == errorPrompt) {
      return const Duration(seconds: 10);
    } else if (prompt == streamingPrompt || prompt == shortStory) {
      return const Duration(seconds: 30);
    } else {
      return const Duration(seconds: 20);
    }
  }
}