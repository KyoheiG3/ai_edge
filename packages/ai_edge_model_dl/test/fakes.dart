import 'dart:io';

import 'package:ai_edge_model_dl/src/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:range_request/range_request.dart';

class FakeFileDownloader extends Fake implements FileDownloader {
  DownloadResult? downloadResult;
  Exception? downloadException;
  void Function(int bytes, int total, DownloadStatus status)?
  capturedOnProgress;
  final FakeRangeRequestClient _fakeClient = FakeRangeRequestClient();

  @override
  Future<DownloadResult> downloadToFile(
    Uri url,
    String outputDir, {
    String? outputFileName,
    bool resume = true,
    ChecksumType checksumType = ChecksumType.none,
    FileConflictStrategy conflictStrategy = FileConflictStrategy.rename,
    Duration progressInterval = const Duration(milliseconds: 500),
    CancelToken? cancelToken,
    void Function(int bytes, int total, DownloadStatus status)? onProgress,
  }) async {
    capturedOnProgress = onProgress;

    if (downloadException != null) {
      throw downloadException!;
    }

    if (downloadResult != null) {
      // Call onProgress if provided to simulate download progress
      if (onProgress != null) {
        // Simulate some progress updates
        onProgress(0, downloadResult!.fileSize, DownloadStatus.downloading);
        onProgress(
          downloadResult!.fileSize ~/ 2,
          downloadResult!.fileSize,
          DownloadStatus.downloading,
        );
        onProgress(
          downloadResult!.fileSize,
          downloadResult!.fileSize,
          DownloadStatus.downloading,
        );
      }
      return downloadResult!;
    }

    // Default return value
    return (
      filePath: '$outputDir/${outputFileName ?? 'file'}',
      fileSize: 0,
      checksum: null,
      checksumType: checksumType,
    );
  }

  @override
  RangeRequestClient get client => _fakeClient;
}

class FakeRangeRequestClient extends Fake implements RangeRequestClient {
  bool cancelAndClearCalled = false;

  @override
  void cancelAndClear() {
    cancelAndClearCalled = true;
  }
}

/// Fake IO implementation for testing
class FakeIO implements IO {
  final Map<String, FakeFile> files = {};
  final Map<String, FakeDirectory> directories = {};
  String baseDirectory = '/test';
  String modelSubdirectory = 'models';

  @override
  File createFile(String path) {
    return files.putIfAbsent(path, () => FakeFile(path, this));
  }

  @override
  Directory createDirectory(String path) {
    return directories.putIfAbsent(path, () => FakeDirectory(path, this));
  }

  @override
  Future<String> getBaseDirectory() async {
    return baseDirectory;
  }

  void simulateFileExists(String path) {
    files[path] = FakeFile(path, this)..existsValue = true;
  }

  void simulateDirectoryExists(String path) {
    directories[path] = FakeDirectory(path, this)..existsValue = true;
  }

  String getExpectedModelsPath() {
    return '$baseDirectory/$modelSubdirectory';
  }
}

/// Fake File implementation
class FakeFile extends Fake implements File {
  final String filePath;
  final FakeIO io;
  bool existsValue = false;

  FakeFile(this.filePath, this.io);

  @override
  String get path => filePath;

  @override
  Future<bool> exists() async => existsValue;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    existsValue = false;
    return this;
  }
}

/// Fake Directory implementation
class FakeDirectory extends Fake implements Directory {
  final String directoryPath;
  final FakeIO io;
  bool existsValue = false;

  FakeDirectory(this.directoryPath, this.io);

  @override
  String get path => directoryPath;

  @override
  Future<bool> exists() async => existsValue;

  @override
  Future<Directory> create({bool recursive = false}) async {
    existsValue = true;
    return this;
  }

  @override
  Stream<FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    // Return files and directories that exist in this directory
    final dirPath = directoryPath.endsWith('/')
        ? directoryPath
        : '$directoryPath/';

    // Get files
    final filesInDir = io.files.entries
        .where((e) => e.key.startsWith(dirPath) && e.value.existsValue)
        .map((e) => e.value as FileSystemEntity);

    // Get subdirectories
    final dirsInDir = io.directories.entries
        .where(
          (e) =>
              e.key != directoryPath && // Exclude self
              e.key.startsWith(dirPath) &&
              e.value.existsValue &&
              !e.key.substring(dirPath.length).contains('/'),
        ) // Only direct subdirs
        .map((e) => e.value as FileSystemEntity);

    return Stream.fromIterable([...filesInDir, ...dirsInDir]);
  }
}
