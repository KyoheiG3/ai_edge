/// Error codes for model downloader exceptions
enum ModelDownloaderErrorCode {
  /// Checksum validation failed
  checksumMismatch,

  /// File size validation failed
  fileSizeMismatch,

  /// Invalid checksum format (wrong length)
  invalidChecksumFormat,
}

/// Exception for model downloader related errors
class ModelDownloaderException implements Exception {
  /// The error code identifying the type of error
  final ModelDownloaderErrorCode code;

  /// Human-readable error message
  final String message;

  /// Optional details about the error
  final Map<String, dynamic>? details;

  const ModelDownloaderException({
    required this.code,
    required this.message,
    this.details,
  });

  /// Factory constructor for checksum mismatch
  factory ModelDownloaderException.checksumMismatch({
    required String expected,
    String? actual,
  }) {
    return ModelDownloaderException(
      code: ModelDownloaderErrorCode.checksumMismatch,
      message: actual != null
          ? 'Checksum mismatch. Expected: $expected, Got: $actual'
          : 'Checksum validation failed. Expected: $expected',
      details: {'expected': expected, if (actual != null) 'actual': actual},
    );
  }

  /// Factory constructor for file size mismatch
  factory ModelDownloaderException.fileSizeMismatch({
    required int expected,
    required int actual,
  }) {
    return ModelDownloaderException(
      code: ModelDownloaderErrorCode.fileSizeMismatch,
      message:
          'File size mismatch. Expected: $expected bytes, Got: $actual bytes',
      details: {'expected': expected, 'actual': actual},
    );
  }

  /// Factory constructor for invalid checksum format
  factory ModelDownloaderException.invalidChecksumFormat({
    required int length,
  }) {
    return ModelDownloaderException(
      code: ModelDownloaderErrorCode.invalidChecksumFormat,
      message:
          'Invalid checksum length: $length. '
          'Expected 32 (MD5) or 64 (SHA256) characters.',
      details: {'length': length},
    );
  }

  @override
  String toString() {
    return 'ModelDownloaderException[${code.name}]: $message';
  }
}
