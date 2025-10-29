import 'package:ai_edge/ai_edge.dart';
import 'package:ai_edge_rag/src/ai_edge_rag.dart';
import 'package:ai_edge_rag/src/ai_edge_rag_method_channel.dart';
import 'package:ai_edge_rag/src/ai_edge_rag_platform_interface.dart';
import 'package:ai_edge_rag/src/types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiEdgeRagPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements AiEdgeRagPlatform {
  final List<String> methodCalls = [];
  Map<String, dynamic>? lastModelConfig;
  Map<String, dynamic>? lastSessionConfig;
  Map<String, dynamic>? lastEmbeddingModelConfig;
  Map<String, dynamic>? lastGeminiEmbedderConfig;
  Map<String, dynamic>? lastMemorizeChunkArguments;
  Map<String, dynamic>? lastMemorizeChunksArguments;
  Map<String, dynamic>? lastMemorizeChunkedTextArguments;
  Map<String, dynamic>? lastSystemInstructionArguments;
  Map<String, dynamic>? lastGenerateResponseAsyncArguments;
  bool shouldThrowOnClose = false;

  @override
  Future<void> createModel(Map<String, dynamic> options) async {
    methodCalls.add('createModel');
    lastModelConfig = options;
  }

  @override
  Future<void> createSession(Map<String, dynamic> arguments) async {
    methodCalls.add('createSession');
    lastSessionConfig = arguments;
  }

  @override
  Future<void> createEmbeddingModel(Map<String, dynamic> arguments) async {
    methodCalls.add('createEmbeddingModel');
    lastEmbeddingModelConfig = arguments;
  }

  @override
  Future<void> createGeminiEmbedder(Map<String, dynamic> arguments) async {
    methodCalls.add('createGeminiEmbedder');
    lastGeminiEmbedderConfig = arguments;
  }

  @override
  Future<void> memorizeChunk(Map<String, dynamic> arguments) async {
    methodCalls.add('memorizeChunk');
    lastMemorizeChunkArguments = arguments;
  }

  @override
  Future<void> memorizeChunks(Map<String, dynamic> arguments) async {
    methodCalls.add('memorizeChunks');
    lastMemorizeChunksArguments = arguments;
  }

  @override
  Future<void> memorizeChunkedText(Map<String, dynamic> arguments) async {
    methodCalls.add('memorizeChunkedText');
    lastMemorizeChunkedTextArguments = arguments;
  }

  @override
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) async {
    methodCalls.add('setSystemInstruction');
    lastSystemInstructionArguments = arguments;
  }

  @override
  Future<void> generateResponseAsync(Map<String, dynamic> arguments) async {
    methodCalls.add('generateResponseAsync');
    lastGenerateResponseAsyncArguments = arguments;
  }

  @override
  Stream<GenerationEvent> getPartialResultStream() {
    return Stream.value(
      const GenerationEvent(partialResult: 'Test response', done: true),
    );
  }

  @override
  Future<void> close() async {
    methodCalls.add('close');
    if (shouldThrowOnClose) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Session is still processing',
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiEdgeRag', () {
    late MockAiEdgeRagPlatform mockPlatform;
    late AiEdgeRag aiEdgeRag;

    setUp(() {
      mockPlatform = MockAiEdgeRagPlatform();
      AiEdgeRagPlatform.instance = mockPlatform;
      aiEdgeRag = AiEdgeRag.instance;
    });

    group('Platform setup', () {
      test('default instance is MethodChannelAiEdgeRag', () {
        // Reset to default
        AiEdgeRagPlatform.instance = MethodChannelAiEdgeRag();
        expect(
          AiEdgeRagPlatform.instance,
          isInstanceOf<MethodChannelAiEdgeRag>(),
        );
        // Restore mock for other tests
        AiEdgeRagPlatform.instance = mockPlatform;
      });
    });

    group('createModel', () {
      group('when called with model parameters', () {
        test('then platform createModel is invoked', () async {
          // When
          await aiEdgeRag.createModel(
            modelPath: '/path/to/model.task',
            maxTokens: 256,
          );

          // Then
          expect(mockPlatform.methodCalls, contains('createModel'));
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model.task'),
          );
          expect(mockPlatform.lastModelConfig?['maxTokens'], equals(256));
        });
      });

      group('when called with all optional parameters', () {
        test('then all parameters are passed', () async {
          // When
          await aiEdgeRag.createModel(
            modelPath: '/path/to/model.task',
            maxTokens: 512,
            supportedLoraRanks: [4, 8],
            preferredBackend: PreferredBackend.gpu,
            maxNumImages: 3,
          );

          // Then
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model.task'),
          );
          expect(mockPlatform.lastModelConfig?['maxTokens'], equals(512));
          expect(mockPlatform.lastModelConfig?['loraRanks'], equals([4, 8]));
          expect(
            mockPlatform.lastModelConfig?['preferredBackend'],
            equals(PreferredBackend.gpu.value),
          );
          expect(mockPlatform.lastModelConfig?['maxNumImages'], equals(3));
        });
      });
    });

    group('createSession', () {
      group('when called with session parameters', () {
        test('then platform createSession is invoked', () async {
          // When
          await aiEdgeRag.createSession(
            temperature: 0.7,
            randomSeed: 42,
            topK: 20,
          );

          // Then
          expect(mockPlatform.methodCalls, contains('createSession'));
          expect(mockPlatform.lastSessionConfig?['temperature'], equals(0.7));
          expect(mockPlatform.lastSessionConfig?['randomSeed'], equals(42));
          expect(mockPlatform.lastSessionConfig?['topK'], equals(20));
        });
      });

      group('when called with no parameters', () {
        test('then default values are used', () async {
          // When
          await aiEdgeRag.createSession();

          // Then
          expect(mockPlatform.lastSessionConfig?['temperature'], equals(0.8));
          expect(mockPlatform.lastSessionConfig?['randomSeed'], equals(1));
          expect(mockPlatform.lastSessionConfig?['topK'], equals(40));
        });
      });
    });

    group('initialize', () {
      group('when called with model params and no session params', () {
        test('then both model and session are created', () async {
          // When
          await aiEdgeRag.initialize(
            modelPath: '/path/to/model.task',
            maxTokens: 256,
          );

          // Then
          expect(
            mockPlatform.methodCalls,
            equals(['createModel', 'createSession']),
          );
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model.task'),
          );
          expect(mockPlatform.lastModelConfig?['maxTokens'], equals(256));
          expect(mockPlatform.lastSessionConfig, isNotNull);
        });
      });

      group('when called with model params and custom session params', () {
        test('then custom params are used', () async {
          // When
          await aiEdgeRag.initialize(
            modelPath: '/path/to/model.task',
            maxTokens: 256,
            temperature: 0.5,
            randomSeed: 123,
            topK: 30,
          );

          // Then
          expect(
            mockPlatform.methodCalls,
            equals(['createModel', 'createSession']),
          );
          expect(mockPlatform.lastSessionConfig?['temperature'], equals(0.5));
          expect(mockPlatform.lastSessionConfig?['randomSeed'], equals(123));
          expect(mockPlatform.lastSessionConfig?['topK'], equals(30));
        });
      });
    });

    group('createEmbeddingModel', () {
      group('when called with required parameters', () {
        test('then platform createEmbeddingModel is invoked', () async {
          // When
          await aiEdgeRag.createEmbeddingModel(
            tokenizerModelPath: '/path/to/tokenizer.model',
            embeddingModelPath: '/path/to/embedding.bin',
          );

          // Then
          expect(mockPlatform.methodCalls, contains('createEmbeddingModel'));
          expect(
            mockPlatform.lastEmbeddingModelConfig?['tokenizerModelPath'],
            equals('/path/to/tokenizer.model'),
          );
          expect(
            mockPlatform.lastEmbeddingModelConfig?['embeddingModelPath'],
            equals('/path/to/embedding.bin'),
          );
          expect(
            mockPlatform.lastEmbeddingModelConfig?['modelType'],
            equals('Gemma'),
          );
        });
      });

      group('when called with all parameters', () {
        test('then all parameters are passed', () async {
          // When
          await aiEdgeRag.createEmbeddingModel(
            tokenizerModelPath: '/path/to/tokenizer.model',
            embeddingModelPath: '/path/to/embedding.bin',
            modelType: EmbeddingModelType.gecko,
            vectorStore: VectorStore.sqlite,
            preferredBackend: PreferredBackend.gpu,
          );

          // Then
          expect(
            mockPlatform.lastEmbeddingModelConfig?['modelType'],
            equals('Gecko'),
          );
          expect(
            mockPlatform.lastEmbeddingModelConfig?['vectorStore'],
            equals('SQLite'),
          );
          expect(
            mockPlatform.lastEmbeddingModelConfig?['preferredBackend'],
            equals(PreferredBackend.gpu.value),
          );
        });
      });
    });

    group('createGeminiEmbedder', () {
      group('when called with required parameters', () {
        test('then platform createGeminiEmbedder is invoked', () async {
          // When
          await aiEdgeRag.createGeminiEmbedder(
            geminiEmbeddingModel: 'models/text-embedding-004',
            geminiApiKey: 'test-api-key',
          );

          // Then
          expect(mockPlatform.methodCalls, contains('createGeminiEmbedder'));
          expect(
            mockPlatform.lastGeminiEmbedderConfig?['geminiEmbeddingModel'],
            equals('models/text-embedding-004'),
          );
          expect(
            mockPlatform.lastGeminiEmbedderConfig?['geminiApiKey'],
            equals('test-api-key'),
          );
        });
      });

      group('when called with vector store', () {
        test('then vector store parameter is passed', () async {
          // When
          await aiEdgeRag.createGeminiEmbedder(
            geminiEmbeddingModel: 'models/text-embedding-004',
            geminiApiKey: 'test-api-key',
            vectorStore: VectorStore.sqlite,
          );

          // Then
          expect(
            mockPlatform.lastGeminiEmbedderConfig?['vectorStore'],
            equals('SQLite'),
          );
        });
      });
    });

    group('memorizeChunk', () {
      group('when called with a text chunk', () {
        test('then platform memorizeChunk is invoked', () async {
          // Given
          const chunk = 'Flutter is an open-source UI framework';

          // When
          await aiEdgeRag.memorizeChunk(chunk);

          // Then
          expect(mockPlatform.methodCalls, contains('memorizeChunk'));
          expect(
            mockPlatform.lastMemorizeChunkArguments?['chunk'],
            equals(chunk),
          );
        });
      });
    });

    group('memorizeChunks', () {
      group('when called with multiple chunks', () {
        test('then platform memorizeChunks is invoked', () async {
          // Given
          const chunks = [
            'Flutter is an open-source UI framework',
            'Dart is the programming language',
            'Flutter supports cross-platform development',
          ];

          // When
          await aiEdgeRag.memorizeChunks(chunks);

          // Then
          expect(mockPlatform.methodCalls, contains('memorizeChunks'));
          expect(
            mockPlatform.lastMemorizeChunksArguments?['chunks'],
            equals(chunks),
          );
        });
      });
    });

    group('memorizeChunkedText', () {
      group('when called with text and default parameters', () {
        test('then platform memorizeChunkedText is invoked', () async {
          // Given
          const text = 'This is a long text that needs to be chunked';

          // When
          await aiEdgeRag.memorizeChunkedText(text);

          // Then
          expect(mockPlatform.methodCalls, contains('memorizeChunkedText'));
          expect(
            mockPlatform.lastMemorizeChunkedTextArguments?['text'],
            equals(text),
          );
          expect(
            mockPlatform.lastMemorizeChunkedTextArguments?['chunkSize'],
            equals(512),
          );
        });
      });

      group('when called with custom chunk size and overlap', () {
        test('then custom parameters are passed', () async {
          // Given
          const text = 'This is a long text that needs to be chunked';

          // When
          await aiEdgeRag.memorizeChunkedText(
            text,
            chunkSize: 256,
            chunkOverlap: 50,
          );

          // Then
          expect(
            mockPlatform.lastMemorizeChunkedTextArguments?['chunkSize'],
            equals(256),
          );
          expect(
            mockPlatform.lastMemorizeChunkedTextArguments?['chunkOverlap'],
            equals(50),
          );
        });
      });
    });

    group('setSystemInstruction', () {
      group('when called with system instruction', () {
        test('then platform setSystemInstruction is invoked', () async {
          // Given
          const instruction = SystemInstruction(
            instruction: 'Use the provided context to answer questions',
          );

          // When
          await aiEdgeRag.setSystemInstruction(instruction);

          // Then
          expect(mockPlatform.methodCalls, contains('setSystemInstruction'));
          expect(
            mockPlatform.lastSystemInstructionArguments?['systemInstruction'],
            equals('Use the provided context to answer questions'),
          );
        });
      });
    });

    group('generateResponseAsync', () {
      group('when called with prompt and default parameters', () {
        test('then platform generateResponseAsync is invoked', () async {
          // Given
          const prompt = 'What is Flutter?';

          // When
          final stream = aiEdgeRag.generateResponseAsync(prompt);
          await stream.first;

          // Then
          expect(
            mockPlatform.methodCalls,
            contains('generateResponseAsync'),
          );
          expect(
            mockPlatform.lastGenerateResponseAsyncArguments?['prompt'],
            equals(prompt),
          );
          expect(
            mockPlatform.lastGenerateResponseAsyncArguments?['topK'],
            equals(3),
          );
          expect(
            mockPlatform.lastGenerateResponseAsyncArguments?['minSimilarityScore'],
            equals(0),
          );
        });
      });

      group('when called with custom topK and minSimilarityScore', () {
        test('then custom parameters are passed', () async {
          // Given
          const prompt = 'What is Flutter?';

          // When
          final stream = aiEdgeRag.generateResponseAsync(
            prompt,
            topK: 5,
            minSimilarityScore: 0.3,
          );
          await stream.first;

          // Then
          expect(
            mockPlatform.lastGenerateResponseAsyncArguments?['topK'],
            equals(5),
          );
          expect(
            mockPlatform.lastGenerateResponseAsyncArguments?['minSimilarityScore'],
            equals(0.3),
          );
        });
      });

      group('when stream is listened', () {
        test('then events are received', () async {
          // Given
          const prompt = 'What is Flutter?';

          // When
          final stream = aiEdgeRag.generateResponseAsync(prompt);
          final events = await stream.toList();

          // Then
          expect(events, isNotEmpty);
          expect(events.first.partialResult, equals('Test response'));
          expect(events.first.done, isTrue);
        });
      });
    });

    group('close', () {
      group('when called normally', () {
        test('then platform close is invoked', () async {
          // When
          await aiEdgeRag.close();

          // Then
          expect(mockPlatform.methodCalls, contains('close'));
        });
      });

      group('when platform throws PlatformException', () {
        test('then exception is silently ignored', () async {
          // Given
          mockPlatform.shouldThrowOnClose = true;

          // When & Then - should not throw
          await expectLater(aiEdgeRag.close(), completes);

          // Verify close was still called
          expect(mockPlatform.methodCalls, contains('close'));
        });

        tearDown(() {
          // Reset flag for other tests
          mockPlatform.shouldThrowOnClose = false;
        });
      });
    });
  });

  group('Types', () {
    group('SystemInstruction', () {
      test('can be created with instruction', () {
        const instruction = SystemInstruction(instruction: 'Test instruction');
        expect(instruction.instruction, equals('Test instruction'));
      });
    });

    group('VectorStore', () {
      test('has correct values', () {
        expect(VectorStore.inMemory.value, equals('Default'));
        expect(VectorStore.sqlite.value, equals('SQLite'));
      });
    });

    group('EmbeddingModelType', () {
      test('has correct values', () {
        expect(EmbeddingModelType.gemma.value, equals('Gemma'));
        expect(EmbeddingModelType.gecko.value, equals('Gecko'));
      });
    });

    group('EmbeddingModelConfig', () {
      test('toMap returns correct structure', () {
        final config = EmbeddingModelConfig(
          tokenizerModelPath: '/path/to/tokenizer',
          embeddingModelPath: '/path/to/embedding',
          modelType: EmbeddingModelType.gemma,
          vectorStore: VectorStore.sqlite,
          preferredBackend: PreferredBackend.gpu,
        );

        final map = config.toMap();
        expect(map['tokenizerModelPath'], equals('/path/to/tokenizer'));
        expect(map['embeddingModelPath'], equals('/path/to/embedding'));
        expect(map['modelType'], equals('Gemma'));
        expect(map['vectorStore'], equals('SQLite'));
        expect(map['preferredBackend'], equals(PreferredBackend.gpu.value));
      });

      test('toMap handles null optional values', () {
        final config = EmbeddingModelConfig(
          tokenizerModelPath: '/path/to/tokenizer',
          embeddingModelPath: '/path/to/embedding',
          modelType: EmbeddingModelType.gemma,
        );

        final map = config.toMap();
        expect(map.containsKey('vectorStore'), isFalse);
        expect(map.containsKey('preferredBackend'), isFalse);
      });
    });

    group('GeminiEmbedderConfig', () {
      test('toMap returns correct structure', () {
        final config = GeminiEmbedderConfig(
          geminiEmbeddingModel: 'models/text-embedding-004',
          geminiApiKey: 'test-key',
          vectorStore: VectorStore.sqlite,
        );

        final map = config.toMap();
        expect(
          map['geminiEmbeddingModel'],
          equals('models/text-embedding-004'),
        );
        expect(map['geminiApiKey'], equals('test-key'));
        expect(map['vectorStore'], equals('SQLite'));
      });

      test('toMap handles null vector store', () {
        final config = GeminiEmbedderConfig(
          geminiEmbeddingModel: 'models/text-embedding-004',
          geminiApiKey: 'test-key',
        );

        final map = config.toMap();
        expect(map.containsKey('vectorStore'), isFalse);
      });
    });
  });
}
