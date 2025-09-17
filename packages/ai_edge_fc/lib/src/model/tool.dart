import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

import 'function_declaration.dart';
import 'writable.dart';

/// Represents a collection of function declarations that can be used by an AI model.
///
/// A [Tool] groups related function declarations together, providing a way to
/// organize and present available functions to an AI model for function calling.
/// This enables the AI to understand what functions are available and how to
/// call them with appropriate parameters.
///
/// This class implements the [Writable] mixin to support serialization to
/// protobuf format for communication with AI models.
///
/// Example usage:
/// ```dart
/// final weatherFunction = FunctionDeclaration(
///   name: 'get_weather',
///   description: 'Get current weather for a location',
///   // ... other parameters
/// );
///
/// final timeFunction = FunctionDeclaration(
///   name: 'get_time',
///   description: 'Get current time',
///   // ... other parameters
/// );
///
/// final utilityTool = Tool(functionDeclarations: [
///   weatherFunction,
///   timeFunction,
/// ]);
///
/// final buffer = utilityTool.writeToBuffer();
/// ```
final class Tool with Writable {
  /// The list of function declarations contained in this tool.
  ///
  /// Each function declaration defines a function that the AI model can call,
  /// including its name, description, parameters, and expected behavior.
  /// Multiple related functions can be grouped together in a single tool.
  final List<FunctionDeclaration> functionDeclarations;

  /// Creates a new [Tool] with the given function declarations.
  ///
  /// [functionDeclarations] - The list of function declarations that this tool provides.
  /// At least one function declaration should be provided for the tool to be useful.
  const Tool({required this.functionDeclarations});

  /// Builds and returns the protobuf representation of this tool.
  ///
  /// This method converts the tool into a [pb.Tool] protobuf object that can be
  /// serialized and transmitted to an AI model. All function declarations are
  /// converted to their protobuf format.
  ///
  /// Returns a [pb.Tool] protobuf message containing all function declarations.
  @override
  pb.Tool build() {
    return pb.Tool(
      functionDeclarations: functionDeclarations
          .map((declaration) => declaration.build())
          .toList(),
    );
  }
}
