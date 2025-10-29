## 0.0.1

### Features

- **RAG Support**: Complete implementation of Retrieval Augmented Generation capabilities

  - Semantic search using vector similarity
  - Context-aware response generation
  - Document retrieval from vector stores

- **Embedding Models**: Support for both local and cloud-based embeddings

  - Local embedding models (Gemma and Gecko)
  - Gemini API-based embeddings for cloud processing
  - On-device embedding generation for privacy

- **Vector Storage**: Flexible storage options for embeddings

  - In-memory vector store for fast access
  - SQLite vector store for persistent storage
  - Automatic persistence across app restarts

- **Document Processing**: Comprehensive text chunking capabilities

  - Manual chunk management (`memorizeChunk`, `memorizeChunks`)
  - Automatic text chunking with configurable size and overlap
  - Support for large document processing

- **Streaming Responses**: Real-time text generation

  - Streaming API for progressive response display
  - Full text accumulation in `partialResult`
  - Event-based completion notification

- **Customizable Retrieval**: Fine-tuned context retrieval
  - Configurable `topK` for number of retrieved chunks
  - `minSimilarityScore` threshold for relevance filtering
  - System instructions for RAG behavior control

### Documentation

- Comprehensive README.md with usage examples
- Detailed Dart doc comments for all public APIs
- API reference documentation
- Best practices and troubleshooting guides
- Use case examples and implementation patterns

### Testing

- Complete unit test suite (28 tests)
  - Model and session creation tests
  - Embedding model configuration tests
  - Document memorization tests
  - RAG generation tests
  - Type validation tests

### Platform Support

- Android support (API level 24+)
  - GPU acceleration support
  - Hardware backend selection
  - Large heap configuration for big models

### API

Core classes and methods:

- `AiEdgeRag` - Main entry point
- `createEmbeddingModel()` - Local embedding model setup
- `createGeminiEmbedder()` - Gemini API embedder setup
- `memorizeChunk()` - Single chunk storage
- `memorizeChunks()` - Batch chunk storage
- `memorizeChunkedText()` - Automatic text chunking and storage
- `setSystemInstruction()` - RAG behavior configuration
- `generateResponseAsync()` - Context-aware streaming generation
- `EmbeddingModelConfig` - Local embedding configuration
- `GeminiEmbedderConfig` - Gemini API configuration
- `SystemInstruction` - RAG system instruction
- `VectorStore` - Storage type enum (inMemory, sqlite)
- `EmbeddingModelType` - Model type enum (gemma, gecko)

### Known Limitations

- iOS support not yet implemented (Android only)
- Embedding models must be in MediaPipe format
- SQLite vector store uses basic similarity search without advanced indexing
