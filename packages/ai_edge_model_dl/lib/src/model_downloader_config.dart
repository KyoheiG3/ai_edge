import 'package:range_request/range_request.dart';

/// Behavior when validation fails
enum ValidationFailureAction {
  /// Delete the downloaded file and throw error
  deleteAndError,

  /// Keep the file and throw error
  keepAndError,
}

/// Configuration for ModelDownloader
class ModelDownloaderConfig {
  /// Base directory path where models will be stored
  /// If null, uses platform-specific default directory
  /// Note: modelSubdirectory will be appended to this path
  final String? baseDirectory;

  /// Subdirectory name for models
  /// This is always appended to the base directory (whether custom or platform-specific)
  final String modelSubdirectory;

  /// Headers to include in download requests (e.g., authorization)
  final Map<String, String> headers;

  /// Checksum type for downloaded files
  final ChecksumType checksumType;

  /// File conflict resolution strategy
  final FileConflictStrategy conflictStrategy;

  /// Progress update interval
  final Duration progressInterval;

  /// Connection timeout for downloads
  final Duration connectionTimeout;

  /// Maximum concurrent downloads
  final int maxConcurrentRequests;

  /// Chunk size for downloads
  final int chunkSize;

  /// Maximum retry attempts
  final int maxRetries;

  /// Temporary file extension
  final String tempFileExtension;

  /// Action to take when validation fails
  final ValidationFailureAction validationFailureAction;

  const ModelDownloaderConfig({
    this.baseDirectory,
    this.modelSubdirectory = 'models',
    this.headers = const {},
    this.checksumType = ChecksumType.none,
    this.conflictStrategy = FileConflictStrategy.overwrite,
    this.progressInterval = const Duration(milliseconds: 500),
    this.connectionTimeout = const Duration(seconds: 30),
    this.maxConcurrentRequests = 8,
    this.chunkSize = 10 * 1024 * 1024, // 10MB
    this.maxRetries = 3,
    this.tempFileExtension = '.tmp',
    this.validationFailureAction = ValidationFailureAction.deleteAndError,
  });

  /// Create a RangeRequestConfig from this configuration
  RangeRequestConfig toRangeRequestConfig() {
    return RangeRequestConfig(
      headers: headers,
      chunkSize: chunkSize,
      maxConcurrentRequests: maxConcurrentRequests,
      maxRetries: maxRetries,
      retryDelayMs: 1000,
      tempFileExtension: tempFileExtension,
      connectionTimeout: connectionTimeout,
      progressInterval: progressInterval,
    );
  }

  /// Create a copy with updated fields
  ModelDownloaderConfig copyWith({
    String? baseDirectory,
    String? modelSubdirectory,
    Map<String, String>? headers,
    ChecksumType? checksumType,
    FileConflictStrategy? conflictStrategy,
    Duration? progressInterval,
    Duration? connectionTimeout,
    int? maxConcurrentRequests,
    int? chunkSize,
    int? maxRetries,
    String? tempFileExtension,
    ValidationFailureAction? validationFailureAction,
  }) {
    return ModelDownloaderConfig(
      baseDirectory: baseDirectory ?? this.baseDirectory,
      modelSubdirectory: modelSubdirectory ?? this.modelSubdirectory,
      headers: headers ?? this.headers,
      checksumType: checksumType ?? this.checksumType,
      conflictStrategy: conflictStrategy ?? this.conflictStrategy,
      progressInterval: progressInterval ?? this.progressInterval,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      maxConcurrentRequests:
          maxConcurrentRequests ?? this.maxConcurrentRequests,
      chunkSize: chunkSize ?? this.chunkSize,
      maxRetries: maxRetries ?? this.maxRetries,
      tempFileExtension: tempFileExtension ?? this.tempFileExtension,
      validationFailureAction:
          validationFailureAction ?? this.validationFailureAction,
    );
  }
}
