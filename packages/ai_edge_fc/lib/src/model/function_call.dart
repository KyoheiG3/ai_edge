import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

import 'struct.dart';

/// Represents a function call request from the AI model.
///
/// When the model decides to use a tool/function, it generates a FunctionCall
/// containing the function name and its arguments. The application should
/// execute the function and return the result via a FunctionResponse.
///
/// Example:
/// ```dart
/// final call = FunctionCall(
///   name: 'get_weather',
///   args: Struct.fromMap({
///     'location': 'Tokyo',
///     'unit': 'celsius',
///   }),
/// );
/// ```
final class FunctionCall {
  /// The name of the function to be called.
  ///
  /// This should match one of the function names declared in the tools
  /// provided to the model.
  final String name;

  /// The arguments to pass to the function.
  ///
  /// Arguments are represented as a [Struct] which can contain nested
  /// values including strings, numbers, booleans, lists, and maps.
  final Struct args;

  /// Creates a new [FunctionCall] instance.
  ///
  /// Both [name] and [args] are required. The [name] should match a declared
  /// function, and [args] should conform to the function's parameter schema.
  const FunctionCall({required this.name, required this.args});

  /// Creates a [FunctionCall] instance from a Protocol Buffer message.
  ///
  /// Deserializes the protobuf representation including the function name
  /// and its arguments structure.
  factory FunctionCall.fromProto(pb.FunctionCall proto) {
    return FunctionCall(name: proto.name, args: Struct.fromProto(proto.args));
  }
}
