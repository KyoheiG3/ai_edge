import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_example/models/gemma_model.dart';
import 'package:ai_edge_example/services/model_download_service.dart';

class TestModelHelper {
  static final ModelDownloadService _downloadService = ModelDownloadService();

  static const String testModelId = 'gemma-3n-e2b';
  static late GemmaModel testModel;

  static void init() {
    testModel = GemmaModel.availableModels.firstWhere(
      (model) => model.id == testModelId,
    );
  }

  /// Ensures the test model is available for testing
  /// In CI, this expects the model to be pre-downloaded
  /// In local testing, it can download if needed
  static Future<String> ensureTestModel() async {
    init();

    // Check if running in CI
    final isCI = Platform.environment['CI'] == 'true';
    final testModelPath = Platform.environment['TEST_MODEL_PATH'];

    if (isCI && testModelPath != null) {
      // In CI, model should be pre-downloaded
      final modelFile = File(testModelPath);
      if (!await modelFile.exists()) {
        throw TestFailure(
          'Model file not found in CI environment: $testModelPath',
        );
      }

      // Copy to expected location if needed
      final expectedPath = await _downloadService.getModelPath(testModel);
      if (testModelPath != expectedPath) {
        final expectedFile = File(expectedPath);
        if (!await expectedFile.exists()) {
          await expectedFile.parent.create(recursive: true);
          await modelFile.copy(expectedPath);
        }
      }

      return expectedPath;
    }

    // Check if model is already downloaded
    final modelPath = await _downloadService.getModelPath(testModel);
    if (await _downloadService.isModelDownloaded(testModel)) {
      return modelPath;
    }

    // In local testing, offer to download
    if (!isCI) {
      debugPrint(
        'Test model not found. Downloading ${testModel.name} (${testModel.fileSizeGB}GB)...',
      );
      debugPrint('This will take several minutes on first run.');

      // Download the model
      await for (final progress in _downloadService.downloadModelWithProgress(
        testModel,
      )) {
        if (progress.progress % 0.1 < 0.01) {
          // Print every 10%
          debugPrint(
            'Download progress: ${(progress.progress * 100).toStringAsFixed(1)}%',
          );
        }
      }

      debugPrint('Model downloaded successfully');
      return modelPath;
    }

    throw TestFailure(
      'Test model not available. Please ensure the model is downloaded before running tests.',
    );
  }

  /// Cleanup after tests (optional)
  static Future<void> cleanup({bool deleteModel = false}) async {
    if (deleteModel) {
      // Only delete in non-CI environments
      final isCI = Platform.environment['CI'] == 'true';
      if (!isCI) {
        await _downloadService.deleteModel(testModel);
      }
    }
  }

  /// Get model directory for verification
  static Future<String> getModelDirectory() async {
    return _downloadService.getModelsDirectory();
  }

  /// Verify model file integrity
  static Future<bool> verifyModelIntegrity(String modelPath) async {
    final file = File(modelPath);
    if (!await file.exists()) {
      return false;
    }

    final fileSize = await file.length();
    final expectedSizeBytes = (testModel.fileSizeGB * 1024 * 1024 * 1024)
        .round();

    // Allow 5% variance in file size
    final sizeDifference = (fileSize - expectedSizeBytes).abs();
    final allowedVariance = expectedSizeBytes * 0.05;

    return sizeDifference <= allowedVariance;
  }

  /// Platform-specific model path helper
  static Future<String> getPlatformModelPath() async {
    if (Platform.isIOS) {
      final dir = await getApplicationSupportDirectory();
      return '${dir.path}/${testModel.fileName}';
    } else if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        return '${dir.path}/${testModel.fileName}';
      }
      final docDir = await getApplicationDocumentsDirectory();
      return '${docDir.path}/${testModel.fileName}';
    }
    throw UnsupportedError('Platform not supported');
  }
}
