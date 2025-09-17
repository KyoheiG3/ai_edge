import 'dart:typed_data';

import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

import 'part.dart';

/// Represents content in a conversation, including the role and message parts.
///
/// Content is the fundamental unit of conversation in the AI model, containing
/// both the role (e.g., 'user', 'model') and the actual message parts which
/// can include text, function calls, or function responses.
///
/// Example:
/// ```dart
/// final content = Content(
///   role: 'user',
///   parts: [TextPart('Hello, how are you?')],
/// );
/// ```
final class Content {
  /// The role of the content creator ('user', 'model', 'system', etc.).
  final String role;

  /// The list of message parts that make up this content.
  ///
  /// Parts can include text, function calls, function responses, or other
  /// content types supported by the model.
  final List<Part> parts;

  /// Creates a new [Content] instance.
  ///
  /// The [role] parameter identifies who created this content, and [parts]
  /// contains the actual message content.
  const Content({required this.role, required this.parts});

  /// Creates a [Content] instance from a binary Protocol Buffer.
  ///
  /// This factory deserializes a binary protobuf message into a Content object.
  /// Useful when receiving content from native platform channels.
  factory Content.fromBuffer(Uint8List buffer) {
    return Content.fromProto(pb.Content.fromBuffer(buffer));
  }

  /// Creates a [Content] instance from a Protocol Buffer message.
  ///
  /// Converts the protobuf representation to the Dart object model,
  /// including all nested parts.
  factory Content.fromProto(pb.Content proto) {
    return Content(
      role: proto.role,
      parts: proto.parts.map(Part.fromProto).toList(),
    );
  }

  /// Converts this instance to a Protocol Buffer message.
  ///
  /// Returns a protobuf representation suitable for serialization and
  /// transmission to the native platform.
  pb.Content build() {
    return pb.Content(
      role: role,
      parts: parts.map((part) => part.build()).toList(),
    );
  }
}
