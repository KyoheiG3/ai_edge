import 'dart:async';

import 'package:ai_edge/ai_edge.dart';
import 'package:flutter/services.dart';
import 'ai_edge_rag_platform_interface.dart';

import 'types.dart';

export 'package:ai_edge/ai_edge.dart'
    show ModelConfig, SessionConfig, PreferredBackend;

class AiEdgeRag {
  static final AiEdgeRag _instance = AiEdgeRag._();

  AiEdgeRag._();

  /// Returns the singleton instance of [AiEdgeRag].
  ///
  /// This plugin uses a singleton pattern to ensure only one model and session
  /// are active at a time, managing resources efficiently on mobile devices.
  ///
  /// Example:
  /// ```dart
  /// final AiEdgeRag = AiEdgeRag.instance;
  /// ```
  static AiEdgeRag get instance => _instance;

  /// Creates and loads an AI model with the specified configuration.
  ///
  /// This method initializes the MediaPipe GenAI inference engine with the provided
  /// model file and configuration parameters. The model must be in MediaPipe Task
  /// format (.task file).
  ///
  /// Parameters:
  /// - [modelPath]: Path to the MediaPipe Task model file (required)
  /// - [maxTokens]: Maximum number of tokens the model can generate. Default: 1024
  /// - [supportedLoraRanks]: Optional LoRA adapter ranks. Default: null
  /// - [preferredBackend]: Hardware acceleration preference (Android only). Default: null
  /// - [maxNumImages]: Maximum number of images for multi-modal input. Default: null
  ///
  /// Throws an exception if the model file cannot be loaded or is incompatible.
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.createModel(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 1024,
  ///   preferredBackend: PreferredBackend.gpu,
  /// );
  /// ```
  Future<void> createModel({
    required String modelPath,
    int? maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
  }) {
    final config = ModelConfig(
      modelPath: modelPath,
      maxTokens: maxTokens,
      supportedLoraRanks: supportedLoraRanks,
      preferredBackend: preferredBackend,
      maxNumImages: maxNumImages,
    );
    return AiEdgeRagPlatform.instance.createModel(config.toMap());
  }

  /// Creates a new inference session with the specified configuration.
  ///
  /// A session manages the conversation context and generation parameters.
  /// Multiple sessions can be created sequentially, but only one session
  /// is active at a time.
  ///
  /// Parameters (all optional with defaults):
  /// - [temperature]: Controls randomness (0.0-1.0). Default: 0.8
  /// - [randomSeed]: For reproducible outputs. Default: 1
  /// - [topK]: Top-K sampling parameter. Default: 40
  /// - [topP]: Top-P nucleus sampling. Default: null
  /// - [loraPath]: Path to LoRA adapter. Default: null
  /// - [enableVisionModality]: Enable vision features. Default: null
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.createSession(
  ///   temperature: 0.7,
  ///   topK: 40,
  ///   topP: 0.95,
  /// );
  /// ```
  Future<void> createSession({
    double? temperature,
    int? randomSeed,
    int? topK,
    double? topP,
    String? loraPath,
    bool? enableVisionModality,
  }) {
    final config = SessionConfig(
      temperature: temperature,
      randomSeed: randomSeed,
      topK: topK,
      topP: topP,
      loraPath: loraPath,
      enableVisionModality: enableVisionModality,
    );
    return AiEdgeRagPlatform.instance.createSession(config.toMap());
  }

  /// Convenience method to initialize both model and session in a single call.
  ///
  /// This method combines [createModel] and [createSession] for simplified setup.
  /// It's the recommended way to initialize the AI Edge RAG plugin for most use cases.
  ///
  /// Parameters:
  /// - [modelPath]: Path to the MediaPipe Task model file (required)
  /// - [maxTokens]: Maximum number of tokens the model can generate. Default: 1024
  /// - [supportedLoraRanks]: Optional LoRA adapter ranks for model customization
  /// - [preferredBackend]: Hardware acceleration preference (CPU/GPU) - Android only, ignored on iOS
  /// - [maxNumImages]: Maximum number of images supported in multi-modal input
  /// - [temperature]: Session temperature for randomness. Default: 0.8
  /// - [randomSeed]: Session random seed. Default: 1
  /// - [topK]: Session top-K sampling. Default: 40
  /// - [topP]: Session top-P nucleus sampling. Default: null
  /// - [loraPath]: Session LoRA adapter path. Default: null
  /// - [enableVisionModality]: Enable vision features. Default: null
  ///
  /// Returns a [Future] that completes when both model and session are ready.
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.initialize(
  ///   modelPath: '/path/to/model.task',
  ///   maxTokens: 512,
  ///   preferredBackend: PreferredBackend.gpu,
  ///   temperature: 0.8,
  ///   topK: 50,
  /// );
  /// ```
  Future<void> initialize({
    required String modelPath,
    int? maxTokens,
    List<int>? supportedLoraRanks,
    PreferredBackend? preferredBackend,
    int? maxNumImages,
    double? temperature,
    int? randomSeed,
    int? topK,
    double? topP,
    String? loraPath,
    bool? enableVisionModality,
  }) async {
    // Create model
    await createModel(
      modelPath: modelPath,
      maxTokens: maxTokens,
      supportedLoraRanks: supportedLoraRanks,
      preferredBackend: preferredBackend,
      maxNumImages: maxNumImages,
    );

    // Create session with provided parameters
    await createSession(
      temperature: temperature,
      randomSeed: randomSeed,
      topK: topK,
      topP: topP,
      loraPath: loraPath,
      enableVisionModality: enableVisionModality,
    );
  }

  /// Creates and initializes a local embedding model for RAG operations.
  ///
  /// This method sets up an on-device embedding model that converts text into
  /// vector representations for similarity search. The embeddings are used to
  /// retrieve relevant context from the vector store.
  ///
  /// Parameters:
  /// - [tokenizerModelPath]: Path to the tokenizer model file (required)
  /// - [embeddingModelPath]: Path to the embedding model file (required)
  /// - [modelType]: Type of embedding model (gemma or gecko). Default: gemma
  /// - [vectorStore]: Vector store type for storing embeddings. Default: inMemory
  /// - [preferredBackend]: Hardware acceleration preference (CPU or GPU). Default: CPU
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.createEmbeddingModel(
  ///   tokenizerModelPath: '/path/to/tokenizer.model',
  ///   embeddingModelPath: '/path/to/embedding.bin',
  ///   modelType: EmbeddingModelType.gemma,
  ///   vectorStore: VectorStore.sqlite,
  ///   preferredBackend: PreferredBackend.gpu,
  /// );
  /// ```
  Future<void> createEmbeddingModel({
    required String tokenizerModelPath,
    required String embeddingModelPath,
    EmbeddingModelType? modelType,
    VectorStore? vectorStore,
    PreferredBackend? preferredBackend,
  }) {
    final config = EmbeddingModelConfig(
      tokenizerModelPath: tokenizerModelPath,
      embeddingModelPath: embeddingModelPath,
      modelType: modelType,
      vectorStore: vectorStore,
      preferredBackend: preferredBackend,
    );
    return AiEdgeRagPlatform.instance.createEmbeddingModel(config.toMap());
  }

  /// Creates and initializes a Gemini-based embedder for RAG operations.
  ///
  /// This method sets up an embedder that uses Google's Gemini API to generate
  /// embeddings. Unlike local embedding models, this approach leverages cloud-based
  /// models for potentially higher quality embeddings.
  ///
  /// Parameters:
  /// - [geminiEmbeddingModel]: Name of the Gemini embedding model (e.g., 'models/text-embedding-004')
  /// - [geminiApiKey]: Your Gemini API key for authentication (required)
  /// - [vectorStore]: Vector store type for storing embeddings. Default: inMemory
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.createGeminiEmbedder(
  ///   geminiEmbeddingModel: 'models/text-embedding-004',
  ///   geminiApiKey: 'your-api-key-here',
  ///   vectorStore: VectorStore.sqlite,
  /// );
  /// ```
  Future<void> createGeminiEmbedder({
    required String geminiEmbeddingModel,
    required String geminiApiKey,
    VectorStore? vectorStore,
  }) {
    final config = GeminiEmbedderConfig(
      geminiEmbeddingModel: geminiEmbeddingModel,
      geminiApiKey: geminiApiKey,
      vectorStore: vectorStore,
    );
    return AiEdgeRagPlatform.instance.createGeminiEmbedder(config.toMap());
  }

  /// Stores a single text chunk in the vector store for retrieval.
  ///
  /// This method processes and stores a single piece of text by converting it
  /// into an embedding and storing it in the configured vector store. The chunk
  /// can later be retrieved based on similarity to a query.
  ///
  /// Parameters:
  /// - [chunk]: The text chunk to store in the vector database
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.memorizeChunk(
  ///   'Flutter is an open-source UI framework by Google.',
  /// );
  /// ```
  Future<void> memorizeChunk(String chunk) {
    return AiEdgeRagPlatform.instance.memorizeChunk({'chunk': chunk});
  }

  /// Stores multiple text chunks in the vector store for retrieval.
  ///
  /// This method processes and stores multiple pieces of text by converting them
  /// into embeddings and storing them in the configured vector store. This is more
  /// efficient than calling [memorizeChunk] multiple times.
  ///
  /// Parameters:
  /// - [chunks]: A list of text chunks to store in the vector database
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.memorizeChunks([
  ///   'Flutter is an open-source UI framework by Google.',
  ///   'Dart is the programming language used by Flutter.',
  ///   'Flutter supports cross-platform development.',
  /// ]);
  /// ```
  Future<void> memorizeChunks(List<String> chunks) {
    return AiEdgeRagPlatform.instance.memorizeChunks({'chunks': chunks});
  }

  /// Automatically chunks and stores a large text document in the vector store.
  ///
  /// This method automatically splits a large text into smaller chunks of the
  /// specified size, optionally with overlap between chunks, and stores them in
  /// the vector store. This is useful for processing documents, articles, or
  /// other long-form content.
  ///
  /// Parameters:
  /// - [text]: The text document to chunk and store
  /// - [chunkSize]: Maximum size of each chunk in characters. Default: 512
  /// - [chunkOverlap]: Optional overlap between consecutive chunks for better context continuity
  ///
  /// Example:
  /// ```dart
  /// final longDocument = '''
  ///   Flutter is Google's UI toolkit for building beautiful, natively compiled
  ///   applications for mobile, web, and desktop from a single codebase...
  /// ''';
  ///
  /// await AiEdgeRag.instance.memorizeChunkedText(
  ///   longDocument,
  ///   chunkSize: 512,
  ///   chunkOverlap: 50,
  /// );
  /// ```
  Future<void> memorizeChunkedText(
    String text, {
    int chunkSize = 512,
    int? chunkOverlap,
  }) {
    final map = <String, dynamic>{'text': text, 'chunkSize': chunkSize};
    if (chunkOverlap != null) {
      map['chunkOverlap'] = chunkOverlap;
    }
    return AiEdgeRagPlatform.instance.memorizeChunkedText(map);
  }

  /// Sets the system instruction for RAG-based generation.
  ///
  /// System instructions guide how the model should use retrieved context when
  /// generating responses. This is particularly important in RAG applications
  /// where you want to control how the model interprets and incorporates
  /// information from the vector store.
  ///
  /// Parameters:
  /// - [systemInstruction]: The system-level instruction to set
  ///
  /// Example:
  /// ```dart
  /// await AiEdgeRag.instance.setSystemInstruction(
  ///   SystemInstruction(
  ///     instruction: 'Use the provided context to answer questions accurately. '
  ///                 'If the answer is not in the context, say so explicitly.',
  ///   ),
  /// );
  /// ```
  Future<void> setSystemInstruction(SystemInstruction systemInstruction) {
    return AiEdgeRagPlatform.instance.setSystemInstruction({
      'systemInstruction': systemInstruction.instruction,
    });
  }

  /// Generates a text response asynchronously with RAG (Retrieval Augmented Generation) support.
  ///
  /// This method retrieves relevant context from the vector store based on the prompt,
  /// then generates a response using the retrieved context. The response is streamed
  /// as [GenerationEvent] objects, enabling real-time display of results.
  ///
  /// Parameters:
  /// - [prompt]: The user's question or prompt (required)
  /// - [topK]: Number of top similar chunks to retrieve from the vector store. Default: 3
  /// - [minSimilarityScore]: Minimum similarity score threshold for retrieved chunks. Default: 0
  ///
  /// Returns a [Stream] of [GenerationEvent] objects containing:
  /// - `partialResult`: The accumulated text generated so far (not incremental)
  /// - `done`: Boolean flag indicating if generation is complete
  ///
  /// Note: Each event's `partialResult` contains the full text generated up to
  /// that point, not just the new tokens. You can directly use `partialResult`
  /// to display the current state without manual accumulation.
  ///
  /// The stream automatically manages the underlying platform event channel
  /// and closes when generation completes or an error occurs.
  ///
  /// Example:
  /// ```dart
  /// final stream = AiEdgeRag.instance.generateResponseAsync(
  ///   'What is Flutter?',
  ///   topK: 5,
  ///   minSimilarityScore: 0.3,
  /// );
  ///
  /// await for (final event in stream) {
  ///   // partialResult contains the full text so far, not just new tokens
  ///   print('Current text: ${event.partialResult}');
  ///
  ///   if (event.done) {
  ///     print('Generation completed!');
  ///     print('Final response: ${event.partialResult}');
  ///   }
  /// }
  /// ```
  Stream<GenerationEvent> generateResponseAsync(
    String prompt, {
    int? topK,
    double? minSimilarityScore,
  }) {
    // First get the stream (which sets up the event listener)
    final controller = StreamController<GenerationEvent>.broadcast(sync: true)
      ..onListen = () {
        final map = <String, dynamic>{
          'prompt': prompt,
          'topK': topK ?? 3,
          'minSimilarityScore': minSimilarityScore ?? 0,
        };
        // When the stream is listened to, we can start the async generation
        AiEdgeRagPlatform.instance.generateResponseAsync(map);
      };

    final stream = AiEdgeRagPlatform.instance.getPartialResultStream();
    controller.addStream(stream).then((_) {
      // If the stream completes, we can close the controller
      if (!controller.isClosed) {
        controller.close();
      }
    });

    return controller.stream;
  }

  /// Releases all resources associated with the model and session.
  ///
  /// This method should be called when the AI Edge RAG functionality is no longer needed,
  /// typically in the widget's dispose method or when switching between different models.
  /// It ensures proper cleanup of native resources and memory.
  ///
  /// After calling [close], you must call [initialize] or [createModel]/[createSession]
  /// again before using any other methods.
  ///
  /// Note: This method silently ignores platform exceptions that may occur during
  /// cleanup, as the native implementation logs warnings but doesn't throw errors.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   AiEdgeRag.instance.close();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> close() async {
    try {
      await AiEdgeRagPlatform.instance.close();
    } on PlatformException {
      // Ignore errors when closing, as per Android implementation
      // which logs warnings but doesn't throw
    }
  }
}
