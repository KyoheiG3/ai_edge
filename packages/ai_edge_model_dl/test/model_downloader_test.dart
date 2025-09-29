import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Create a test setup for downloadModel tests
({ModelDownloader downloader, FakeFileDownloader fakeDownloader, FakeIO fakeIO})
_createDownloadTestSetup({
  ModelDownloaderConfig? config,
  String? baseDirectory,
}) {
  final fakeDownloader = FakeFileDownloader();
  final fakeIO = FakeIO();
  if (baseDirectory != null) {
    fakeIO.baseDirectory = baseDirectory;
  }
  fakeIO.modelSubdirectory = 'models';

  final modelDownloader = ModelDownloader.withDownloader(
    downloader: fakeDownloader,
    config:
        config ??
        const ModelDownloaderConfig(
          modelSubdirectory: 'models',
          validationFailureAction: ValidationFailureAction.deleteAndError,
        ),
    io: fakeIO,
  );

  return (
    downloader: modelDownloader,
    fakeDownloader: fakeDownloader,
    fakeIO: fakeIO,
  );
}

/// Helper function to setup a fake download result
DownloadResult _createDownloadResult({
  String filePath = '/test/model.bin',
  int fileSize = 1024,
  String? checksum,
  ChecksumType checksumType = ChecksumType.none,
}) {
  return (
    filePath: filePath,
    fileSize: fileSize,
    checksum: checksum,
    checksumType: checksumType,
  );
}

void main() {
  group('ModelDownloader', () {
    group('constructor', () {
      test('default constructor should initialize with default config', () {
        // When
        final downloader = ModelDownloader();

        // Then
        expect(downloader.config.modelSubdirectory, 'models');
        expect(downloader.config.checksumType, ChecksumType.none);
        expect(
          downloader.config.validationFailureAction,
          ValidationFailureAction.deleteAndError,
        );
        expect(
          downloader.config.conflictStrategy,
          FileConflictStrategy.overwrite,
        );
        expect(downloader.config.baseDirectory, isNull);
      });

      test('default constructor should accept custom config', () {
        // Given
        const customConfig = ModelDownloaderConfig(
          modelSubdirectory: 'custom_models',
          checksumType: ChecksumType.sha256,
          validationFailureAction: ValidationFailureAction.keepAndError,
          conflictStrategy: FileConflictStrategy.overwrite,
          baseDirectory: '/custom/path',
        );

        // When
        final downloader = ModelDownloader(config: customConfig);

        // Then
        expect(downloader.config.modelSubdirectory, 'custom_models');
        expect(downloader.config.checksumType, ChecksumType.sha256);
        expect(
          downloader.config.validationFailureAction,
          ValidationFailureAction.keepAndError,
        );
        expect(
          downloader.config.conflictStrategy,
          FileConflictStrategy.overwrite,
        );
        expect(downloader.config.baseDirectory, '/custom/path');
      });
    });

    group('downloadModel', () {
      group('validation failure action', () {
        test(
          'should delete file when validation fails with deleteAndError',
          () async {
            // Given
            final setup = _createDownloadTestSetup(
              config: const ModelDownloaderConfig(
                validationFailureAction: ValidationFailureAction.deleteAndError,
              ),
            );
            final testUrl = Uri.parse('https://example.com/model.bin');
            final expectedChecksum = 'a'.padRight(64, 'a');
            final actualChecksum = 'b'.padRight(64, 'b');
            final filePath = '/test/model.bin';

            setup.fakeDownloader.downloadResult = _createDownloadResult(
              filePath: filePath,
              fileSize: 1024,
              checksum: actualChecksum,
              checksumType: ChecksumType.sha256,
            );

            // Simulate file exists
            setup.fakeIO.simulateFileExists(filePath);

            // When & Then
            await expectLater(
              setup.downloader.downloadModel(
                testUrl,
                expectedChecksum: expectedChecksum,
              ),
              throwsA(
                isA<ModelDownloaderException>()
                    .having(
                      (e) => e.code,
                      'code',
                      ModelDownloaderErrorCode.checksumMismatch,
                    )
                    .having(
                      (e) => e.message,
                      'message',
                      contains('Checksum mismatch'),
                    ),
              ),
            );

            // Verify file was deleted
            expect(setup.fakeIO.files[filePath]?.existsValue, false);
          },
        );

        test(
          'should keep file when validation fails with keepAndError',
          () async {
            // Given
            final setup = _createDownloadTestSetup(
              config: const ModelDownloaderConfig(
                validationFailureAction: ValidationFailureAction.keepAndError,
              ),
            );
            final testUrl = Uri.parse('https://example.com/model.bin');
            final expectedChecksum = 'a'.padRight(64, 'a');
            final actualChecksum = 'b'.padRight(64, 'b');
            final filePath = '/test/model.bin';

            setup.fakeDownloader.downloadResult = _createDownloadResult(
              filePath: filePath,
              fileSize: 1024,
              checksum: actualChecksum,
              checksumType: ChecksumType.sha256,
            );

            // Simulate file exists
            setup.fakeIO.simulateFileExists(filePath);

            // When & Then
            await expectLater(
              setup.downloader.downloadModel(
                testUrl,
                expectedChecksum: expectedChecksum,
              ),
              throwsA(
                isA<ModelDownloaderException>()
                    .having(
                      (e) => e.code,
                      'code',
                      ModelDownloaderErrorCode.checksumMismatch,
                    )
                    .having(
                      (e) => e.message,
                      'message',
                      contains('Checksum mismatch'),
                    ),
              ),
            );

            // Verify file was NOT deleted
            expect(setup.fakeIO.files[filePath]?.existsValue, true);
          },
        );
      });

      group('when expectedChecksum is provided', () {
        group('and checksum matches', () {
          test('should complete successfully', () async {
            // Given
            final setup = _createDownloadTestSetup();
            final testUrl = Uri.parse('https://example.com/model.bin');
            final expectedChecksum = 'a'.padRight(64, 'a'); // SHA256 length

            setup.fakeDownloader.downloadResult = _createDownloadResult(
              filePath: '/test/model.bin',
              fileSize: 1024,
              checksum: expectedChecksum,
              checksumType: ChecksumType.sha256,
            );

            // When
            final result = await setup.downloader.downloadModel(
              testUrl,
              expectedChecksum: expectedChecksum,
            );

            // Then
            expect(result.checksum, expectedChecksum);
            expect(result.checksumType, ChecksumType.sha256);
          });
        });

        group('and checksum does not match', () {
          test(
            'should throw exception with checksum mismatch message',
            () async {
              // Given
              final setup = _createDownloadTestSetup();
              final testUrl = Uri.parse('https://example.com/model.bin');
              final expectedChecksum = 'a'.padRight(64, 'a');
              final actualChecksum = 'b'.padRight(64, 'b');

              setup.fakeDownloader.downloadResult = _createDownloadResult(
                filePath: '/test/model.bin',
                fileSize: 1024,
                checksum: actualChecksum,
                checksumType: ChecksumType.sha256,
              );

              // When & Then
              await expectLater(
                setup.downloader.downloadModel(
                  testUrl,
                  expectedChecksum: expectedChecksum,
                ),
                throwsA(
                  isA<ModelDownloaderException>().having(
                    (e) => e.code,
                    'code',
                    ModelDownloaderErrorCode.checksumMismatch,
                  ),
                ),
              );
            },
          );
        });

        group('and checksum length is invalid', () {
          test(
            'should throw exception with invalid checksum length message',
            () async {
              // Given
              final setup = _createDownloadTestSetup();
              final testUrl = Uri.parse('https://example.com/model.bin');
              final invalidChecksum = 'abc123'; // Invalid length

              // When & Then
              await expectLater(
                setup.downloader.downloadModel(
                  testUrl,
                  expectedChecksum: invalidChecksum,
                ),
                throwsA(
                  isA<ModelDownloaderException>().having(
                    (e) => e.code,
                    'code',
                    ModelDownloaderErrorCode.invalidChecksumFormat,
                  ),
                ),
              );
            },
          );
        });

        group('and checksum is MD5 format', () {
          test(
            'should identify MD5 from length and use correct type',
            () async {
              // Given
              final setup = _createDownloadTestSetup();
              final testUrl = Uri.parse('https://example.com/model.bin');
              final md5Checksum = 'a'.padRight(32, 'a'); // MD5 length

              setup.fakeDownloader.downloadResult = _createDownloadResult(
                filePath: '/test/model.bin',
                fileSize: 1024,
                checksum: md5Checksum,
                checksumType: ChecksumType.md5,
              );

              // When
              final result = await setup.downloader.downloadModel(
                testUrl,
                expectedChecksum: md5Checksum,
              );

              // Then
              expect(result.checksumType, ChecksumType.md5);
            },
          );
        });
      });

      group('when expectedFileSize is provided', () {
        group('and file size matches', () {
          test('should complete successfully', () async {
            // Given
            final setup = _createDownloadTestSetup();
            final testUrl = Uri.parse('https://example.com/model.bin');
            const expectedFileSize = 1024;

            setup.fakeDownloader.downloadResult = _createDownloadResult(
              filePath: '/test/model.bin',
              fileSize: expectedFileSize,
              checksum: null,
              checksumType: ChecksumType.none,
            );

            // When
            final result = await setup.downloader.downloadModel(
              testUrl,
              expectedFileSize: expectedFileSize,
            );

            // Then
            expect(result.fileSize, expectedFileSize);
          });
        });

        group('and file size does not match', () {
          test(
            'should throw exception with file size mismatch message',
            () async {
              // Given
              final setup = _createDownloadTestSetup();
              final testUrl = Uri.parse('https://example.com/model.bin');
              const expectedFileSize = 1024;
              const actualFileSize = 2048;

              setup.fakeDownloader.downloadResult = _createDownloadResult(
                filePath: '/test/model.bin',
                fileSize: actualFileSize,
                checksum: null,
                checksumType: ChecksumType.none,
              );

              // When & Then
              await expectLater(
                setup.downloader.downloadModel(
                  testUrl,
                  expectedFileSize: expectedFileSize,
                ),
                throwsA(
                  isA<ModelDownloaderException>().having(
                    (e) => e.code,
                    'code',
                    ModelDownloaderErrorCode.fileSizeMismatch,
                  ),
                ),
              );
            },
          );
        });
      });

      group('when progress callback is provided', () {
        test('should report progress updates during download', () async {
          // Given
          final setup = _createDownloadTestSetup();
          final testUrl = Uri.parse('https://example.com/model.bin');
          final progressUpdates = <ModelDownloadProgress>[];

          setup.fakeDownloader.downloadResult = _createDownloadResult(
            filePath: '/test/model.bin',
            fileSize: 100,
            checksum: null,
            checksumType: ChecksumType.none,
          );

          // When
          await setup.downloader.downloadModel(
            testUrl,
            onProgress: (progress) => progressUpdates.add(progress),
          );

          // Then
          expect(progressUpdates.length, 3);
          expect(progressUpdates[0].progress, 0.0);
          expect(progressUpdates[1].progress, 0.5);
          expect(progressUpdates[2].progress, 1.0);
        });
      });

      group('when no validation is required', () {
        test('should return download result', () async {
          // Given
          final setup = _createDownloadTestSetup();
          final testUrl = Uri.parse('https://example.com/model.bin');
          const expectedResult = (
            filePath: '/test/model.bin',
            fileSize: 1024,
            checksum: null,
            checksumType: ChecksumType.none,
          );

          setup.fakeDownloader.downloadResult = expectedResult;

          // When
          final result = await setup.downloader.downloadModel(testUrl);

          // Then
          expect(result.filePath, expectedResult.filePath);
          expect(result.fileSize, expectedResult.fileSize);
          expect(result.checksum, expectedResult.checksum);
          expect(result.checksumType, expectedResult.checksumType);
        });
      });
    });

    group('cancelDownload', () {
      test('should call cancelAndClear on the client', () {
        // Given
        final fakeDownloader = FakeFileDownloader();
        final fakeIO = FakeIO();
        final modelDownloader = ModelDownloader.withDownloader(
          downloader: fakeDownloader,
          io: fakeIO,
        );
        final fakeClient = fakeDownloader.client as FakeRangeRequestClient;

        // When
        modelDownloader.cancelDownload();

        // Then
        expect(fakeClient.cancelAndClearCalled, true);
      });
    });

    group('isModelDownloaded', () {
      test('should return true when file exists', () async {
        // Given
        final setup = _createDownloadTestSetup();
        final fakeIO = setup.fakeIO;
        fakeIO.simulateFileExists('/test/models/model.tflite');

        // When
        final exists = await setup.downloader.isModelDownloaded('model.tflite');

        // Then
        expect(exists, true);
      });

      test('should return false when file does not exist', () async {
        // Given
        final setup = _createDownloadTestSetup();

        // When
        final exists = await setup.downloader.isModelDownloaded('model.tflite');

        // Then
        expect(exists, false);
      });
    });

    group('deleteModel', () {
      test('should delete existing file', () async {
        // Given
        final setup = _createDownloadTestSetup();
        final fakeIO = setup.fakeIO;
        fakeIO.simulateFileExists('/test/models/model.tflite');

        // When
        await setup.downloader.deleteModel('model.tflite');

        // Then
        final file = fakeIO.files['/test/models/model.tflite'];
        expect(file?.existsValue, false);
      });

      test('should handle deletion of non-existent file gracefully', () async {
        // Given
        final setup = _createDownloadTestSetup();

        // When & Then (should not throw)
        await expectLater(
          setup.downloader.deleteModel('nonexistent.tflite'),
          completes,
        );
      });
    });

    group('getDownloadedModels', () {
      test('should return list of downloaded models', () async {
        // Given
        final setup = _createDownloadTestSetup();
        final fakeIO = setup.fakeIO;

        // Create directory and files
        fakeIO.simulateDirectoryExists('/test/models');
        fakeIO.simulateFileExists('/test/models/model1.tflite');
        fakeIO.simulateFileExists('/test/models/model2.bin');
        fakeIO.simulateFileExists('/test/models/model3.onnx');

        // When
        final models = await setup.downloader.getDownloadedModels();

        // Then
        expect(
          models,
          containsAll(['model1.tflite', 'model2.bin', 'model3.onnx']),
        );
        expect(models.length, 3);
      });

      test('should return empty list when directory does not exist', () async {
        // Given
        final setup = _createDownloadTestSetup();
        // The directory is not created, so exists() returns false
        // This tests the `: []` branch at line 138

        // When
        final models = await setup.downloader.getDownloadedModels();

        // Then
        expect(models, isEmpty);

        // Verify that the directory's exists() method would return false
        final dirPath = '/test/models';
        final dir = setup.fakeIO.directories[dirPath];
        expect(dir?.existsValue ?? false, false);
      });

      test(
        'should return empty list when directory exists but has no files',
        () async {
          // Given
          final setup = _createDownloadTestSetup();
          final fakeIO = setup.fakeIO;
          fakeIO.simulateDirectoryExists('/test/models');

          // When
          final models = await setup.downloader.getDownloadedModels();

          // Then
          expect(models, isEmpty);
        },
      );

      test('should only return files and exclude subdirectories', () async {
        // Given
        final setup = _createDownloadTestSetup();
        final fakeIO = setup.fakeIO;

        // Create directory
        fakeIO.simulateDirectoryExists('/test/models');

        // Add files
        fakeIO.simulateFileExists('/test/models/model1.tflite');
        fakeIO.simulateFileExists('/test/models/model2.bin');

        // Add subdirectory (should be excluded)
        fakeIO.simulateDirectoryExists('/test/models/subfolder');

        // When
        final models = await setup.downloader.getDownloadedModels();

        // Then
        expect(models, containsAll(['model1.tflite', 'model2.bin']));
        expect(models.length, 2);
        expect(models, isNot(contains('subfolder')));
      });
    });

    group('getModelsDirectory', () {
      test('should use configured base directory when provided', () async {
        // Given
        final fakeIO = FakeIO();
        final modelDownloader = ModelDownloader.withDownloader(
          downloader: FakeFileDownloader(),
          config: const ModelDownloaderConfig(
            baseDirectory: '/custom/path',
            modelSubdirectory: 'models',
          ),
          io: fakeIO,
        );

        // When
        final directory = await modelDownloader.getModelsDirectory();

        // Then
        expect(directory, '/custom/path/models');
      });

      test(
        'should use IO base directory when config.baseDirectory is null',
        () async {
          // Given
          final fakeIO = FakeIO()..baseDirectory = '/io/base';
          final modelDownloader = ModelDownloader.withDownloader(
            downloader: FakeFileDownloader(),
            config: const ModelDownloaderConfig(modelSubdirectory: 'ai_models'),
            io: fakeIO,
          );

          // When
          final directory = await modelDownloader.getModelsDirectory();

          // Then
          expect(directory, '/io/base/ai_models');
        },
      );

      test('should create directory if it does not exist', () async {
        // Given
        final fakeIO = FakeIO();
        final modelDownloader = ModelDownloader.withDownloader(
          downloader: FakeFileDownloader(),
          config: const ModelDownloaderConfig(
            baseDirectory: '/test',
            modelSubdirectory: 'models',
          ),
          io: fakeIO,
        );

        // When
        await modelDownloader.getModelsDirectory();

        // Then
        final dir = fakeIO.directories['/test/models'];
        expect(dir?.existsValue, true);
      });
    });

    group('getModelPath', () {
      test('should combine models directory with file name', () async {
        // Given
        final fakeIO = FakeIO();
        final modelDownloader = ModelDownloader.withDownloader(
          downloader: FakeFileDownloader(),
          config: const ModelDownloaderConfig(
            baseDirectory: '/custom',
            modelSubdirectory: 'models',
          ),
          io: fakeIO,
        );

        // When
        final path = await modelDownloader.getModelPath('model.tflite');

        // Then
        expect(path, '/custom/models/model.tflite');
      });
    });
  });
}
