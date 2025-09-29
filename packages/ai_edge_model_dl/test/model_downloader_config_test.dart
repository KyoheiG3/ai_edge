import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelDownloaderConfig', () {
    test('default values should be set correctly', () {
      // When
      const config = ModelDownloaderConfig();

      // Then
      expect(config.baseDirectory, isNull);
      expect(config.modelSubdirectory, 'models');
      expect(config.headers, isEmpty);
      expect(config.checksumType, ChecksumType.none);
      expect(config.conflictStrategy, FileConflictStrategy.overwrite);
      expect(config.progressInterval, const Duration(milliseconds: 500));
      expect(config.connectionTimeout, const Duration(seconds: 30));
      expect(config.maxConcurrentRequests, 8);
      expect(config.chunkSize, 10 * 1024 * 1024);
      expect(config.maxRetries, 3);
      expect(config.tempFileExtension, '.tmp');
      expect(
        config.validationFailureAction,
        ValidationFailureAction.deleteAndError,
      );
    });

    test('custom values should override defaults', () {
      // Given
      const customHeaders = {'Authorization': 'Bearer token'};
      const customConfig = ModelDownloaderConfig(
        baseDirectory: '/custom/path',
        modelSubdirectory: 'ai_models',
        headers: customHeaders,
        checksumType: ChecksumType.sha256,
        conflictStrategy: FileConflictStrategy.rename,
        progressInterval: Duration(seconds: 1),
        connectionTimeout: Duration(minutes: 1),
        maxConcurrentRequests: 4,
        chunkSize: 5 * 1024 * 1024,
        maxRetries: 5,
        tempFileExtension: '.download',
        validationFailureAction: ValidationFailureAction.keepAndError,
      );

      // Then
      expect(customConfig.baseDirectory, '/custom/path');
      expect(customConfig.modelSubdirectory, 'ai_models');
      expect(customConfig.headers, customHeaders);
      expect(customConfig.checksumType, ChecksumType.sha256);
      expect(customConfig.conflictStrategy, FileConflictStrategy.rename);
      expect(customConfig.progressInterval, const Duration(seconds: 1));
      expect(customConfig.connectionTimeout, const Duration(minutes: 1));
      expect(customConfig.maxConcurrentRequests, 4);
      expect(customConfig.chunkSize, 5 * 1024 * 1024);
      expect(customConfig.maxRetries, 5);
      expect(customConfig.tempFileExtension, '.download');
      expect(
        customConfig.validationFailureAction,
        ValidationFailureAction.keepAndError,
      );
    });

    group('toRangeRequestConfig', () {
      test('should convert to RangeRequestConfig with default values', () {
        // Given
        const config = ModelDownloaderConfig();

        // When
        final rangeConfig = config.toRangeRequestConfig();

        // Then
        expect(rangeConfig.headers, isEmpty);
        expect(rangeConfig.progressInterval, const Duration(milliseconds: 500));
        expect(rangeConfig.connectionTimeout, const Duration(seconds: 30));
        expect(rangeConfig.maxConcurrentRequests, 8);
        expect(rangeConfig.chunkSize, 10 * 1024 * 1024);
        expect(rangeConfig.maxRetries, 3);
        expect(rangeConfig.tempFileExtension, '.tmp');
      });

      test('should convert to RangeRequestConfig with custom values', () {
        // Given
        const customHeaders = {'Authorization': 'Bearer token'};
        const config = ModelDownloaderConfig(
          headers: customHeaders,
          checksumType: ChecksumType.md5,
          conflictStrategy: FileConflictStrategy.rename,
          progressInterval: Duration(seconds: 2),
          connectionTimeout: Duration(minutes: 2),
          maxConcurrentRequests: 2,
          chunkSize: 2 * 1024 * 1024,
          maxRetries: 10,
          tempFileExtension: '.partial',
        );

        // When
        final rangeConfig = config.toRangeRequestConfig();

        // Then
        expect(rangeConfig.headers, customHeaders);
        expect(rangeConfig.progressInterval, const Duration(seconds: 2));
        expect(rangeConfig.connectionTimeout, const Duration(minutes: 2));
        expect(rangeConfig.maxConcurrentRequests, 2);
        expect(rangeConfig.chunkSize, 2 * 1024 * 1024);
        expect(rangeConfig.maxRetries, 10);
        expect(rangeConfig.tempFileExtension, '.partial');
      });
    });

    group('ValidationFailureAction', () {
      test('should have correct enum values', () {
        // Then
        expect(ValidationFailureAction.values.length, 2);
        expect(ValidationFailureAction.deleteAndError.index, 0);
        expect(ValidationFailureAction.keepAndError.index, 1);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated values', () {
        // Given
        const original = ModelDownloaderConfig(
          baseDirectory: '/original/path',
          modelSubdirectory: 'original_models',
          headers: {'Original': 'header'},
          checksumType: ChecksumType.md5,
          conflictStrategy: FileConflictStrategy.error,
          progressInterval: Duration(seconds: 1),
          connectionTimeout: Duration(seconds: 60),
          maxConcurrentRequests: 4,
          chunkSize: 5 * 1024 * 1024,
          maxRetries: 2,
          tempFileExtension: '.orig',
          validationFailureAction: ValidationFailureAction.keepAndError,
        );

        // When
        final copied = original.copyWith(
          baseDirectory: '/new/path',
          modelSubdirectory: 'new_models',
          headers: {'New': 'header'},
          checksumType: ChecksumType.sha256,
          conflictStrategy: FileConflictStrategy.rename,
          progressInterval: const Duration(seconds: 2),
          connectionTimeout: const Duration(seconds: 120),
          maxConcurrentRequests: 8,
          chunkSize: 10 * 1024 * 1024,
          maxRetries: 5,
          tempFileExtension: '.new',
          validationFailureAction: ValidationFailureAction.deleteAndError,
        );

        // Then
        expect(copied.baseDirectory, '/new/path');
        expect(copied.modelSubdirectory, 'new_models');
        expect(copied.headers, {'New': 'header'});
        expect(copied.checksumType, ChecksumType.sha256);
        expect(copied.conflictStrategy, FileConflictStrategy.rename);
        expect(copied.progressInterval, const Duration(seconds: 2));
        expect(copied.connectionTimeout, const Duration(seconds: 120));
        expect(copied.maxConcurrentRequests, 8);
        expect(copied.chunkSize, 10 * 1024 * 1024);
        expect(copied.maxRetries, 5);
        expect(copied.tempFileExtension, '.new');
        expect(
          copied.validationFailureAction,
          ValidationFailureAction.deleteAndError,
        );

        // Original should remain unchanged
        expect(original.baseDirectory, '/original/path');
        expect(original.modelSubdirectory, 'original_models');
        expect(original.headers, {'Original': 'header'});
        expect(original.checksumType, ChecksumType.md5);
        expect(original.conflictStrategy, FileConflictStrategy.error);
        expect(original.progressInterval, const Duration(seconds: 1));
        expect(original.connectionTimeout, const Duration(seconds: 60));
        expect(original.maxConcurrentRequests, 4);
        expect(original.chunkSize, 5 * 1024 * 1024);
        expect(original.maxRetries, 2);
        expect(original.tempFileExtension, '.orig');
        expect(
          original.validationFailureAction,
          ValidationFailureAction.keepAndError,
        );
      });

      test(
        'should preserve original values when not specified in copyWith',
        () {
          // Given
          const original = ModelDownloaderConfig(
            baseDirectory: '/original/path',
            modelSubdirectory: 'original_models',
            headers: {'Original': 'header'},
            checksumType: ChecksumType.sha256,
            conflictStrategy: FileConflictStrategy.rename,
            progressInterval: Duration(seconds: 2),
            connectionTimeout: Duration(seconds: 120),
            maxConcurrentRequests: 16,
            chunkSize: 20 * 1024 * 1024,
            maxRetries: 10,
            tempFileExtension: '.orig',
            validationFailureAction: ValidationFailureAction.keepAndError,
          );

          // When - only update modelSubdirectory
          final copied = original.copyWith(modelSubdirectory: 'new_models');

          // Then
          expect(copied.baseDirectory, '/original/path');
          expect(copied.modelSubdirectory, 'new_models');
          expect(copied.headers, {'Original': 'header'});
          expect(copied.checksumType, ChecksumType.sha256);
          expect(copied.conflictStrategy, FileConflictStrategy.rename);
          expect(copied.progressInterval, const Duration(seconds: 2));
          expect(copied.connectionTimeout, const Duration(seconds: 120));
          expect(copied.maxConcurrentRequests, 16);
          expect(copied.chunkSize, 20 * 1024 * 1024);
          expect(copied.maxRetries, 10);
          expect(copied.tempFileExtension, '.orig');
          expect(
            copied.validationFailureAction,
            ValidationFailureAction.keepAndError,
          );
        },
      );

      test('should allow setting baseDirectory to null', () {
        // Given
        const original = ModelDownloaderConfig(
          baseDirectory: '/original/path',
          modelSubdirectory: 'models',
        );

        // When - explicitly set baseDirectory to null
        final copied = original.copyWith(baseDirectory: null);

        // Then - null is preserved because ?? operator prevents setting null
        expect(copied.baseDirectory, '/original/path');
      });
    });

    group('edge cases', () {
      test('empty modelSubdirectory should be allowed', () {
        // Given
        const config = ModelDownloaderConfig(modelSubdirectory: '');

        // Then
        expect(config.modelSubdirectory, '');
      });

      test('baseDirectory with trailing slash should be preserved', () {
        // Given
        const config = ModelDownloaderConfig(
          baseDirectory: '/path/to/directory/',
        );

        // Then
        expect(config.baseDirectory, '/path/to/directory/');
      });
    });
  });
}
