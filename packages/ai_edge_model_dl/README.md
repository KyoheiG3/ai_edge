# AI Edge Model DL (Downloader)

[![pub package](https://img.shields.io/pub/v/ai_edge_model_dl.svg)](https://pub.dev/packages/ai_edge_model_dl)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue.svg)](https://pub.dev/packages/ai_edge_model_dl)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A Flutter plugin for downloading and managing AI models efficiently, with seamless integration for AI Edge packages. Simplifies model path management and provides resumable downloads, progress tracking, and automatic validation.

## Features

- 🤝 **AI Edge Integration** - Seamless path resolution for AI Edge packages - just pass the model path directly
- 📥 **Resumable Downloads** - Automatically resume interrupted downloads from where they left off
- 📊 **Progress Tracking** - Real-time download progress with speed and time estimates
- ✅ **Checksum Validation** - Automatic MD5/SHA256 validation to ensure model integrity
- 🔄 **Parallel Downloads** - Concurrent chunk downloading for faster speeds
- 💾 **Smart Storage** - Platform-specific directory management with customizable paths
- 🎯 **File Management** - List, check, and delete downloaded models
- ⚡ **Optimized Performance** - Configurable chunk size and connection settings

## Installation

```bash
flutter pub add ai_edge_model_dl
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  ai_edge_model_dl:
```

## Getting Started

### Basic Usage

```dart
import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';

// Create a downloader instance
final downloader = ModelDownloader();

// Download a model
final result = await downloader.downloadModel(
  Uri.parse('https://example.com/model.task'),
  fileName: 'gemma.task',
  expectedChecksum: 'abc123...', // Optional MD5 or SHA256
  expectedFileSize: 1024000,     // Optional size validation
  onProgress: (progress) {
    print('Progress: ${(progress.progress * 100).toStringAsFixed(1)}%');
    print('Speed: ${progress.speed}');
    print('Remaining: ${progress.remainingTime}');
  },
);

print('Model downloaded to: ${result.filePath}');
print('Size: ${result.fileSize} bytes');
print('Checksum: ${result.checksum}');
```

### Integration with AI Edge

```dart
import 'package:ai_edge/ai_edge.dart';
import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';

// Download and use model with AI Edge
final downloader = ModelDownloader();

// Download model
final result = await downloader.downloadModel(
  Uri.parse('https://example.com/gemma.task'),
  fileName: 'gemma.task',
);

// Use directly with AI Edge - path resolution is handled automatically
final aiEdge = AiEdge.instance;
await aiEdge.initialize(
  modelPath: result.filePath,  // Direct path usage - no manual path management needed
  maxTokens: 512,
);

// Or check if model exists before initializing
final modelPath = await downloader.getModelPath('gemma.task');
if (await downloader.isModelDownloaded('gemma.task')) {
  await aiEdge.initialize(
    modelPath: modelPath,
    maxTokens: 512,
  );
}
```

### Configuration

```dart
// Create a downloader with custom configuration
final downloader = ModelDownloader(
  config: const ModelDownloaderConfig(
    // Custom base directory (default: platform-specific)
    baseDirectory: '/custom/path',

    // Subdirectory for models (default: 'models')
    modelSubdirectory: 'ai_models',

    // Download settings
    chunkSize: 5 * 1024 * 1024,  // 5MB chunks
    maxConcurrentRequests: 4,     // Parallel connections
    maxRetries: 3,                // Retry attempts
    connectionTimeout: Duration(seconds: 30),

    // Validation
    checksumType: ChecksumType.sha256,
    validationFailureAction: ValidationFailureAction.deleteAndError,

    // Progress updates
    progressInterval: Duration(milliseconds: 500),

    // File conflict strategy
    conflictStrategy: FileConflictStrategy.overwrite,

    // Custom headers (e.g., for authentication)
    headers: {'Authorization': 'Bearer token'},
  ),
);
```

## Usage

### Download with Progress Tracking

```dart
await downloader.downloadModel(
  Uri.parse('https://huggingface.co/model.task'),
  fileName: 'model.task',
  onProgress: (progress) {
    // Progress information
    print('Downloaded: ${progress.downloadedSize} / ${progress.totalSize}');
    print('Progress: ${(progress.progress * 100).toStringAsFixed(1)}%');
    print('Speed: ${progress.speed}');

    // Time estimates
    print('Remaining time: ${progress.remainingTime}');

    // Custom time formatting
    final formatted = progress.formatRemainingTime('H hours M minutes');
    print('Time left: $formatted');
  },
);
```

### Checksum Validation

```dart
// MD5 validation (32 characters)
final result = await downloader.downloadModel(
  modelUri,
  expectedChecksum: 'd41d8cd98f00b204e9800998ecf8427e',
);

// SHA256 validation (64 characters)
final result = await downloader.downloadModel(
  modelUri,
  expectedChecksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
);

// File size validation
final result = await downloader.downloadModel(
  modelUri,
  expectedFileSize: 1024000, // Expected size in bytes
);
```

### Cancel Downloads

```dart
// Start a download
final downloadFuture = downloader.downloadModel(
  modelUri,
  onProgress: (progress) {
    print('Progress: ${progress.progress}');
  },
);

// Cancel if needed (uses CancelToken internally)
downloader.cancelDownload();

// Handle cancellation
try {
  await downloadFuture;
} catch (e) {
  print('Download cancelled or failed: $e');
}
```

### Model Management

```dart
// Get models directory path
final modelsDir = await downloader.getModelsDirectory();
print('Models stored in: $modelsDir');

// Get path for a specific model
final modelPath = await downloader.getModelPath('gemma.task');
print('Model path: $modelPath');

// Check if a model exists
final exists = await downloader.isModelDownloaded('gemma.task');
print('Model exists: $exists');

// List all downloaded models
final models = await downloader.getDownloadedModels();
for (final model in models) {
  print('Found model: $model');
}

// Delete a model
await downloader.deleteModel('old_model.task');
```

### Error Handling

```dart
try {
  final result = await downloader.downloadModel(
    modelUri,
    expectedChecksum: 'abc123...',
    expectedFileSize: 1024000,
  );
} on ModelDownloaderException catch (e) {
  switch (e.code) {
    case ModelDownloaderErrorCode.checksumMismatch:
      print('Checksum validation failed: ${e.message}');
    case ModelDownloaderErrorCode.fileSizeMismatch:
      print('File size validation failed: ${e.message}');
    case ModelDownloaderErrorCode.invalidChecksumFormat:
      print('Invalid checksum format: ${e.message}');
  }
} catch (e) {
  // Handle other exceptions (network errors, etc.)
  print('Download failed: $e');
}
```

### Resume Interrupted Downloads

Downloads are automatically resumed if interrupted. The downloader:
1. Detects partial downloads (`.tmp` files)
2. Verifies existing chunks
3. Continues from the last successful position
4. Validates the complete file after resuming

```dart
// If this download is interrupted...
await downloader.downloadModel(
  modelUri,
  fileName: 'large_model.task',
);

// ...calling it again will resume from where it stopped
await downloader.downloadModel(
  modelUri,
  fileName: 'large_model.task',
);
```

## Platform Setup

### iOS

No additional setup required. Models are stored in the app's Application Support directory.

### Android

No additional setup required. Models are stored in the app's external storage directory (if available) or Application Support directory.

### Storage Locations

By default, models are stored in:
- **iOS**: `<app_support>/models/` (Application Support directory - not backed up to iCloud)
- **Android**: `<external_storage>/models/` or `<app_support>/models/` (External storage preferred for better space availability)

You can customize the storage location:

```dart
final downloader = ModelDownloader(
  config: const ModelDownloaderConfig(
    baseDirectory: '/custom/path',
    modelSubdirectory: 'ai_models',
  ),
);
```

## API Reference

### Main Classes

#### `ModelDownloader`
The main class for downloading and managing models.

#### `ModelDownloaderConfig`
Configuration options:
- `baseDirectory`: Custom base directory path (nullable)
- `modelSubdirectory`: Subdirectory name for models (default: 'models')
- `headers`: HTTP headers for requests
- `checksumType`: Type of checksum validation (`ChecksumType.md5`, `ChecksumType.sha256`, `ChecksumType.none`)
- `conflictStrategy`: How to handle existing files (`FileConflictStrategy.overwrite`, `FileConflictStrategy.rename`, `FileConflictStrategy.error`)
- `progressInterval`: How often to emit progress updates
- `connectionTimeout`: HTTP connection timeout
- `maxConcurrentRequests`: Number of parallel connections
- `chunkSize`: Size of each download chunk in bytes
- `maxRetries`: Number of retry attempts
- `tempFileExtension`: Extension for temporary files during download (default: '.tmp')
- `validationFailureAction`: Action on validation failure (`ValidationFailureAction.deleteAndError`, `ValidationFailureAction.keepAndError`)

#### `ModelDownloadProgress`
Download progress information:
- `progress`: Download percentage (0.0 to 1.0)
- `downloadedBytes`: Bytes downloaded so far
- `totalBytes`: Total file size
- `bytesPerSecond`: Current download speed
- `estimatedTimeRemaining`: Estimated time to completion
- `downloadedSize`: Human-readable downloaded size (e.g., "1.5 MB")
- `totalSize`: Human-readable total size
- `speed`: Human-readable speed (e.g., "2.5 MB/s")
- `remainingTime`: Formatted remaining time
- `formatRemainingTime(pattern)`: Custom time formatting

#### `ValidationFailureAction`
Actions when validation fails:
- `deleteAndError`: Delete the file and throw error (default)
- `keepAndError`: Keep the file and throw error

#### `ModelDownloaderException`
Exception class for model downloader errors:
- `code`: Error code (`ModelDownloaderErrorCode`)
- `message`: Human-readable error message
- `details`: Optional details map with error-specific information

#### `ModelDownloaderErrorCode`
Error codes for exception handling:
- `checksumMismatch`: Checksum validation failed
- `fileSizeMismatch`: File size validation failed
- `invalidChecksumFormat`: Invalid checksum format (wrong length)

## Example App

Check out the complete example in the repository for demonstrations of:
- Model downloading with progress UI
- Resume capability after app restart
- Download cancellation
- Error handling
- Model management (list, delete)

## Troubleshooting

### Common Issues

**Download fails immediately:**
- Check network connectivity
- Verify the URL is accessible
- Ensure proper headers are set if authentication is required

**Checksum validation fails:**
- Verify the expected checksum is correct
- Ensure the checksum type matches (MD5 vs SHA256)
- Check if the file is corrupted during download

**Out of storage space:**
- Check available device storage
- Clean up old models using `deleteModel()`
- Consider downloading to external storage on Android

**Slow download speeds:**
- Increase `chunkSize` for better throughput
- Adjust `maxConcurrentRequests` based on server capabilities
- Check network connection quality

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Links

- [Pub.dev Package](https://pub.dev/packages/ai_edge_model_dl)
- [GitHub Repository](https://github.com/KyoheiG3/ai_edge)
- [Issue Tracker](https://github.com/KyoheiG3/ai_edge/issues)