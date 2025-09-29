import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:range_request/range_request.dart';

import 'exceptions.dart';
import 'io.dart';
import 'model_download_progress.dart';
import 'model_downloader_config.dart';

class ModelDownloader {
  final ModelDownloaderConfig config;
  final FileDownloader _downloader;
  final IO _io;

  ModelDownloader({this.config = const ModelDownloaderConfig()})
    : _downloader = FileDownloader.fromConfig(config.toRangeRequestConfig()),
      _io = const DefaultIO();

  /// Constructor for testing with custom FileDownloader
  @visibleForTesting
  ModelDownloader.withDownloader({
    required FileDownloader downloader,
    required IO io,
    this.config = const ModelDownloaderConfig(),
  }) : _downloader = downloader,
       _io = io;

  Future<String> getModelsDirectory() async {
    final dirPath = await _getModelsDirectoryPath();

    // Create directory if it doesn't exist
    final modelsDir = _io.createDirectory(dirPath);
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    return dirPath;
  }

  Future<String> getModelPath(String fileName) async {
    final modelsDir = await getModelsDirectory();
    return '$modelsDir/$fileName';
  }

  Future<bool> isModelDownloaded(String fileName) async {
    final modelPath = await getModelPath(fileName);
    return _io.createFile(modelPath).exists();
  }

  Future<DownloadResult> downloadModel(
    Uri url, {
    String? fileName,
    String? expectedChecksum,
    int? expectedFileSize,
    CancelToken? cancelToken,
    void Function(ModelDownloadProgress)? onProgress,
  }) async {
    final startTime = DateTime.now();
    int? sessionStartBytes;

    // Determine checksum type from expected checksum
    final checksumType = _determineChecksumType(expectedChecksum);

    // Use the downloadToFile method
    final result = await _downloader.downloadToFile(
      url,
      await getModelsDirectory(),
      outputFileName: fileName,
      checksumType: checksumType,
      conflictStrategy: config.conflictStrategy,
      cancelToken: cancelToken,
      onProgress: (bytes, total, status) {
        // Initialize sessionStartBytes on first callback
        // bytes already includes any previously downloaded data if resumed
        sessionStartBytes ??= bytes;

        onProgress?.call(
          ModelDownloadProgress.calculate(
            downloadedBytes: bytes,
            totalBytes: total,
            startTime: startTime,
            sessionStartBytes: sessionStartBytes ?? 0,
          ),
        );
      },
    );

    // Validate checksum if provided
    if (expectedChecksum != null && result.checksum != expectedChecksum) {
      await _handleChecksumValidationFailure(
        result.filePath,
        expected: expectedChecksum,
        actual: result.checksum,
      );
    }

    // Validate file size if provided
    if (expectedFileSize != null && result.fileSize != expectedFileSize) {
      await _handleFileSizeValidationFailure(
        result.filePath,
        expected: expectedFileSize,
        actual: result.fileSize,
      );
    }

    return result;
  }

  Future<void> deleteModel(String fileName) async {
    final modelPath = await getModelPath(fileName);
    final file = _io.createFile(modelPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<String>> getDownloadedModels() async {
    final modelsDir = await _getModelsDirectoryPath();
    final dir = _io.createDirectory(modelsDir);
    return await dir.exists()
        ? dir.list().toList().then(
            (files) => files
                .whereType<File>()
                .map((file) => file.path.split('/').last)
                .toList(),
          )
        : [];
  }

  Future<String> _getModelsDirectoryPath() async {
    // Determine the base directory
    final baseDir = config.baseDirectory ?? await _io.getBaseDirectory();

    // Always append the model subdirectory
    return '$baseDir/${config.modelSubdirectory}';
  }

  ChecksumType _determineChecksumType(String? expectedChecksum) {
    // If expectedChecksum is provided, infer type from length
    if (expectedChecksum != null) {
      return switch (expectedChecksum.length) {
        32 => ChecksumType.md5,
        64 => ChecksumType.sha256,
        _ => throw ModelDownloaderException.invalidChecksumFormat(
          length: expectedChecksum.length,
        ),
      };
    }

    // No checksum validation needed
    return config.checksumType;
  }

  /// Cancel any active downloads
  void cancelDownload() {
    _downloader.client.cancelAndClear();
  }

  Future<void> _handleValidationFailure(String filePath) async {
    if (config.validationFailureAction ==
        ValidationFailureAction.deleteAndError) {
      final file = _io.createFile(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _handleChecksumValidationFailure(
    String filePath, {
    required String expected,
    String? actual,
  }) async {
    await _handleValidationFailure(filePath);
    throw ModelDownloaderException.checksumMismatch(
      expected: expected,
      actual: actual,
    );
  }

  Future<void> _handleFileSizeValidationFailure(
    String filePath, {
    required int expected,
    required int actual,
  }) async {
    await _handleValidationFailure(filePath);
    throw ModelDownloaderException.fileSizeMismatch(
      expected: expected,
      actual: actual,
    );
  }
}
