import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/download_progress.dart';
import '../models/gemma_model.dart';
import 'config_service.dart';

class ModelDownloadService {
  static const String _downloadProgressKey = 'download_progress_';

  final ConfigService _configService = ConfigService();

  Future<String> getModelsDirectory() async {
    Directory appDir;

    // Use platform-specific directory
    if (Platform.isAndroid) {
      // Try external storage on Android for better space availability
      final externalDir = await getExternalStorageDirectory();
      appDir = externalDir ?? await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      // Use Application Support directory on iOS to avoid iCloud backup
      // Models are downloaded content that can be re-downloaded if needed
      appDir = await getApplicationSupportDirectory();
    } else {
      // Use documents directory on other platforms
      appDir = await getApplicationDocumentsDirectory();
    }

    // Both platforms use the directory directly (no subdirectory)
    return appDir.path;
  }

  Future<String> getModelPath(GemmaModel model) async {
    final modelsDir = await getModelsDirectory();
    return '$modelsDir/${model.fileName}';
  }

  Future<bool> isModelDownloaded(GemmaModel model) async {
    final modelPath = await getModelPath(model);
    return File(modelPath).exists();
  }

  Stream<DownloadProgress> downloadModelWithProgress(GemmaModel model) async* {
    debugPrint(
      '[ModelDownloadService] Starting download for model: ${model.name}',
    );
    final modelPath = await getModelPath(model);
    debugPrint('[ModelDownloadService] Model will be saved to: $modelPath');
    final file = File(modelPath);

    // If file already exists, delete it first
    if (await file.exists()) {
      debugPrint('[ModelDownloadService] Existing file found, deleting...');
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final progressKey = '$_downloadProgressKey${model.id}';

    // Use RandomAccessFile for efficient streaming writes
    RandomAccessFile? raf;
    final client = http.Client();

    try {
      debugPrint(
        '[ModelDownloadService] Creating download request for: ${model.downloadUrl}',
      );
      final request = http.Request('GET', Uri.parse(model.downloadUrl));

      // Add authorization header if available
      final authHeaders = await _configService.getAuthorizationHeader();
      if (authHeaders != null) {
        debugPrint('[ModelDownloadService] Adding authorization headers');
        request.headers.addAll(authHeaders);
      }

      debugPrint('[ModelDownloadService] Sending request...');
      final response = await client.send(request);

      debugPrint(
        '[ModelDownloadService] Response status code: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download model: HTTP ${response.statusCode}',
        );
      }

      final contentLength = response.contentLength ?? 0;
      debugPrint(
        '[ModelDownloadService] Content length: $contentLength bytes (${(contentLength / 1024 / 1024 / 1024).toStringAsFixed(2)} GB)',
      );
      var downloadedBytes = 0;

      // Open file for writing
      debugPrint('[ModelDownloadService] Opening file for writing...');
      raf = await file.open(mode: FileMode.write);

      // Buffer for batching writes (8MB chunks for better performance)
      const bufferSize = 8 * 1024 * 1024; // 8MB
      final buffer = <int>[];

      // Track progress update frequency (update every 0.5% to reduce UI updates)
      var lastProgress = 0.0;
      const progressUpdateThreshold = 0.005; // 0.5%

      // Speed calculation
      final startTime = DateTime.now();
      var lastUpdateTime = startTime;
      var lastDownloadedBytes = 0;
      var currentSpeed = 0.0;

      await for (final chunk in response.stream) {
        buffer.addAll(chunk);
        downloadedBytes += chunk.length;

        // Write to file when buffer reaches threshold
        if (buffer.length >= bufferSize) {
          await raf.writeFrom(buffer);
          buffer.clear();
        }

        if (contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          final now = DateTime.now();
          final timeSinceLastUpdate = now
              .difference(lastUpdateTime)
              .inMilliseconds;

          // Update speed calculation every 500ms
          if (timeSinceLastUpdate >= 500) {
            final bytesSinceLastUpdate = downloadedBytes - lastDownloadedBytes;
            currentSpeed =
                bytesSinceLastUpdate / (timeSinceLastUpdate / 1000.0);
            lastUpdateTime = now;
            lastDownloadedBytes = downloadedBytes;
          }

          // Only yield progress if it has changed significantly
          if (progress - lastProgress >= progressUpdateThreshold ||
              progress >= 1.0) {
            final remainingBytes = contentLength - downloadedBytes;
            final estimatedSeconds = currentSpeed > 0
                ? (remainingBytes / currentSpeed).round()
                : 0;

            yield DownloadProgress(
              progress: progress,
              downloadedBytes: downloadedBytes,
              totalBytes: contentLength,
              bytesPerSecond: currentSpeed,
              estimatedTimeRemaining: Duration(seconds: estimatedSeconds),
            );

            lastProgress = progress;

            // Save progress less frequently (every 2%)
            if ((progress * 100).round() % 2 == 0) {
              await prefs.setDouble(progressKey, progress);
            }
          }
        }
      }

      // Write any remaining data in buffer
      if (buffer.isNotEmpty) {
        await raf.writeFrom(buffer);
        buffer.clear();
      }

      await raf.close();
      raf = null;

      debugPrint('[ModelDownloadService] Download completed successfully!');
      debugPrint('[ModelDownloadService] File saved at: $modelPath');
      debugPrint(
        '[ModelDownloadService] File size: ${downloadedBytes / 1024 / 1024 / 1024} GB',
      );

      await prefs.remove(progressKey);
      yield DownloadProgress(
        progress: 1.0,
        downloadedBytes: contentLength,
        totalBytes: contentLength,
        bytesPerSecond: 0,
        estimatedTimeRemaining: Duration.zero,
      );
    } catch (e, stackTrace) {
      debugPrint('[ModelDownloadService] Error during download: $e');
      debugPrint('[ModelDownloadService] Stack trace: $stackTrace');

      await prefs.remove(progressKey);

      // Clean up resources
      if (raf != null) {
        debugPrint('[ModelDownloadService] Closing file handle...');
        await raf.close();
      }

      if (await file.exists()) {
        debugPrint('[ModelDownloadService] Deleting incomplete file...');
        await file.delete();
      }

      // Check if it's a storage space error
      if (e.toString().contains('ENOSPC') ||
          e.toString().contains('No space left') ||
          e.toString().contains('insufficient storage')) {
        debugPrint('[ModelDownloadService] Storage space error detected');
        throw Exception(
          'Insufficient storage space. Please free up at least ${model.fileSizeGB} GB and try again.',
        );
      }

      debugPrint('[ModelDownloadService] Re-throwing error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> deleteModel(GemmaModel model) async {
    final modelPath = await getModelPath(model);
    final file = File(modelPath);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_downloadProgressKey${model.id}');
  }

  Future<double?> getSavedProgress(GemmaModel model) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_downloadProgressKey${model.id}');
  }

  // Backward compatibility method that returns simple progress
  Stream<double> downloadModel(GemmaModel model) async* {
    await for (final progress in downloadModelWithProgress(model)) {
      yield progress.progress;
    }
  }

  Future<List<String>> getDownloadedModels() async {
    final modelsDir = await getModelsDirectory();
    final dir = Directory(modelsDir);
    if (await dir.exists()) {
      final files = await dir.list().toList();
      return files
          .whereType<File>()
          .map((f) => f.path.split('/').last)
          .toList();
    }
    return [];
  }
}
