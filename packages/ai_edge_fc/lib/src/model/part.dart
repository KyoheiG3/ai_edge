import 'package:ai_edge_fc/src/model/function_call.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

/// Represents a part of content that can contain either text or a function call.
/// 
/// A [Part] is a fundamental building block of AI conversation content.
/// It can contain either plain text content or a function call request.
/// This allows for mixed content types within a single message or response,
/// enabling both conversational text and structured function calls.
/// 
/// Example usage:
/// ```dart
/// // Text part
/// final textPart = Part(text: 'Hello, how can I help you?');
/// 
/// // Function call part
/// final functionPart = Part(functionCall: FunctionCall(
///   name: 'get_weather',
///   args: Struct(fields: {'location': 'New York'})
/// ));
/// 
/// // Convert to protobuf
/// final protoPart = textPart.build();
/// ```
final class Part {
  /// The text content of this part.
  /// 
  /// Contains plain text content when this part represents textual information.
  /// This will be null if the part contains a function call instead.
  final String? text;

  /// The function call content of this part.
  /// 
  /// Contains a structured function call when this part represents a request
  /// to execute a specific function with given arguments.
  /// This will be null if the part contains text instead.
  final FunctionCall? functionCall;

  /// Creates a new [Part] with either text or function call content.
  /// 
  /// [text] - The text content for this part (optional).
  /// [functionCall] - The function call content for this part (optional).
  /// 
  /// Note: Typically only one of [text] or [functionCall] should be provided,
  /// though both being null or both being provided are technically allowed.
  const Part({this.text, this.functionCall});

  /// Creates a [Part] from a protobuf message.
  /// 
  /// [proto] - The protobuf representation of the part.
  /// Returns a new [Part] instance with the appropriate content type.
  factory Part.fromProto(pb.Part proto) {
    return Part(
      text: proto.hasText() ? proto.text : null,
      functionCall: proto.hasFunctionCall()
          ? FunctionCall.fromProto(proto.functionCall)
          : null,
    );
  }

  /// Builds and returns the protobuf representation of this part.
  /// 
  /// Converts this [Part] into a [pb.Part] protobuf object that can be
  /// serialized and transmitted. The appropriate content type (text or
  /// function call) is included in the resulting protobuf.
  /// 
  /// Returns a [pb.Part] protobuf message.
  pb.Part build() {
    final call = functionCall;
    return pb.Part(
      text: text,
      functionCall: call != null
          ? pb.FunctionCall(name: call.name, args: call.args.build())
          : null,
    );
  }
}
