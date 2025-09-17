/// Specifies the model formatter for function calling.
///
/// Different language models require different formatters to properly
/// handle function calling. Choose the formatter that matches your model type.
enum ModelFormatter {
  /// Formatter for Gemma models.
  ///
  /// Use this for Gemma-based models (e.g., gemma-2b, gemma-7b).
  gemma('GEMMA'),

  /// Formatter for models using Hammer format.
  ///
  /// Use this for models that require Hammer-style formatting.
  hammer('HAMMER'),

  /// Formatter for Llama models.
  ///
  /// Use this for Llama-based models (e.g., llama2, llama3).
  llama('LLAMA');

  /// The string value used for native platform communication.
  final String value;

  const ModelFormatter(this.value);
}