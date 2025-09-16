import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

import 'function_call.dart';
import 'struct.dart';
import 'writable.dart';

/// Represents a response from a function call.
///
/// After the application executes a function requested by the model via
/// [FunctionCall], it should create a [FunctionResponse] with the result
/// and send it back to continue the conversation.
///
/// Example:
/// ```dart
/// final response = FunctionResponse(
///   role: 'function',
///   functionCall: previousFunctionCall,
///   response: {
///     'temperature': 25,
///     'condition': 'sunny',
///     'humidity': 60,
///   },
/// );
/// ```
final class FunctionResponse with Writable {
  /// Optional role identifier for the response.
  ///
  /// Typically set to 'function' to indicate this is a function response.
  final String? role;
  
  /// The original function call that this is responding to.
  ///
  /// This links the response back to the specific function invocation.
  final FunctionCall functionCall;
  
  /// The actual response data from the function execution.
  ///
  /// This map contains the result of the function call, which can include
  /// any JSON-serializable data structure.
  final Map<String, dynamic> response;

  /// Creates a new [FunctionResponse].
  ///
  /// The [functionCall] parameter should be the original call from the model,
  /// and [response] should contain the execution result.
  const FunctionResponse({
    this.role,
    required this.functionCall,
    required this.response,
  });

  /// Converts this instance to a Protocol Buffer Content message.
  ///
  /// Wraps the function response in a Content message with the appropriate
  /// part structure for transmission back to the model.
  @override
  pb.Content build() {
    return pb.Content(
      role: role,
      parts: [
        pb.Part(
          functionResponse: pb.FunctionResponse(
            name: functionCall.name,
            response: Struct(fields: response).build(),
          ),
        ),
      ],
    );
  }
}
