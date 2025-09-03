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

    // Debug: Print all environment variables
    debugPrint('=== Environment Variables ===');
    Platform.environment.forEach((key, value) {
      if (key.startsWith('TEST_') || key == 'CI' || key == 'HF_TOKEN') {
        debugPrint('$key: ${key == 'HF_TOKEN' ? '***' : value}');
      }
    });
    debugPrint('=== End Environment Variables ===');

    // Check if TEST_MODEL_PATH is set (from environment or dart-define)
    String? testModelPath = Platform.environment['TEST_MODEL_PATH'];
    
    // If not in environment, try from dart-define
    if ((testModelPath == null || testModelPath.isEmpty)) {
      const definedPath = String.fromEnvironment('TEST_MODEL_PATH');
      if (definedPath.isNotEmpty) {
        testModelPath = definedPath;
        debugPrint('TEST_MODEL_PATH from dart-define: $testModelPath');
      }
    }
    
    if (testModelPath != null && testModelPath.isNotEmpty) {
      debugPrint('Using TEST_MODEL_PATH: $testModelPath');
      
      // Verify the file exists
      final modelFile = File(testModelPath);
      if (await modelFile.exists()) {
        debugPrint('Model file found at TEST_MODEL_PATH: $testModelPath');
        
        // Copy to expected location if needed
        final expectedPath = await _downloadService.getModelPath(testModel);
        if (testModelPath != expectedPath) {
          final expectedFile = File(expectedPath);
          if (!await expectedFile.exists()) {
            debugPrint('Copying model to expected location: $expectedPath');
            await expectedFile.parent.create(recursive: true);
            await modelFile.copy(expectedPath);
          }
        }
        
        return expectedPath;
      } else {
        debugPrint('WARNING: TEST_MODEL_PATH set but file not found: $testModelPath');
      }
    }
    
    // Check if running in CI without TEST_MODEL_PATH
    final isCI = Platform.environment['CI'] == 'true' || 
                 const String.fromEnvironment('CI') == 'true';
    if (isCI) {
      throw TestFailure(
        'CI environment detected but TEST_MODEL_PATH not set or file not found',
      );
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
    // Check if TEST_MODEL_PATH environment variable is set (for CI)
    final testModelPath = Platform.environment['TEST_MODEL_PATH'];
    if (testModelPath != null && testModelPath.isNotEmpty) {
      debugPrint('Using TEST_MODEL_PATH from environment: $testModelPath');
      return testModelPath;
    }
    
    if (Platform.isIOS) {
      final dir = await getApplicationSupportDirectory();
      return '${dir.path}/${testModel.fileName}';
    } else if (Platform.isAndroid) {
      // Try multiple locations for Android
      // 1. Check Download folder (CI environment)
      final downloadPath = '/sdcard/Download/${testModel.fileName}';
      if (await File(downloadPath).exists()) {
        debugPrint('Found model in Download folder: $downloadPath');
        return downloadPath;
      }
      
      // 2. Check app-specific external storage
      final dir = await getExternalStorageDirectory();
      if (dir != null) {
        final appPath = '${dir.path}/${testModel.fileName}';
        if (await File(appPath).exists()) {
          debugPrint('Found model in app external storage: $appPath');
          return appPath;
        }
      }
      
      // 3. Fall back to documents directory
      final docDir = await getApplicationDocumentsDirectory();
      return '${docDir.path}/${testModel.fileName}';
    }
    throw UnsupportedError('Platform not supported');
  }
}
