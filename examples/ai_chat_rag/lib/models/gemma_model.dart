class GemmaModel {
  final String id;
  final String name;
  final String description;
  final String downloadUrl;
  final String fileName;
  final double fileSizeGB;

  const GemmaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.downloadUrl,
    required this.fileName,
    required this.fileSizeGB,
  });

  static const String hfHost = 'https://huggingface.co';

  static final List<GemmaModel> availableModels = [
    GemmaModel(
      id: "gemma-3n-e1b",
      name: "Gemma 3n E1B-IT",
      description: "1B parameter model optimized for on-device inference",
      downloadUrl:
          "$hfHost/AfiOne/gemma3-1b-it-int4.task/resolve/main/gemma3-1b-it-int4.task",
      fileName: "gemma3-1b-it-int4.task",
      fileSizeGB: 0.55,
    ),
    GemmaModel(
      id: "gemma-3n-e4b",
      name: "Gemma 3n E4B-IT",
      description: "4B parameter model with enhanced capabilities",
      downloadUrl:
          "$hfHost/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task",
      fileName: "gemma-3n-E4B-it-int4.task",
      fileSizeGB: 4.41,
    ),
    GemmaModel(
      id: "gemma-3n-E4B-it-int4",
      name: "Gemma 3n E4B-IT",
      description: "4B parameter model with enhanced capabilities",
      downloadUrl:
          "$hfHost/google/gemma-3n-E4B-it-litert-lm/resolve/main/gemma-3n-E4B-it-int4.litertlm",
      fileName: "gemma-3n-E4B-it-int4.litertlm",
      fileSizeGB: 4.65,
    ),
    GemmaModel(
      id: "hammer2.1_1.5b_q8_ekv4096",
      name: "Hammer 2.1 1.5B",
      description: "1.5B parameter model with enhanced capabilities",
      downloadUrl:
          "$hfHost/litert-community/Hammer2.1-1.5b/resolve/main/hammer2.1_1.5b_q8_ekv4096.task",
      fileName: "hammer2.1_1.5b_q8_ekv4096.task",
      fileSizeGB: 1.63,
    ),
  ];
}
