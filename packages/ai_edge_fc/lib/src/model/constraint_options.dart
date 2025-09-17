import 'package:ai_edge_fc/src/model/writable.dart';
import 'package:ai_edge_fc/src/proto/local_agents/function_calling/core/proto/constraint_options.pb.dart'
    as pb;

/// Represents constraint options for controlling AI model output generation.
///
/// This class allows specification of constraints that guide the model's response
/// format, including tool-only calls, text conditions, or stop phrases.
/// Only one constraint type can be active at a time.
///
/// Example:
/// ```dart
/// final constraints = ConstraintOptions(
///   toolCallOnly: ToolCallOnly(
///     constraintPrefix: 'Function:',
///     constraintSuffix: '\n',
///   ),
/// );
/// ```
final class ConstraintOptions with Writable {
  /// Constraint for forcing tool-only responses from the model.
  final ToolCallOnly? toolCallOnly;

  /// Constraint for text generation with AND/OR stop conditions.
  final TextAndOr? textAndOr;

  /// Constraint for text generation until a specific stop phrase is encountered.
  final TextUntil? textUntil;

  /// Creates a new [ConstraintOptions] instance.
  ///
  /// Only one of [toolCallOnly], [textAndOr], or [textUntil] should be provided.
  /// If multiple are provided, behavior is undefined.
  const ConstraintOptions({this.toolCallOnly, this.textAndOr, this.textUntil});

  /// Creates a [ConstraintOptions] instance from a Protocol Buffer message.
  ///
  /// This factory constructor deserializes the protobuf representation into
  /// the corresponding Dart object model.
  factory ConstraintOptions.fromProto(pb.ConstraintOptions proto) {
    return ConstraintOptions(
      toolCallOnly: proto.hasToolCallOnly()
          ? ToolCallOnly.fromProto(proto.toolCallOnly)
          : null,
      textAndOr: proto.hasTextAndOr()
          ? TextAndOr.fromProto(proto.textAndOr)
          : null,
      textUntil: proto.hasTextUntil()
          ? TextUntil.fromProto(proto.textUntil)
          : null,
    );
  }

  /// Converts this instance to a Protocol Buffer message.
  ///
  /// Returns a protobuf representation suitable for serialization and
  /// transmission to the native platform.
  @override
  pb.ConstraintOptions build() {
    return pb.ConstraintOptions(
      toolCallOnly: toolCallOnly?.build(),
      textAndOr: textAndOr?.build(),
      textUntil: textUntil?.build(),
    );
  }
}

/// Constraint that forces the model to only generate tool/function calls.
///
/// When this constraint is active, the model will not generate regular text
/// responses and will only output function calls with optional prefix/suffix.
///
/// Example:
/// ```dart
/// final toolOnly = ToolCallOnly(
///   constraintPrefix: 'Calling function: ',
///   constraintSuffix: '\n---\n',
/// );
/// ```
final class ToolCallOnly {
  /// Optional prefix text to add before tool call output.
  final String? constraintPrefix;

  /// Optional suffix text to add after tool call output.
  final String? constraintSuffix;

  /// Creates a new [ToolCallOnly] constraint.
  ///
  /// Both [constraintPrefix] and [constraintSuffix] are optional and can be
  /// used to format the tool call output.
  const ToolCallOnly({this.constraintPrefix, this.constraintSuffix});

  /// Creates a [ToolCallOnly] instance from a Protocol Buffer message.
  factory ToolCallOnly.fromProto(pb.ConstraintOptions_ToolCallOnly proto) {
    return ToolCallOnly(
      constraintPrefix: proto.constraintPrefix,
      constraintSuffix: proto.constraintSuffix,
    );
  }

  /// Converts this instance to a Protocol Buffer message.
  pb.ConstraintOptions_ToolCallOnly build() {
    return pb.ConstraintOptions_ToolCallOnly(
      constraintPrefix: constraintPrefix,
      constraintSuffix: constraintSuffix,
    );
  }
}

/// Constraint for text generation with combined AND/OR stop conditions.
///
/// This constraint allows specifying stop phrases that can terminate
/// text generation, with optional prefix and suffix formatting.
///
/// Example:
/// ```dart
/// final textConstraint = TextAndOr(
///   stopPhrasePrefix: 'END:',
///   stopPhraseSuffix: '\n',
///   constraintSuffix: '\n---\n',
/// );
/// ```
final class TextAndOr {
  /// Prefix to match before the stop phrase.
  final String? stopPhrasePrefix;

  /// Suffix to match after the stop phrase.
  final String? stopPhraseSuffix;

  /// Optional suffix to add after constraint is applied.
  final String? constraintSuffix;

  /// Creates a new [TextAndOr] constraint.
  ///
  /// All parameters are optional and control different aspects of the
  /// stop condition and output formatting.
  const TextAndOr({
    this.stopPhrasePrefix,
    this.stopPhraseSuffix,
    this.constraintSuffix,
  });

  /// Creates a [TextAndOr] instance from a Protocol Buffer message.
  factory TextAndOr.fromProto(pb.ConstraintOptions_TextAndOr proto) {
    return TextAndOr(
      stopPhrasePrefix: proto.stopPhrasePrefix,
      stopPhraseSuffix: proto.stopPhraseSuffix,
      constraintSuffix: proto.constraintSuffix,
    );
  }

  /// Converts this instance to a Protocol Buffer message.
  pb.ConstraintOptions_TextAndOr build() {
    return pb.ConstraintOptions_TextAndOr(
      stopPhrasePrefix: stopPhrasePrefix,
      stopPhraseSuffix: stopPhraseSuffix,
      constraintSuffix: constraintSuffix,
    );
  }
}

/// Constraint for text generation until a specific stop phrase is encountered.
///
/// This constraint causes the model to generate text until it produces
/// the specified stop phrase, at which point generation terminates.
///
/// Example:
/// ```dart
/// final untilConstraint = TextUntil(
///   stopPhrase: 'END_OF_RESPONSE',
///   constraintSuffix: '\n',
/// );
/// ```
final class TextUntil {
  /// The phrase that terminates text generation when encountered.
  final String? stopPhrase;

  /// Optional suffix to add after the constraint is applied.
  final String? constraintSuffix;

  /// Creates a new [TextUntil] constraint.
  ///
  /// The [stopPhrase] defines when to stop generating text, and
  /// [constraintSuffix] can be used to format the output.
  const TextUntil({this.stopPhrase, this.constraintSuffix});

  /// Creates a [TextUntil] instance from a Protocol Buffer message.
  factory TextUntil.fromProto(pb.ConstraintOptions_TextUntil proto) {
    return TextUntil(
      stopPhrase: proto.stopPhrase,
      constraintSuffix: proto.constraintSuffix,
    );
  }

  /// Converts this instance to a Protocol Buffer message.
  pb.ConstraintOptions_TextUntil build() {
    return pb.ConstraintOptions_TextUntil(
      stopPhrase: stopPhrase,
      constraintSuffix: constraintSuffix,
    );
  }
}
