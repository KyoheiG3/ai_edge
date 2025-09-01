part of 'ai_edge.dart';

/// Preferred backend for model inference
enum PreferredBackend { unknown, cpu, gpu, gpuFloat16, gpuMixed, gpuFull, tpu }

/// Configuration for the inference model
class InferenceModelConfig {
  final String modelPath;
  final int maxTokens;
  final List<int>? supportedLoraRanks;
  final PreferredBackend? preferredBackend;
  final int? maxNumImages;

  InferenceModelConfig({
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
      map['preferredBackend'] = preferredBackend!.index;
    }
    if (maxNumImages != null) {
      map['maxNumImages'] = maxNumImages;
    }
    return map;
  }
}

/// Configuration for the inference session
class InferenceSessionConfig {
  final double temperature;
  final int randomSeed;
  final int topK;
  final double? topP;
  final String? loraPath;
  final bool? enableVisionModality;

  InferenceSessionConfig({
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
