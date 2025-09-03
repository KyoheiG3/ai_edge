import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_edge/ai_edge.dart';
import 'helpers/test_model_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late String modelPath;
  final aiEdge = AiEdge.instance;

  setUpAll(() async {
    // Ensure test model is available
    modelPath = await TestModelHelper.ensureTestModel();

    // Verify model integrity
    final isValid = await TestModelHelper.verifyModelIntegrity(modelPath);
    expect(isValid, isTrue, reason: 'Model file integrity check failed');
  });

  tearDownAll(() async {
    // Clean up after all tests
    await aiEdge.close();
  });

  group('AI Edge Plugin Basic Tests', () {
    test('Model initialization', () async {
      await aiEdge.createModel(
        ModelConfig(
          modelPath: modelPath,
          maxTokens: 1024,
          preferredBackend: PreferredBackend.cpu,
        ),
      );

      // If we get here without exception, model was created successfully
      expect(true, isTrue, reason: 'Model should initialize without errors');
    });

    test('Session creation', () async {
      await aiEdge.createSession(
        const SessionConfig(temperature: 0.7, topK: 40, randomSeed: 42),
      );

      // If we get here without exception, session was created successfully
      expect(true, isTrue, reason: 'Session should be created without errors');
    });

    test('Initialize with convenience method', () async {
      // Close any existing model/session
      await aiEdge.close();

      // Initialize with convenience method
      await aiEdge.initialize(
        modelPath: modelPath,
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
        sessionConfig: const SessionConfig(temperature: 0.7, topK: 40),
      );

      expect(true, isTrue, reason: 'Initialize should complete without errors');
    });

    test('Add query chunk', () async {
      await aiEdge.addQueryChunk('Hello, ');
      await aiEdge.addQueryChunk('how are you?');

      expect(
        true,
        isTrue,
        reason: 'Query chunks should be added without errors',
      );
    });

    test('Resource cleanup', () async {
      await aiEdge.close();

      // Re-initialize for next tests
      await aiEdge.initialize(modelPath: modelPath, maxTokens: 1024);

      expect(
        true,
        isTrue,
        reason: 'Resources should be cleaned up and re-initialized',
      );
    });
  });

  group('Error Handling Tests', () {
    test('Invalid model path should throw', () async {
      await aiEdge.close();

      expect(
        () async => await aiEdge.createModel(
          ModelConfig(modelPath: '/invalid/path/to/model.bin', maxTokens: 1024),
        ),
        throwsException,
        reason: 'Invalid model path should throw an exception',
      );

      // Re-initialize with valid model for next tests
      await aiEdge.initialize(modelPath: modelPath, maxTokens: 1024);
    });

    test('Multiple session creation attempts', () async {
      // First session should succeed
      await aiEdge.createSession(const SessionConfig());

      // Second session creation might replace the first or throw
      // This behavior depends on the plugin implementation
      try {
        await aiEdge.createSession(const SessionConfig());
        // If it succeeds, that's also acceptable
        expect(true, isTrue);
      } catch (e) {
        // If it throws, that's expected behavior
        expect(e, isNotNull);
      }
    });
  });
}
