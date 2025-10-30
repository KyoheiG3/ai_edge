class RagModel {
  final String id;
  final String name;
  final String description;
  final String downloadUrl;
  final String fileName;
  final double fileSizeMB;

  const RagModel({
    required this.id,
    required this.name,
    required this.description,
    required this.downloadUrl,
    required this.fileName,
    required this.fileSizeMB,
  });

  static const String hfHost = 'https://huggingface.co';

  // Tokenizer model
  static final RagModel tokenizerModel = RagModel(
    id: 'sentencepiece',
    name: 'SentencePiece Tokenizer',
    description: 'Tokenizer model for text processing',
    downloadUrl:
        '$hfHost/litert-community/embeddinggemma-300m/resolve/main/sentencepiece.model',
    fileName: 'sentencepiece.model',
    fileSizeMB: 4.0,
  );

  // Embedding model
  static final RagModel embeddingModel = RagModel(
    id: 'embedding-gemma',
    name: 'Embedding Gemma 300M',
    description: 'Embedding model for semantic search (300M parameters)',
    downloadUrl:
        '$hfHost/litert-community/embeddinggemma-300m/resolve/main/embeddinggemma-300M_seq256_mixed-precision.tflite',
    fileName: 'embeddinggemma-300M_seq256_mixed-precision.tflite',
    fileSizeMB: 315.0,
  );

  static final List<RagModel> requiredModels = [tokenizerModel, embeddingModel];
}
