import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart';

import 'message.dart';
import 'writable.dart';

/// Represents a system instruction that provides context or guidelines to an AI model.
///
/// A [SystemInstruction] is a special type of message that sets the behavior,
/// personality, or operational guidelines for an AI model. Unlike regular user
/// messages, system instructions are typically used to establish the context
/// and constraints within which the AI should operate.
///
/// This class implements the [Writable] mixin to support serialization to
/// protobuf format for communication with AI models.
///
/// Example usage:
/// ```dart
/// final instruction = SystemInstruction(
///   instruction: 'You are a helpful assistant that provides concise answers.'
/// );
///
/// // Custom role system instruction
/// final customInstruction = SystemInstruction(
///   role: 'moderator',
///   instruction: 'Monitor conversation for inappropriate content.'
/// );
///
/// final buffer = instruction.writeToBuffer();
/// ```
final class SystemInstruction with Writable {
  /// The role identifier for this system instruction.
  ///
  /// Defaults to 'system' but can be customized for specific use cases
  /// where different types of system-level instructions are needed.
  final String role;

  /// The actual instruction text that guides the AI model's behavior.
  ///
  /// This contains the directives, context, or guidelines that should
  /// influence how the AI model responds and behaves during the conversation.
  final String instruction;

  /// Creates a new [SystemInstruction] with the given instruction text.
  ///
  /// [role] - The role identifier for this instruction (defaults to 'system').
  /// [instruction] - The instruction text that guides the AI model's behavior.
  const SystemInstruction({this.role = 'system', required this.instruction});

  /// Builds and returns the protobuf representation of this system instruction.
  ///
  /// This method converts the system instruction into a [Content] protobuf object
  /// by wrapping it as a [Message]. The instruction is treated as message content
  /// with the specified role.
  ///
  /// Returns a [Content] protobuf message.
  @override
  Content build() {
    return Message(role: role, text: instruction).build();
  }
}
