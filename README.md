# AI Edge - Flutter On-Device AI Inference

[![pub package](https://img.shields.io/pub/v/ai_edge.svg)](https://pub.dev/packages/ai_edge)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)](https://pub.dev/packages/ai_edge)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A comprehensive Flutter plugin suite for on-device AI inference powered by Google's MediaPipe GenAI framework, enabling powerful language models to run directly on mobile devices without internet connectivity.

## 🚀 Features

- 🔒 **Privacy-First**: All processing happens on-device, your data never leaves the device
- ⚡ **Real-time Inference**: Fast responses without network latency
- 🛠️ **Function Calling**: Enable LLMs to interact with external tools and APIs (Android only)
- 📚 **RAG Support**: Retrieval Augmented Generation with semantic search (Android only)
- 📱 **Cross-Platform**: ai_edge supports both Android and iOS, advanced features are Android-only
- 🎯 **Production Ready**: Used in production applications with comprehensive error handling
- 🤖 **MediaPipe Powered**: Built on Google's MediaPipe GenAI for reliable on-device inference

## 📦 Packages

This monorepo contains four main packages:

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

### [ai_edge_rag](packages/ai_edge_rag/)

RAG (Retrieval Augmented Generation) package for context-aware AI. **⚠️ Currently Android-only, iOS support is planned for future releases.**

- Semantic search with vector similarity
- Local embeddings (Gemma, Gecko) or Gemini API embeddings
- Vector storage (in-memory or SQLite)
- Automatic text chunking for large documents
- Context-aware response generation

### [ai_edge_model_dl](packages/ai_edge_model_dl/)

Efficient model downloader for AI Edge with advanced features.

- Resumable downloads with automatic retry
- Real-time progress tracking with speed and time estimates
- Checksum validation (MD5/SHA256) for model integrity
- Parallel chunk downloading for optimized performance
- Platform-specific storage management

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

### [ai_chat_rag](examples/ai_chat_rag/)

RAG-enabled chat application demonstrating context-aware responses.

- Document loading and processing
- Semantic search and retrieval
- Context-aware question answering
- Vector store management
- Local and cloud embedding options

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
  - Note: ai_edge_fc and ai_edge_rag are not yet supported on iOS

### Installation

Add the desired package to your `pubspec.yaml`:

```yaml
# For basic AI inference
dependencies:
  ai_edge:

# For AI with function calling (Android only)
dependencies:
  ai_edge_fc:

# For AI with RAG capabilities (Android only)
dependencies:
  ai_edge_rag:

# For efficient model downloading
dependencies:
  ai_edge_model_dl:
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

#### RAG (Retrieval Augmented Generation) (ai_edge_rag)

```dart
import 'package:ai_edge_rag/ai_edge_rag.dart';

final aiEdgeRag = AiEdgeRag.instance;

// Initialize model and embedding
await aiEdgeRag.initialize(
  modelPath: '/path/to/model.task',
  maxTokens: 512,
);

await aiEdgeRag.createEmbeddingModel(
  tokenizerModelPath: '/path/to/tokenizer.model',
  embeddingModelPath: '/path/to/embedding.bin',
  modelType: EmbeddingModelType.gemma,
  vectorStore: VectorStore.sqlite,
);

// Add documents to vector store
await aiEdgeRag.memorizeChunkedText(
  'Your document content here...',
  chunkSize: 512,
  chunkOverlap: 50,
);

// Generate context-aware responses
final stream = aiEdgeRag.generateResponseAsync(
  'What is Flutter?',
  topK: 3,
  minSimilarityScore: 0.3,
);

await for (final event in stream) {
  print(event.partialResult);
  if (event.done) break;
}
```

#### Model Downloading (ai_edge_model_dl)

```dart
import 'package:ai_edge_model_dl/ai_edge_model_dl.dart';
import 'package:ai_edge/ai_edge.dart';

final downloader = ModelDownloader();

// Download model with progress tracking
final result = await downloader.downloadModel(
  Uri.parse('https://example.com/model.task'),
  fileName: 'gemma.task',
  onProgress: (progress) {
    print('Progress: ${(progress.progress * 100).toStringAsFixed(1)}%');
    print('Speed: ${progress.speed}');
  },
);

// Use downloaded model with AI Edge
final aiEdge = AiEdge.instance;
await aiEdge.initialize(
  modelPath: result.filePath,  // Direct path from downloader
  maxTokens: 1024,
);
```

## 📱 Platform Configuration

### iOS

The plugin automatically includes necessary MediaPipe frameworks. For large models, you may need to increase memory limit by adding the following entitlement to `ios/Runner/Runner.entitlements`:

```xml
<dict>
  <key>com.apple.developer.kernel.increased-memory-limit</key>
  <true/>
</dict>
```

Make sure to configure `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` in your Xcode project settings.

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

## 📝 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google MediaPipe team for the excellent GenAI framework that powers this plugin
- Flutter community for continuous support and feedback
- All contributors who have helped improve this project
