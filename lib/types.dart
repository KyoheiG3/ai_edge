/// Preferred backend for model inference
enum PreferredBackend {
  unknown(0),
  cpu(1),
  gpu(2);

  final int value;
  const PreferredBackend(this.value);
}

/// Configuration for the inference model
class ModelConfig {
  final String modelPath;
  final int maxTokens;
  final List<int>? supportedLoraRanks;
  final PreferredBackend? preferredBackend;
  final int? maxNumImages;

  const ModelConfig({
    required this.modelPath,
    required this.maxTokens,
    this.supportedLoraRanks,
    this.preferredBackend,
    this.maxNumImages,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'modelPath': modelPath,
      'maxTokens': maxTokens,
    };
    if (supportedLoraRanks != null) {
      map['loraRanks'] = supportedLoraRanks;
    }
    if (preferredBackend != null) {
      map['preferredBackend'] = preferredBackend?.value;
    }
    if (maxNumImages != null) {
      map['maxNumImages'] = maxNumImages;
    }
    return map;
  }
}

/// Configuration for the inference session
class SessionConfig {
  final double temperature;
  final int randomSeed;
  final int topK;
  final double? topP;
  final String? loraPath;
  final bool? enableVisionModality;

  const SessionConfig({
    this.temperature = 0.8,
    this.randomSeed = 1,
    this.topK = 40,
    this.topP,
    this.loraPath,
    this.enableVisionModality,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'temperature': temperature,
      'randomSeed': randomSeed,
      'topK': topK,
    };
    if (topP != null) {
      map['topP'] = topP;
    }
    if (loraPath != null) {
      map['loraPath'] = loraPath;
    }
    if (enableVisionModality != null) {
      map['enableVisionModality'] = enableVisionModality;
    }
    return map;
  }
}

/// Response event from async generation
class GenerationEvent {
  final String partialResult;
  final bool done;

  const GenerationEvent({required this.partialResult, required this.done});

  factory GenerationEvent.fromMap(Map<String, dynamic> map) {
    return GenerationEvent(
      partialResult: map['partialResult'] as String? ?? '',
      done: map['done'] as bool? ?? false,
    );
  }
}
