import 'package:ai_edge_rag/ai_edge_rag.dart';

/// Represents a system instruction for RAG (Retrieval Augmented Generation) operations.
///
/// A [SystemInstruction] provides context or guidelines that define how the AI model
/// should interpret and use retrieved information in its responses. This is particularly
/// useful in RAG applications where you want to control how the model incorporates
/// retrieved context into its answers.
///
/// Example usage:
/// ```dart
/// final instruction = SystemInstruction(
///   instruction: 'Use the provided context to answer questions accurately. '
///       'If the answer is not in the context, say so explicitly.'
/// );
/// ```
final class SystemInstruction {
  /// The instruction text that guides how the model uses retrieved context.
  ///
  /// This text should clearly define the behavior expectations, such as how to
  /// handle retrieved information, formatting requirements, or response guidelines.
  final String instruction;

  /// Creates a [SystemInstruction] with the given instruction text.
  ///
  /// [instruction] - The instruction text for guiding the model's RAG behavior.
  const SystemInstruction({required this.instruction});
}

/// Represents the type of vector store used for RAG (Retrieval Augmented Generation).
///
/// Vector stores are used to store and efficiently retrieve embeddings
/// for similarity search operations in RAG applications.
enum VectorStore {
  /// In-memory vector store
  ///
  /// Stores vectors in memory for fast access but does not persist data.
  /// Best for temporary storage or when persistence is not required.
  inMemory('Default'),

  /// SQLite vector store
  ///
  /// Stores vectors in a SQLite database for persistent storage.
  /// Best for applications that require data persistence across sessions.
  sqlite('SQLite');

  /// The string value representing the vector store type.
  final String value;

  /// Creates a [VectorStore] enum with the given string value.
  const VectorStore(this.value);
}

/// Represents the type of embedding model used for generating vector embeddings.
///
/// Embedding models convert text into dense vector representations that can
/// be used for similarity search and retrieval operations.
enum EmbeddingModelType {
  /// Gemma embedding model
  ///
  /// A text embedding model from Google's Gemma family.
  gemma('Gemma'),

  /// Gecko embedding model
  ///
  /// A text embedding model optimized for retrieval tasks.
  gecko('Gecko');

  /// The string value representing the embedding model type.
  final String value;

  /// Creates an [EmbeddingModelType] enum with the given string value.
  const EmbeddingModelType(this.value);
}

/// Configuration for a local embedding model used in RAG applications.
///
/// This class specifies the paths to the tokenizer and embedding model files,
/// the model type, and optional configurations for vector storage and backend preference.
///
/// Example usage:
/// ```dart
/// final config = EmbeddingModelConfig(
///   tokenizerModelPath: '/path/to/tokenizer.model',
///   embeddingModelPath: '/path/to/embedding.bin',
///   modelType: EmbeddingModelType.gemma,
///   vectorStore: VectorStore.sqlite,
///   preferredBackend: PreferredBackend.gpu,
/// );
/// ```
final class EmbeddingModelConfig {
  /// Path to the tokenizer model file.
  ///
  /// The tokenizer is used to convert text into tokens before embedding.
  final String tokenizerModelPath;

  /// Path to the embedding model file.
  ///
  /// This model generates vector embeddings from tokenized input.
  final String embeddingModelPath;

  /// The type of embedding model being used.
  final EmbeddingModelType? modelType;

  /// Optional vector store type for storing embeddings.
  ///
  /// If not specified, uses the default vector store (inMemory).
  final VectorStore? vectorStore;

  /// Optional preferred backend for running the model.
  ///
  /// Specifies whether to use CPU, GPU, or other available backends.
  /// If not specified, uses the default backend (CPU).
  final PreferredBackend? preferredBackend;

  /// Creates an [EmbeddingModelConfig] with the specified model paths and type.
  ///
  /// [tokenizerModelPath] - Path to the tokenizer model file
  /// [embeddingModelPath] - Path to the embedding model file
  /// [modelType] - The type of embedding model
  /// [vectorStore] - Optional vector store type
  /// [preferredBackend] - Optional preferred computational backend
  const EmbeddingModelConfig({
    required this.tokenizerModelPath,
    required this.embeddingModelPath,
    this.modelType,
    this.vectorStore,
    this.preferredBackend,
  });

  /// Converts the configuration to a map representation.
  ///
  /// Returns a map containing all configuration values, suitable for
  /// serialization or passing to platform-specific implementations.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tokenizerModelPath': tokenizerModelPath,
      'embeddingModelPath': embeddingModelPath,
      'modelType': (modelType ?? EmbeddingModelType.gemma).value,
    };
    if (vectorStore != null) {
      map['vectorStore'] = vectorStore!.value;
    }
    if (preferredBackend != null) {
      map['preferredBackend'] = preferredBackend!.value;
    }
    return map;
  }
}

/// Configuration for using Google's Gemini API for embeddings in RAG applications.
///
/// This class specifies the Gemini embedding model and API credentials,
/// along with optional vector storage configuration.
///
/// Example usage:
/// ```dart
/// final config = GeminiEmbedderConfig(
///   geminiEmbeddingModel: 'models/text-embedding-004',
///   geminiApiKey: 'your-api-key',
///   vectorStore: VectorStore.sqlite,
/// );
/// ```
final class GeminiEmbedderConfig {
  /// The name of the Gemini embedding model to use.
  ///
  /// For example: 'models/text-embedding-004' or 'models/embedding-001'.
  final String geminiEmbeddingModel;

  /// The API key for accessing Google's Gemini API.
  ///
  /// This key is required for authentication with the Gemini service.
  final String geminiApiKey;

  /// Optional vector store type for storing embeddings.
  ///
  /// If not specified, uses the default vector store (inMemory).
  final VectorStore? vectorStore;

  /// Creates a [GeminiEmbedderConfig] with the specified model and API key.
  ///
  /// [geminiEmbeddingModel] - The name of the Gemini embedding model
  /// [geminiApiKey] - Your Gemini API key
  /// [vectorStore] - Optional vector store type
  const GeminiEmbedderConfig({
    required this.geminiEmbeddingModel,
    required this.geminiApiKey,
    this.vectorStore,
  });

  /// Converts the configuration to a map representation.
  ///
  /// Returns a map containing all configuration values, suitable for
  /// serialization or passing to platform-specific implementations.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'geminiEmbeddingModel': geminiEmbeddingModel,
      'geminiApiKey': geminiApiKey,
    };
    if (vectorStore != null) {
      map['vectorStore'] = vectorStore!.value;
    }
    return map;
  }
}
