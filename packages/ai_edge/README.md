# AI Edge

[![pub package](https://img.shields.io/pub/v/ai_edge.svg)](https://pub.dev/packages/ai_edge)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue.svg)](https://pub.dev/packages/ai_edge)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A Flutter plugin for on-device AI inference powered by MediaPipe GenAI. Run large language models directly on mobile devices with optimized performance and privacy.

## Features

- 🚀 **On-device inference** - Run LLMs locally without internet connection
- 🔒 **Privacy-first** - All processing happens on the device, no data leaves the phone
- ⚡ **Hardware acceleration** - Supports GPU acceleration for faster inference
- 🌊 **Streaming responses** - Real-time text generation with partial results
- 🖼️ **Multi-modal support** - Process both text and images (vision-language models)
- 💬 **Session management** - Maintain conversation context across multiple queries
- 🎯 **Flexible configuration** - Customize temperature, top-k, top-p, and other parameters

## Installation

```bash
flutter pub add ai_edge
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  ai_edge:
```

## Getting Started

### 1. Basic Setup

```dart
import 'package:ai_edge/ai_edge.dart';

// Initialize the AI model
final aiEdge = AiEdge.instance;
await aiEdge.initialize(
  modelPath: '/path/to/your/model.task',
  maxTokens: 512,
);

// Generate a response
final response = await aiEdge.generateResponse('What is Flutter?');
print(response);

// Clean up when done
await aiEdge.close();
```

### 2. Download and Setup Model

This plugin requires a MediaPipe Task format model (`.task` file). You can:

1. Download pre-converted `.task` models from [MediaPipe Model Gallery](https://developers.google.com/mediapipe/solutions/genai/llm_inference#models)
2. Convert your own models to `.task` format using [MediaPipe Model Maker](https://developers.google.com/mediapipe/solutions/model_maker)
3. Download ready-to-use `.task` models from Hugging Face (example: [gemma-3n-E2B-it-litert-preview](https://huggingface.co/google/gemma-3n-E2B-it-litert-preview))

Place the model file in your app's documents directory or assets.

## Usage

### Basic Text Generation

```dart
// Simple query-response
final response = await aiEdge.generateResponse(
  'Explain quantum computing in simple terms'
);
```

### Streaming Responses

```dart
// Get real-time partial results as the model generates text
final stream = aiEdge.generateResponseAsync('Write a story about a robot');

await for (final event in stream) {
  print('Partial: ${event.partialResult}');
  
  if (event.done) {
    print('Generation completed!');
  }
}
```

### Multi-turn Conversations

```dart
// Build context for conversations
await aiEdge.addQueryChunk('You are a helpful assistant.');
await aiEdge.addQueryChunk('Previous context: User asked about Flutter');

final response = await aiEdge.generateResponse(
  'What are its main advantages?'
);
```

### Multi-modal Input (Text + Image)

```dart
import 'dart:io';

// Add image to the session
final imageBytes = await File('path/to/image.jpg').readAsBytes();
await aiEdge.addImage(imageBytes);

// Ask about the image
final response = await aiEdge.generateResponse(
  'What objects do you see in this image?'
);
```

### Advanced Configuration

```dart
// Initialize with custom settings
await aiEdge.initialize(
  modelPath: modelPath,
  maxTokens: 1024,
  preferredBackend: PreferredBackend.gpu,  // Android only, ignored on iOS
  sessionConfig: SessionConfig(
    temperature: 0.7,  // Control randomness (0.0-1.0)
    topK: 40,         // Limit vocabulary size
    topP: 0.95,       // Nucleus sampling threshold
    randomSeed: 42,   // For reproducible outputs
  ),
);
```

## Platform Setup

### iOS Requirements

- iOS 15.0 or later
- Add to your `Info.plist` if loading models from network:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
  ```

- **Recommended Devices**:

  - Optimal performance on iPhone 12 or newer
  - iPad with A14 Bionic chip or later
  - Other high-end iOS devices with comparable specs

- For large models, you may need to increase memory limit by adding the following entitlement to `ios/Runner/Runner.entitlements`:
  ```xml
  <dict>
    <key>com.apple.developer.kernel.increased-memory-limit</key>
    <true/>
  </dict>
  ```
  Make sure to configure `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` in your Xcode project settings.

### Android Requirements

- **Minimum SDK**: Android API level 24 (Android 7.0) or later
  - This is a requirement from MediaPipe GenAI SDK
  - Flutter's default minSdkVersion is 21, so you **must** update it

- Add to your `android/app/build.gradle`:
  ```gradle
  android {
    defaultConfig {
        minSdkVersion 24  // Required by MediaPipe GenAI
    }
  }
  ```

- **Recommended Devices**: 
  - Optimal performance on Pixel 7 or newer
  - Other high-end Android devices with comparable specs

- For large models, you may need to increase heap size in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <application
    android:largeHeap="true"
    ...>
  ```

## Model Preparation

### Model Format

This plugin uses MediaPipe Task format (`.task` files) which are optimized for mobile inference. Any LLM model converted to `.task` format can be used with this plugin.

**Tested models include:**
- Gemma models (2B, 3B variants)
- Hammer models
- Other models converted to MediaPipe Task format

The key requirement is that the model must be in `.task` format. Models in other formats (GGUF, SafeTensors, etc.) need to be converted first.

### Model Storage

**Option 1: Download at runtime (Recommended for large models)**
```dart
import 'package:path_provider/path_provider.dart';

// Download model to app's documents directory
final documentsDir = await getApplicationDocumentsDirectory();
final modelPath = '${documentsDir.path}/models/gemma.task';

// Use the modelPath with AiEdge
await aiEdge.initialize(modelPath: modelPath, maxTokens: 512);
```

**Option 2: Bundle with app (For smaller models)**
```dart
// First, add to pubspec.yaml:
// flutter:
//   assets:
//     - assets/models/

// Then use the asset path directly
await aiEdge.initialize(
  modelPath: 'assets/models/model.task',
  maxTokens: 512,
);
```

**Model Size Considerations:**
- Models < 100MB: Can be bundled as assets
- Models > 100MB: Download on first launch to save app size
- Use the example app's download manager for reference implementation

## API Reference

### Main Classes

#### `AiEdge`
The main entry point for the plugin. Provides methods for model initialization and text generation.

#### `ModelConfig`
Configuration for model initialization:
- `modelPath`: Path to the .task model file
- `maxTokens`: Maximum tokens to generate
- `preferredBackend`: CPU or GPU acceleration (Android only, ignored on iOS)
- `supportedLoraRanks`: LoRA adapter support
- `maxNumImages`: Maximum images for multi-modal input

#### `SessionConfig`
Configuration for generation sessions:
- `temperature`: Controls randomness (0.0-1.0)
- `topK`: Top-K sampling parameter
- `topP`: Top-P (nucleus) sampling parameter
- `randomSeed`: Seed for reproducible generation

#### `GenerationEvent`
Event emitted during streaming generation:
- `partialResult`: The generated text so far
- `done`: Whether generation is complete

## Example App

Check out the [examples/ai_chat](examples/ai_chat/) directory for a complete chat application demonstrating:

- Model download and management
- Real-time streaming responses
- Conversation history
- Error handling
- UI best practices

Run the example:
```bash
cd examples/ai_chat
flutter run
```

## Development

### Running Tests

#### Setting up Hugging Face Token

Some integration tests download models from Hugging Face and require authentication:

```bash
# Set your Hugging Face token as an environment variable
export HF_TOKEN="your_hugging_face_token_here"

# Or pass it directly when running tests
HF_TOKEN="your_token" ./scripts/test_local_ios.sh
```

To get a Hugging Face token:
1. Create an account at [huggingface.co](https://huggingface.co)
2. Go to Settings → Access Tokens
3. Create a new token with read permissions

#### Running Test Scripts

Quick test commands:
```bash
# iOS (macOS only)
./scripts/test_local_ios.sh

# Android
./scripts/test_local_android.sh
```

## Troubleshooting

### Common Issues

**Model loading fails:**
- Ensure the model file exists at the specified path
- Check file permissions
- Verify the model is in MediaPipe Task format

**Out of memory errors:**
- Use smaller models or reduce `maxTokens`
- Enable `largeHeap` on Android
- Consider using quantized models

**Slow inference:**
- Enable GPU acceleration with `PreferredBackend.gpu`
- Use smaller models for faster response
- Reduce `maxTokens` for shorter outputs

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This plugin is built on top of [MediaPipe GenAI](https://developers.google.com/mediapipe/solutions/genai/llm_inference) by Google, providing optimized on-device inference for mobile platforms.

## Links

- [Pub.dev Package](https://pub.dev/packages/ai_edge)
- [GitHub Repository](https://github.com/KyoheiG3/ai_edge)
- [Issue Tracker](https://github.com/KyoheiG3/ai_edge/issues)
- [MediaPipe Documentation](https://developers.google.com/mediapipe)