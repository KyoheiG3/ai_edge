import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge/ai_edge.dart';
import 'package:ai_edge/ai_edge_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiEdgePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements AiEdgePlatform {
  final List<String> methodCalls = [];
  ModelConfig? lastModelConfig;
  SessionConfig? lastSessionConfig;
  String? lastPrompt;
  Uint8List? lastImageBytes;
  
  @override
  Future<void> createModel(ModelConfig config) async {
    methodCalls.add('createModel');
    lastModelConfig = config;
  }

  @override
  Future<void> createSession(SessionConfig config) async {
    methodCalls.add('createSession');
    lastSessionConfig = config;
  }

  @override
  Future<void> close() async {
    methodCalls.add('close');
  }

  @override
  Future<void> addQueryChunk(String prompt) async {
    methodCalls.add('addQueryChunk');
    lastPrompt = prompt;
  }

  @override
  Future<void> addImage(Uint8List imageBytes) async {
    methodCalls.add('addImage');
    lastImageBytes = imageBytes;
  }

  @override
  Future<String> generateResponse(String? prompt) async {
    methodCalls.add('generateResponse');
    lastPrompt = prompt;
    return 'Test response';
  }

  @override
  Future<void> generateResponseAsync(String? prompt) async {
    methodCalls.add('generateResponseAsync');
    lastPrompt = prompt;
  }

  bool shouldThrowError = false;

  @override
  Stream<GenerationEvent> getPartialResultStream() {
    if (shouldThrowError) {
      return Stream.error(Exception('Test error'));
    }
    return Stream.fromIterable([
      const GenerationEvent(partialResult: 'Hello', done: false),
      const GenerationEvent(partialResult: ' World', done: false),
      const GenerationEvent(partialResult: '', done: true),
    ]);
  }
}

void main() {
  group('AiEdge', () {
    late MockAiEdgePlatform mockPlatform;
    late AiEdge aiEdge;

    setUp(() {
      mockPlatform = MockAiEdgePlatform();
      AiEdgePlatform.instance = mockPlatform;
      aiEdge = AiEdge.instance;
    });

    group('createModel', () {
      group('when called with valid model config', () {
        test('then platform createModel is invoked', () async {
          // Given
          const config = ModelConfig(
            modelPath: '/path/to/model',
            maxTokens: 256,
          );

          // When
          await aiEdge.createModel(config);

          // Then
          expect(mockPlatform.methodCalls, contains('createModel'));
          expect(mockPlatform.lastModelConfig, equals(config));
        });
      });

      group('when called with optional parameters', () {
        test('then all parameters are passed', () async {
          // Given
          const config = ModelConfig(
            modelPath: '/path/to/model',
            maxTokens: 512,
            supportedLoraRanks: [4, 8],
            preferredBackend: PreferredBackend.gpu,
            maxNumImages: 3,
          );

          // When
          await aiEdge.createModel(config);

          // Then
          expect(mockPlatform.lastModelConfig?.modelPath, equals('/path/to/model'));
          expect(mockPlatform.lastModelConfig?.maxTokens, equals(512));
          expect(mockPlatform.lastModelConfig?.supportedLoraRanks, equals([4, 8]));
          expect(mockPlatform.lastModelConfig?.preferredBackend, equals(PreferredBackend.gpu));
          expect(mockPlatform.lastModelConfig?.maxNumImages, equals(3));
        });
      });
    });

    group('createSession', () {
      group('when called with valid session config', () {
        test('then platform createSession is invoked', () async {
          // Given
          const config = SessionConfig(
            temperature: 0.7,
            randomSeed: 42,
            topK: 20,
          );

          // When
          await aiEdge.createSession(config);

          // Then
          expect(mockPlatform.methodCalls, contains('createSession'));
          expect(mockPlatform.lastSessionConfig, equals(config));
        });
      });

      group('when called with default session config', () {
        test('then default values are used', () async {
          // Given
          const config = SessionConfig();

          // When
          await aiEdge.createSession(config);

          // Then
          expect(mockPlatform.lastSessionConfig?.temperature, equals(0.8));
          expect(mockPlatform.lastSessionConfig?.randomSeed, equals(1));
          expect(mockPlatform.lastSessionConfig?.topK, equals(40));
        });
      });
    });

    group('initialize', () {
      group('when called with model params and no session config', () {
        test('then both model and session are created', () async {
          // Given
          const modelPath = '/path/to/model';
          const maxTokens = 256;

          // When
          await aiEdge.initialize(
            modelPath: modelPath,
            maxTokens: maxTokens,
          );

          // Then
          expect(mockPlatform.methodCalls, equals(['createModel', 'createSession']));
          expect(mockPlatform.lastModelConfig?.modelPath, equals(modelPath));
          expect(mockPlatform.lastModelConfig?.maxTokens, equals(maxTokens));
          expect(mockPlatform.lastSessionConfig, isNotNull);
        });
      });

      group('when called with model params and custom session config', () {
        test('then custom config is used', () async {
          // Given
          const modelPath = '/path/to/model';
          const maxTokens = 256;
          const sessionConfig = SessionConfig(
            temperature: 0.5,
            randomSeed: 123,
            topK: 30,
          );

          // When
          await aiEdge.initialize(
            modelPath: modelPath,
            maxTokens: maxTokens,
            sessionConfig: sessionConfig,
          );

          // Then
          expect(mockPlatform.methodCalls, equals(['createModel', 'createSession']));
          expect(mockPlatform.lastSessionConfig?.temperature, equals(0.5));
          expect(mockPlatform.lastSessionConfig?.randomSeed, equals(123));
          expect(mockPlatform.lastSessionConfig?.topK, equals(30));
        });
      });
    });

    group('close', () {
      group('when called', () {
        test('then platform close is invoked', () async {
          // Given
          // AiEdge is already initialized in setUp

          // When
          await aiEdge.close();

          // Then
          expect(mockPlatform.methodCalls, contains('close'));
        });
      });
    });

    group('addQueryChunk', () {
      group('when called with a prompt', () {
        test('then platform addQueryChunk is invoked', () async {
          // Given
          const prompt = 'Test prompt';

          // When
          await aiEdge.addQueryChunk(prompt);

          // Then
          expect(mockPlatform.methodCalls, contains('addQueryChunk'));
          expect(mockPlatform.lastPrompt, equals(prompt));
        });
      });
    });

    group('addImage', () {
      group('when called with image bytes', () {
        test('then platform addImage is invoked', () async {
          // Given
          final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

          // When
          await aiEdge.addImage(imageBytes);

          // Then
          expect(mockPlatform.methodCalls, contains('addImage'));
          expect(mockPlatform.lastImageBytes, equals(imageBytes));
        });
      });
    });

    group('generateResponse', () {
      group('when called without prompt', () {
        test('then response is returned', () async {
          // Given
          // No prompt

          // When
          final response = await aiEdge.generateResponse();

          // Then
          expect(response, equals('Test response'));
          expect(mockPlatform.methodCalls, contains('generateResponse'));
        });
      });

      group('when called with prompt', () {
        test('then prompt is passed and response is returned', () async {
          // Given
          const prompt = 'Test prompt';

          // When
          final response = await aiEdge.generateResponse(prompt);

          // Then
          expect(response, equals('Test response'));
          expect(mockPlatform.lastPrompt, equals(prompt));
        });
      });
    });

    group('generateResponseAsync', () {
      group('when stream events arrive in order', () {
        test('then partial events come before done event', () async {
          // Given
          mockPlatform = MockAiEdgePlatform();
          AiEdgePlatform.instance = mockPlatform;
          aiEdge = AiEdge.instance;

          // When
          final stream = aiEdge.generateResponseAsync();
          final events = await stream.toList();

          // Then - validate event ordering
          var foundDone = false;
          for (final event in events) {
            if (event.done) {
              foundDone = true;
            } else if (foundDone) {
              fail('Received partial event after done event');
            }
          }
          expect(foundDone, isTrue, reason: 'Should have a done event');
        });
      });

      group('when accumulating partial results', () {
        test('then complete text is built correctly', () async {
          // Given
          mockPlatform = MockAiEdgePlatform();
          AiEdgePlatform.instance = mockPlatform;
          aiEdge = AiEdge.instance;

          // When
          final stream = aiEdge.generateResponseAsync();
          final events = await stream.toList();
          
          // Accumulate partial results
          String accumulated = '';
          for (final event in events) {
            if (!event.done) {
              accumulated += event.partialResult;
            }
          }

          // Then
          expect(accumulated, equals('Hello World'));
        });
      });
      group('when called without prompt', () {
        test('then stream of events is returned', () async {
          // Given
          // No prompt

          // When
          final stream = aiEdge.generateResponseAsync();
          final events = await stream.toList();

          // Then
          expect(events.length, equals(3));
          expect(events[0].partialResult, equals('Hello'));
          expect(events[0].done, isFalse);
          expect(events[1].partialResult, equals(' World'));
          expect(events[1].done, isFalse);
          expect(events[2].partialResult, equals(''));
          expect(events[2].done, isTrue);
        });
      });

      group('when called with prompt', () {
        test('then prompt is passed to platform', () async {
          // Given
          const prompt = 'Test prompt';

          // When
          final stream = aiEdge.generateResponseAsync(prompt);
          await stream.toList();

          // Then
          expect(mockPlatform.methodCalls, contains('generateResponseAsync'));
          expect(mockPlatform.lastPrompt, equals(prompt));
        });
      });

      group('when stream has error', () {
        test('then error is propagated', () async {
          // Given
          mockPlatform.shouldThrowError = true;

          // When
          final stream = aiEdge.generateResponseAsync();
          
          // Then
          expectLater(
            stream,
            emitsError(isA<Exception>()),
          );
        });
        
        tearDown(() {
          // Reset error flag for other tests
          mockPlatform.shouldThrowError = false;
        });
      });

      group('when stream completes normally', () {
        test('then controller is closed', () async {
          // Given
          // No special setup needed

          // When
          final stream = aiEdge.generateResponseAsync();
          final events = await stream.toList();

          // Then
          expect(events.length, equals(3));
          // Verify stream completed successfully
          expect(events.last.done, isTrue);
        });
      });
      
      group('when validating streaming response', () {
        test('then should have partial results before done', () async {
          // Given
          mockPlatform = MockAiEdgePlatform();
          AiEdgePlatform.instance = mockPlatform;
          aiEdge = AiEdge.instance;

          // When
          final stream = aiEdge.generateResponseAsync();
          final events = await stream.toList();

          // Then
          final hasPartialResults = events.any((e) => !e.done);
          expect(hasPartialResults, isTrue, 
            reason: 'Streaming should include partial results');
          
          final hasComplete = events.any((e) => e.done);
          expect(hasComplete, isTrue,
            reason: 'Streaming should end with a complete result');
        });
      });
    });
  });

  group('Types', () {
    group('ModelConfig', () {
      group('when toMap is called with all parameters', () {
        test('then map contains all values', () {
          // Given
          const config = ModelConfig(
            modelPath: '/path/to/model',
            maxTokens: 256,
            supportedLoraRanks: [4, 8],
            preferredBackend: PreferredBackend.gpu,
            maxNumImages: 3,
          );

          // When
          final map = config.toMap();

          // Then
          expect(map['modelPath'], equals('/path/to/model'));
          expect(map['maxTokens'], equals(256));
          expect(map['loraRanks'], equals([4, 8]));
          expect(map['preferredBackend'], equals(PreferredBackend.gpu.value));
          expect(map['maxNumImages'], equals(3));
        });
      });

      group('when toMap is called with only required parameters', () {
        test('then map contains only required values', () {
          // Given
          const config = ModelConfig(
            modelPath: '/path/to/model',
            maxTokens: 256,
          );

          // When
          final map = config.toMap();

          // Then
          expect(map['modelPath'], equals('/path/to/model'));
          expect(map['maxTokens'], equals(256));
          expect(map.containsKey('loraRanks'), isFalse);
          expect(map.containsKey('preferredBackend'), isFalse);
          expect(map.containsKey('maxNumImages'), isFalse);
        });
      });
    });

    group('SessionConfig', () {
      group('when toMap is called with all parameters', () {
        test('then map contains all values', () {
          // Given
          const config = SessionConfig(
            temperature: 0.7,
            randomSeed: 42,
            topK: 20,
            topP: 0.9,
            loraPath: '/path/to/lora',
            enableVisionModality: true,
          );

          // When
          final map = config.toMap();

          // Then
          expect(map['temperature'], equals(0.7));
          expect(map['randomSeed'], equals(42));
          expect(map['topK'], equals(20));
          expect(map['topP'], equals(0.9));
          expect(map['loraPath'], equals('/path/to/lora'));
          expect(map['enableVisionModality'], isTrue);
        });
      });

      group('when toMap is called with default parameters', () {
        test('then map contains default values', () {
          // Given
          const config = SessionConfig();

          // When
          final map = config.toMap();

          // Then
          expect(map['temperature'], equals(0.8));
          expect(map['randomSeed'], equals(1));
          expect(map['topK'], equals(40));
          expect(map.containsKey('topP'), isFalse);
          expect(map.containsKey('loraPath'), isFalse);
          expect(map.containsKey('enableVisionModality'), isFalse);
        });
      });
    });

    group('GenerationEvent', () {
      group('when fromMap is called with valid map', () {
        test('then GenerationEvent is created', () {
          // Given
          final map = {
            'partialResult': 'Hello World',
            'done': true,
          };

          // When
          final event = GenerationEvent.fromMap(map);

          // Then
          expect(event.partialResult, equals('Hello World'));
          expect(event.done, isTrue);
        });
      });

      group('when fromMap is called with missing values', () {
        test('then defaults are used', () {
          // Given
          final map = <String, dynamic>{};

          // When
          final event = GenerationEvent.fromMap(map);

          // Then
          expect(event.partialResult, equals(''));
          expect(event.done, isFalse);
        });
      });
    });

    group('PreferredBackend', () {
      group('when value is accessed', () {
        test('then correct value is returned', () {
          // Given
          const backends = [
            PreferredBackend.unknown,
            PreferredBackend.cpu,
            PreferredBackend.gpu,
          ];

          // When & Then
          expect(backends[0].value, equals(0));
          expect(backends[1].value, equals(1));
          expect(backends[2].value, equals(2));
        });
      });
    });
  });
}