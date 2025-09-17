import 'package:ai_edge_fc/src/model/content.dart';
import 'package:ai_edge_fc/src/model/part.dart';
import 'package:ai_edge_fc/src/model/writable.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

/// Represents a conversational message with a role and text content.
///
/// A message is a fundamental unit of communication in AI conversations,
/// containing both the role of the sender (such as 'user', 'assistant', or 'system')
/// and the text content of the message. This class implements the [Writable]
/// mixin to support serialization to protobuf format.
///
/// Example usage:
/// ```dart
/// final userMessage = Message(role: 'user', text: 'Hello, how are you?');
/// final assistantMessage = Message(role: 'assistant', text: 'I am doing well, thank you!');
/// final buffer = userMessage.writeToBuffer();
/// ```
final class Message with Writable {
  /// The role of the message sender.
  ///
  /// Common roles include:
  /// - 'user': Messages from the user/human
  /// - 'assistant': Messages from the AI assistant
  /// - 'system': System instructions or prompts
  final String role;

  /// The text content of the message.
  ///
  /// This contains the actual message content that will be processed
  /// or displayed in the conversation.
  final String text;

  /// Creates a new [Message] with the specified role and text.
  ///
  /// [role] - The role of the message sender (e.g., 'user', 'assistant', 'system').
  /// [text] - The text content of the message.
  const Message({required this.role, required this.text});

  /// Builds and returns the protobuf representation of this message.
  ///
  /// This method converts the message into a [pb.Content] protobuf object
  /// that can be serialized and transmitted. The text is wrapped in a [Part]
  /// and added to the content's parts list.
  ///
  /// Returns a [pb.Content] protobuf message.
  @override
  pb.Content build() {
    return Content(
      role: role,
      parts: [Part(text: text)],
    ).build();
  }
}
