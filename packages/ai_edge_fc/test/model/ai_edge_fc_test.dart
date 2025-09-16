import 'package:ai_edge_fc/src/model/struct.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:ai_edge_fc/src/ai_edge_fc.dart';
import 'package:ai_edge_fc/src/ai_edge_fc_platform_interface.dart';
import 'package:ai_edge_fc/src/ai_edge_fc_method_channel.dart';
import 'package:ai_edge_fc/src/model/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiEdgeFcPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements AiEdgeFcPlatform {
  final List<String> methodCalls = [];
  Map<String, dynamic>? lastModelConfig;
  Map<String, dynamic>? lastSessionConfig;
  Map<String, dynamic>? lastConstraintArguments;
  Map<String, dynamic>? lastToolsArguments;
  Map<String, dynamic>? lastSystemInstructionArguments;
  Map<String, dynamic>? lastSendMessageArguments;
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
  Future<void> cloneSession() async {
    methodCalls.add('cloneSession');
  }

  @override
  Future<void> enableConstraint(Map<String, dynamic> arguments) async {
    methodCalls.add('enableConstraint');
    lastConstraintArguments = arguments;
  }

  @override
  Future<void> disableConstraint() async {
    methodCalls.add('disableConstraint');
  }

  @override
  Future<void> setTools(Map<String, dynamic> arguments) async {
    methodCalls.add('setTools');
    lastToolsArguments = arguments;
  }

  @override
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) async {
    methodCalls.add('setSystemInstruction');
    lastSystemInstructionArguments = arguments;
  }

  @override
  Future<Uint8List> sendMessage(Map<String, dynamic> arguments) async {
    methodCalls.add('sendMessage');
    lastSendMessageArguments = arguments;
    // Return a minimal valid GenerateContentResponse protobuf
    // This is just a placeholder - in real tests you'd return actual protobuf data
    return Uint8List.fromList([
      10,
      2,
      18,
      0,
    ]); // Minimal protobuf with empty candidate
  }

  @override
  Future<Iterable<Uint8List>> getHistory() async {
    methodCalls.add('getHistory');
    return [
      Uint8List.fromList([10, 4, 117, 115, 101, 114]), // "user" role
      Uint8List.fromList([10, 5, 109, 111, 100, 101, 108]), // "model" role
    ];
  }

  @override
  Future<Uint8List?> getLast() async {
    methodCalls.add('getLast');
    return Uint8List.fromList([10, 5, 109, 111, 100, 101, 108]); // "model" role
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
  group('AiEdgeFc', () {
    late MockAiEdgeFcPlatform mockPlatform;
    late AiEdgeFc aiEdgeFc;

    setUp(() {
      mockPlatform = MockAiEdgeFcPlatform();
      AiEdgeFcPlatform.instance = mockPlatform;
      aiEdgeFc = AiEdgeFc.instance;
    });

    group('Platform setup', () {
      test('default instance is MethodChannelAiEdgeFc', () {
        // Reset to default
        AiEdgeFcPlatform.instance = MethodChannelAiEdgeFc();
        expect(
          AiEdgeFcPlatform.instance,
          isInstanceOf<MethodChannelAiEdgeFc>(),
        );
        // Restore mock for other tests
        AiEdgeFcPlatform.instance = mockPlatform;
      });
    });

    group('createModel', () {
      group('when called with model parameters', () {
        test('then platform createModel is invoked', () async {
          // When
          await aiEdgeFc.createModel(
            modelPath: '/path/to/model',
            maxTokens: 256,
          );

          // Then
          expect(mockPlatform.methodCalls, contains('createModel'));
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model'),
          );
          expect(mockPlatform.lastModelConfig?['maxTokens'], equals(256));
        });
      });

      group('when called with all optional parameters', () {
        test('then all parameters are passed', () async {
          // When
          await aiEdgeFc.createModel(
            modelPath: '/path/to/model',
            maxTokens: 512,
            supportedLoraRanks: [4, 8],
            preferredBackend: PreferredBackend.gpu,
            maxNumImages: 3,
          );

          // Then
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model'),
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
          await aiEdgeFc.createSession(
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
          await aiEdgeFc.createSession();

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
          await aiEdgeFc.initialize(
            modelPath: '/path/to/model',
            maxTokens: 256,
          );

          // Then
          expect(
            mockPlatform.methodCalls,
            equals(['createModel', 'createSession']),
          );
          expect(
            mockPlatform.lastModelConfig?['modelPath'],
            equals('/path/to/model'),
          );
          expect(mockPlatform.lastModelConfig?['maxTokens'], equals(256));
          expect(mockPlatform.lastSessionConfig, isNotNull);
        });
      });

      group('when called with model params and custom session params', () {
        test('then custom params are used', () async {
          // When
          await aiEdgeFc.initialize(
            modelPath: '/path/to/model',
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

    group('cloneSession', () {
      group('when called', () {
        test('then platform cloneSession is invoked', () async {
          // When
          await aiEdgeFc.cloneSession();

          // Then
          expect(mockPlatform.methodCalls, contains('cloneSession'));
        });
      });
    });

    group('enableConstraint', () {
      group('when called with constraints', () {
        test('then platform enableConstraint is invoked', () async {
          // Given
          final constraints = ConstraintOptions(
            toolCallOnly: ToolCallOnly(
              constraintPrefix: 'prefix',
              constraintSuffix: 'suffix',
            ),
          );

          // When
          await aiEdgeFc.enableConstraint(constraints);

          // Then
          expect(mockPlatform.methodCalls, contains('enableConstraint'));
          expect(
            mockPlatform.lastConstraintArguments?['constraints'],
            isA<Uint8List>(),
          );
        });
      });
    });

    group('disableConstraint', () {
      group('when called', () {
        test('then platform disableConstraint is invoked', () async {
          // When
          await aiEdgeFc.disableConstraint();

          // Then
          expect(mockPlatform.methodCalls, contains('disableConstraint'));
        });
      });
    });

    group('setFunctions', () {
      group('when called with function declarations', () {
        test('then setTools is invoked with wrapped functions', () async {
          // Given
          final functions = [
            const FunctionDeclaration(
              name: 'test_function',
              description: 'Test function',
              properties: [],
            ),
          ];

          // When
          await aiEdgeFc.setFunctions(functions);

          // Then
          expect(mockPlatform.methodCalls, contains('setTools'));
          expect(mockPlatform.lastToolsArguments?['tools'], isA<List>());
          final tools = mockPlatform.lastToolsArguments?['tools'] as List;
          expect(tools.length, equals(1));
          expect(tools.first, isA<Uint8List>());
        });
      });
    });

    group('setTools', () {
      group('when called with tools', () {
        test('then platform setTools is invoked', () async {
          // Given
          final tools = [
            const Tool(
              functionDeclarations: [
                FunctionDeclaration(
                  name: 'test_function',
                  description: 'Test function',
                  properties: [],
                ),
              ],
            ),
          ];

          // When
          await aiEdgeFc.setTools(tools);

          // Then
          expect(mockPlatform.methodCalls, contains('setTools'));
          expect(mockPlatform.lastToolsArguments?['tools'], isA<List>());
        });
      });
    });

    group('setSystemInstruction', () {
      group('when called with system instruction', () {
        test('then platform setSystemInstruction is invoked', () async {
          // Given
          const instruction = SystemInstruction(instruction: 'Be helpful');

          // When
          await aiEdgeFc.setSystemInstruction(instruction);

          // Then
          expect(mockPlatform.methodCalls, contains('setSystemInstruction'));
          expect(
            mockPlatform.lastSystemInstructionArguments?['systemInstruction'],
            isA<Uint8List>(),
          );
        });
      });
    });

    group('sendMessage', () {
      group('when called with message', () {
        test('then platform sendMessage is invoked', () async {
          // Given
          final message = Message(role: 'user', text: 'Hello');

          // When
          try {
            await aiEdgeFc.sendMessage(message);
          } catch (e) {
            // Expected to fail parsing the mock response
            // We're just testing that the platform method is called
          }

          // Then
          expect(mockPlatform.methodCalls, contains('sendMessage'));
          expect(
            mockPlatform.lastSendMessageArguments?['message'],
            isA<Uint8List>(),
          );
        });
      });
    });

    group('sendFunctionResponse', () {
      group('when called with function response', () {
        test('then platform sendMessage is invoked', () async {
          // Given
          final functionCall = const FunctionCall(
            name: 'test_function',
            args: Struct(fields: {}),
          );
          final response = FunctionResponse(
            functionCall: functionCall,
            response: {'result': 'success'},
          );

          // When
          try {
            await aiEdgeFc.sendFunctionResponse(response);
          } catch (e) {
            // Expected to fail parsing the mock response
            // We're just testing that the platform method is called
          }

          // Then
          expect(mockPlatform.methodCalls, contains('sendMessage'));
          expect(
            mockPlatform.lastSendMessageArguments?['message'],
            isA<Uint8List>(),
          );
        });
      });
    });

    group('getHistory', () {
      group('when called', () {
        test('then platform getHistory is invoked', () async {
          // When
          try {
            await aiEdgeFc.getHistory();
          } catch (e) {
            // Expected to fail parsing the mock response
            // We're just testing that the platform method is called
          }

          // Then
          expect(mockPlatform.methodCalls, contains('getHistory'));
        });
      });
    });

    group('getLast', () {
      group('when called', () {
        test('then platform getLast is invoked', () async {
          // When
          try {
            await aiEdgeFc.getLast();
          } catch (e) {
            // Expected to fail parsing the mock response
            // We're just testing that the platform method is called
          }

          // Then
          expect(mockPlatform.methodCalls, contains('getLast'));
        });
      });
    });

    group('close', () {
      group('when called normally', () {
        test('then platform close is invoked', () async {
          // When
          await aiEdgeFc.close();

          // Then
          expect(mockPlatform.methodCalls, contains('close'));
        });
      });

      group('when platform throws PlatformException', () {
        test('then exception is silently ignored', () async {
          // Given
          mockPlatform.shouldThrowOnClose = true;

          // When & Then - should not throw
          await expectLater(aiEdgeFc.close(), completes);

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
}
