# AI Edge RAG (Retrieval Augmented Generation)

[![pub package](https://img.shields.io/pub/v/ai_edge_rag.svg)](https://pub.dev/packages/ai_edge_rag)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://pub.dev/packages/ai_edge_rag)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A Flutter plugin for on-device AI inference with Retrieval Augmented Generation (RAG) capabilities powered by MediaPipe GenAI. Enable your LLMs to access and use relevant information from your own documents while keeping everything on-device.

## Features

- 📚 **RAG Support** - Enhance LLM responses with context from your own documents
- 🔍 **Semantic Search** - Find relevant information using vector similarity
- 💾 **Vector Store** - Store embeddings in memory or SQLite for persistence
- 🧠 **Local Embeddings** - Generate embeddings on-device (Gemma, Gecko models)
- ☁️ **Gemini Embeddings** - Alternative cloud-based embeddings via Gemini API
- 📄 **Text Chunking** - Automatically split large documents into manageable pieces
- 🚀 **On-device inference** - All processing happens locally (except Gemini embeddings)
- 🔒 **Privacy-first** - Your documents and queries stay on the device
- 🌊 **Streaming responses** - Real-time text generation with partial results

## Installation

```bash
flutter pub add ai_edge_rag
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  ai_edge_rag:
```

## Getting Started

### 1. Basic RAG Setup

```dart
import 'package:ai_edge_rag/ai_edge_rag.dart';

// Get the AI Edge RAG instance
final aiEdgeRag = AiEdgeRag.instance;

// Step 1: Initialize the language model
await aiEdgeRag.initialize(
  modelPath: '/path/to/your/model.task',
  maxTokens: 512,
  temperature: 0.7,
);

// Step 2: Create an embedding model for RAG
await aiEdgeRag.createEmbeddingModel(
  tokenizerModelPath: '/path/to/tokenizer.model',
  embeddingModelPath: '/path/to/embedding.bin',
  modelType: EmbeddingModelType.gemma, // Optional, defaults to gemma
  vectorStore: VectorStore.sqlite, // Optional, defaults to inMemory
);

// Step 3: Set system instruction for RAG behavior
await aiEdgeRag.setSystemInstruction(
  SystemInstruction(
    instruction: 'Use the provided context to answer questions accurately. '
        'If the answer is not in the context, say so explicitly.',
  ),
);

// Step 4: Add your documents to the vector store
await aiEdgeRag.memorizeChunkedText(
  '''Flutter is Google's UI toolkit for building beautiful, natively compiled
  applications for mobile, web, and desktop from a single codebase.

  Dart is the programming language used by Flutter. It's optimized for
  building user interfaces with features like hot reload.''',
  chunkSize: 512,
  chunkOverlap: 50,
);

// Step 5: Ask questions and get context-aware responses
final stream = aiEdgeRag.generateResponseAsync(
  'What programming language does Flutter use?',
  topK: 3, // Number of relevant chunks to retrieve
  minSimilarityScore: 0.3, // Minimum relevance threshold
);

await for (final event in stream) {
  print('Response: ${event.partialResult}');

  if (event.done) {
    print('Generation completed!');
  }
}

// Clean up when done
await aiEdgeRag.close();
```

### 2. Model Requirements

This plugin requires:

1. **Language Model**: A MediaPipe Task format model (`.task` file) for text generation
2. **Embedding Model**: Either:
   - Local embedding model files (tokenizer + embedding model)
   - Gemini API key for cloud-based embeddings

## Usage

### Using Local Embeddings (Recommended for Privacy)

```dart
// Create a local embedding model
await aiEdgeRag.createEmbeddingModel(
  tokenizerModelPath: '/path/to/tokenizer.model',
  embeddingModelPath: '/path/to/embedding.bin',
  modelType: EmbeddingModelType.gemma, // Optional: gemma (default) or gecko
  vectorStore: VectorStore.sqlite, // Optional: sqlite or inMemory (default)
  preferredBackend: PreferredBackend.gpu, // Optional: gpu or cpu (default), Android only
);
```

### Using Gemini API Embeddings

```dart
// Create a Gemini-based embedder
await aiEdgeRag.createGeminiEmbedder(
  geminiEmbeddingModel: 'models/text-embedding-004',
  geminiApiKey: 'your-api-key-here',
  vectorStore: VectorStore.sqlite, // Optional: sqlite or inMemory (default)
);
```

### Adding Documents to RAG

#### Option 1: Add Pre-chunked Text

```dart
// Add a single chunk
await aiEdgeRag.memorizeChunk(
  'Flutter is an open-source UI framework by Google.',
);

// Add multiple chunks
await aiEdgeRag.memorizeChunks([
  'Flutter is an open-source UI framework by Google.',
  'Dart is the programming language used by Flutter.',
  'Flutter supports cross-platform development.',
]);
```

#### Option 2: Auto-chunk Large Documents

```dart
// Read a large document
final document = await File('documentation.txt').readAsString();

// Automatically chunk and store
await aiEdgeRag.memorizeChunkedText(
  document,
  chunkSize: 512, // Characters per chunk
  chunkOverlap: 50, // Overlap for context continuity
);
```

### Querying with RAG

```dart
// Basic query with default settings
final stream = aiEdgeRag.generateResponseAsync(
  'How does Flutter handle state management?',
);

await for (final event in stream) {
  // Display the response as it's generated
  print(event.partialResult);

  if (event.done) {
    break;
  }
}
```

### Advanced RAG Configuration

```dart
// Customize retrieval parameters
final stream = aiEdgeRag.generateResponseAsync(
  'What is Flutter?',
  topK: 5, // Retrieve top 5 most relevant chunks
  minSimilarityScore: 0.3, // Only use chunks with similarity > 0.3
);

await for (final event in stream) {
  print(event.partialResult);
}
```

### Vector Store Options

```dart
// In-memory vector store (default, fast but not persistent)
await aiEdgeRag.createEmbeddingModel(
  tokenizerModelPath: tokenizerPath,
  embeddingModelPath: embeddingPath,
  vectorStore: VectorStore.inMemory,
);

// SQLite vector store (persistent across app restarts)
await aiEdgeRag.createEmbeddingModel(
  tokenizerModelPath: tokenizerPath,
  embeddingModelPath: embeddingPath,
  vectorStore: VectorStore.sqlite,
);
```

## Platform Setup

### iOS

❌ **Not yet supported** - RAG features are currently Android-only. iOS support is planned for a future release.

### Android

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

- For large models and documents, you may need to increase heap size in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <application
    android:largeHeap="true"
    ...>
  ```

## Model Preparation

### Language Model

This plugin uses MediaPipe Task format (`.task` files) for the language model. See the [ai_edge package documentation](https://pub.dev/packages/ai_edge) for details on obtaining `.task` models.

### Embedding Models

#### Local Embedding Models

You need two files:
1. **Tokenizer Model**: Converts text to tokens (e.g., `tokenizer.model`)
2. **Embedding Model**: Generates vector embeddings (e.g., `embedding.bin`)

Supported model types:
- **Gemma**: Text embedding models from Google's Gemma family
- **Gecko**: Text embedding models optimized for retrieval tasks

#### Gemini API Embeddings

Alternatively, use Google's Gemini API for embeddings:
- No local model files needed
- Requires internet connection
- Requires a Gemini API key
- Recommended models: `models/text-embedding-004`

## API Reference

### Main Classes

#### `AiEdgeRag`
The main entry point for RAG capabilities.

**Key Methods:**
- `initialize()` - Set up language model and session
- `createEmbeddingModel()` - Create local embedding model
- `createGeminiEmbedder()` - Create Gemini API embedder
- `memorizeChunk()` - Store a single text chunk
- `memorizeChunks()` - Store multiple text chunks
- `memorizeChunkedText()` - Auto-chunk and store large text
- `setSystemInstruction()` - Configure RAG behavior
- `generateResponseAsync()` - Generate context-aware responses
- `close()` - Clean up resources

#### `EmbeddingModelConfig`
Configuration for local embedding models:
- `tokenizerModelPath` - Path to tokenizer model file (required)
- `embeddingModelPath` - Path to embedding model file (required)
- `modelType` - Type of embedding model: `gemma` (default) or `gecko` (optional)
- `vectorStore` - Storage type: `inMemory` (default) or `sqlite` (optional)
- `preferredBackend` - Hardware backend: `cpu` (default) or `gpu` (optional, Android only)

#### `GeminiEmbedderConfig`
Configuration for Gemini API embeddings:
- `geminiEmbeddingModel` - Gemini model name (required, e.g., 'models/text-embedding-004')
- `geminiApiKey` - Your Gemini API key (required)
- `vectorStore` - Storage type: `inMemory` (default) or `sqlite` (optional)

#### `SystemInstruction`
RAG-specific system instruction:
- `instruction` - Text guiding how the model uses retrieved context

#### `VectorStore`
Storage options for embeddings:
- `inMemory` - Fast, not persistent (default)
- `sqlite` - Persistent across app restarts

#### `EmbeddingModelType`
Supported embedding models:
- `gemma` - Gemma embedding models
- `gecko` - Gecko embedding models

#### `GenerationEvent`
Event emitted during streaming generation:
- `partialResult` - The accumulated text generated so far
- `done` - Whether generation is complete

## Example App

Check out the [examples/ai_chat_rag](../../examples/ai_chat_rag/) directory for a complete RAG chat application demonstrating:

- Document loading and chunking
- Semantic search and retrieval
- Context-aware response generation
- Real-time streaming responses
- Vector store management
- Error handling

Run the example:
```bash
cd examples/ai_chat_rag
flutter run
```

## Use Cases

### Knowledge Base Q&A
Build a chatbot that answers questions based on your documentation, manuals, or knowledge base.

### Document Analysis
Let users query information from uploaded documents (PDFs, text files, etc.).

### Code Documentation Assistant
Create an assistant that helps developers by referencing your codebase documentation.

### Personal Note Assistant
Build a smart notes app where users can ask questions about their notes.

## Best Practices

### Chunking Strategy
- **Chunk size**: 256-512 characters works well for most use cases
- **Overlap**: 50-100 characters helps maintain context between chunks
- Use `memorizeChunkedText()` for automatic chunking

### System Instructions
Provide clear instructions on how to use retrieved context:
```dart
SystemInstruction(
  instruction: '''You are a helpful assistant. Use the provided context to answer questions.
  If the answer is not in the context, say "I don't have that information."
  Always cite the context when answering.'''
)
```

### Retrieval Parameters
- **topK**: Start with 3-5, increase if responses lack context
- **minSimilarityScore**: Start with 0.2-0.3, adjust based on quality

### Vector Store Choice
- Use `VectorStore.inMemory` for temporary data or prototyping
- Use `VectorStore.sqlite` for persistent knowledge bases

## Troubleshooting

### Common Issues

**Embeddings fail to create:**
- Ensure embedding model files exist at specified paths
- Check file permissions
- Verify model format matches the selected model type

**Responses don't use context:**
- Check that documents were successfully added with `memorizeChunk/s/ChunkedText`
- Increase `topK` to retrieve more context
- Lower `minSimilarityScore` threshold
- Improve system instructions to emphasize using context

**Out of memory errors:**
- Use `VectorStore.sqlite` instead of `inMemory`
- Reduce `chunkSize` when processing documents
- Process large documents in batches
- Enable `largeHeap` on Android

**Slow inference:**
- Enable GPU acceleration with `PreferredBackend.gpu`
- Use smaller language models
- Reduce `maxTokens` for shorter outputs
- Consider using Gemini API embeddings for faster embedding generation

## Limitations

- Currently Android-only (iOS support planned)
- Embedding models must be in MediaPipe format
- SQLite vector store uses basic similarity search (no advanced indexing)

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This plugin is built on top of:
- [MediaPipe GenAI](https://developers.google.com/mediapipe/solutions/genai/llm_inference) by Google for LLM inference
- [MediaPipe RAG SDK](https://developers.google.com/mediapipe) for RAG capabilities

## Links

- [Pub.dev Package](https://pub.dev/packages/ai_edge_rag)
- [GitHub Repository](https://github.com/KyoheiG3/ai_edge)
- [Issue Tracker](https://github.com/KyoheiG3/ai_edge/issues)
- [MediaPipe Documentation](https://developers.google.com/mediapipe)
- [Related Packages](https://pub.dev/packages?q=ai_edge):
  - [ai_edge](https://pub.dev/packages/ai_edge) - Basic on-device LLM inference
  - [ai_edge_fc](https://pub.dev/packages/ai_edge_fc) - Function calling support
