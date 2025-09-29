# AI Edge - Flutter On-Device AI Inference

[![pub package](https://img.shields.io/pub/v/ai_edge.svg)](https://pub.dev/packages/ai_edge)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)](https://pub.dev/packages/ai_edge)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A comprehensive Flutter plugin suite for on-device AI inference powered by Google's MediaPipe GenAI framework, enabling powerful language models to run directly on mobile devices without internet connectivity.

## 🚀 Features

- 🔒 **Privacy-First**: All processing happens on-device, your data never leaves the device
- ⚡ **Real-time Inference**: Fast responses without network latency  
- 🛠️ **Function Calling**: Enable LLMs to interact with external tools and APIs (Android only)
- 📱 **Cross-Platform**: ai_edge supports both Android and iOS, ai_edge_fc is Android-only
- 🎯 **Production Ready**: Used in production applications with comprehensive error handling
- 🤖 **MediaPipe Powered**: Built on Google's MediaPipe GenAI for reliable on-device inference

## 📦 Packages

This monorepo contains two main packages:

### [ai_edge](packages/ai_edge/)
Core package for basic on-device AI inference.

- Text generation with streaming support
- Customizable generation parameters (temperature, top-k, top-p)
- Session management and conversation history
- Support for various model formats

### [ai_edge_fc](packages/ai_edge_fc/)
Extended package with function calling capabilities. **⚠️ Currently Android-only, iOS support is planned for future releases.**

- Define functions that LLMs can call
- Structured output with constraints
- Tool integration for complex workflows
- System instructions for behavior customization

## 🎮 Example Apps

### [ai_chat](examples/ai_chat/)
Basic chat application demonstrating core AI Edge features.

- Simple conversational interface
- Model management and downloading
- Streaming text generation
- Basic chat history

### [ai_chat_fc](examples/ai_chat_fc/)
Advanced chat application with function calling demonstrations.

- Weather information retrieval
- Calculator functions
- Time and date information
- Quick action buttons for common queries
- Model download management with progress tracking

## 🚦 Getting Started

### Prerequisites

- Flutter 3.32.0 or later
- Dart 3.8.0 or later
- Android:
  - Minimum SDK: 24 (Android 7.0) - Required by Google MediaPipe GenAI
  - Recommended: Pixel 7 or newer for optimal performance
- iOS:
  - Minimum iOS 15.0 (ai_edge only)
  - Recommended: iPhone 12 or newer
  - Note: ai_edge_fc is not yet supported on iOS

### Installation

Add the desired package to your `pubspec.yaml`:

```yaml
# For basic AI inference
dependencies:
  ai_edge:

# For AI with function calling
dependencies:
  ai_edge_fc:
```

### Quick Example

#### Basic Usage (ai_edge)
```dart
import 'package:ai_edge/ai_edge.dart';

final aiEdge = AiEdge.instance;

// Initialize model
await aiEdge.initialize(
  modelPath: '/path/to/model.task',
  maxTokens: 1024,
);

// Generate text
final response = await aiEdge.generateContent(
  'Tell me about Flutter',
);
print(response);
```

#### Function Calling (ai_edge_fc)
```dart
import 'package:ai_edge_fc/ai_edge_fc.dart';

final aiEdgeFc = AiEdgeFc.instance;

// Define functions
final functions = [
  FunctionDeclaration(
    name: 'get_weather',
    description: 'Get current weather',
    properties: [
      FunctionProperty(
        name: 'location',
        type: PropertyType.string,
        required: true,
      ),
    ],
  ),
];

// Initialize with functions
await aiEdgeFc.initialize(
  modelPath: '/path/to/model.task',
  maxTokens: 1024,
);
await aiEdgeFc.setFunctions(functions);
await aiEdgeFc.createSession();

// Send message that triggers function call
final response = await aiEdgeFc.sendMessage(
  Message(role: 'user', text: 'What\'s the weather in Tokyo?'),
);

// Handle function call
if (response.functionCall != null) {
  // Execute function and send result back
  final result = await getWeather('Tokyo');
  final functionResponse = FunctionResponse(
    functionCall: response.functionCall!,
    response: result,
  );
  final finalResponse = await aiEdgeFc.sendFunctionResponse(functionResponse);
}
```

## 📱 Platform Configuration

### Android

Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Required by MediaPipe GenAI
    }
}
```

For large models, add to `AndroidManifest.xml`:
```xml
<application
    android:largeHeap="true"
    ...>
```

### iOS

The plugin automatically includes necessary MediaPipe frameworks. No additional configuration needed.

## 📝 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google MediaPipe team for the excellent GenAI framework that powers this plugin
- Flutter community for continuous support and feedback
- All contributors who have helped improve this project

