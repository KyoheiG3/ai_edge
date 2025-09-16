import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

import 'function_property.dart';
import 'writable.dart';

/// Declares a function that the AI model can call.
///
/// This class defines the schema for a function including its name,
/// description, and parameters. The model uses this information to
/// understand when and how to call the function.
///
/// Example:
/// ```dart
/// final weatherFunction = FunctionDeclaration(
///   name: 'get_weather',
///   description: 'Get the current weather for a location',
///   properties: [
///     FunctionProperty(
///       name: 'location',
///       type: PropertyType.string,
///       description: 'The city name',
///       required: true,
///     ),
///     FunctionProperty(
///       name: 'unit',
///       type: PropertyType.string,
///       description: 'Temperature unit (celsius or fahrenheit)',
///       required: false,
///     ),
///   ],
/// );
/// ```
final class FunctionDeclaration with Writable {
  /// The unique name of the function.
  ///
  /// This name is used by the model when generating function calls.
  final String name;
  
  /// Optional human-readable description of what the function does.
  ///
  /// This helps the model understand when to use the function.
  final String? description;
  
  /// The list of parameters this function accepts.
  ///
  /// Each property defines a parameter including its type, description,
  /// and whether it's required.
  final List<FunctionProperty> properties;

  /// Creates a new [FunctionDeclaration].
  ///
  /// The [name] must be unique among all declared functions.
  /// The [description] helps the model understand the function's purpose.
  /// The [properties] define the function's parameter schema.
  const FunctionDeclaration({
    required this.name,
    this.description,
    required this.properties,
  });

  /// Converts this instance to a Protocol Buffer message.
  ///
  /// Builds the complete function schema including parameters and their
  /// requirements for transmission to the native platform.
  @override
  pb.FunctionDeclaration build() {
    final propertiesMap = <MapEntry<String, pb.Schema>>[];
    final requiredList = <String>[];

    for (final property in properties) {
      propertiesMap.add(property.build());

      if (property.required) {
        requiredList.add(property.name);
      }
    }

    return pb.FunctionDeclaration(
      name: name,
      description: description,
      parameters: pb.Schema(
        type: pb.Type.OBJECT,
        properties: propertiesMap,
        required: requiredList,
      ),
    );
  }
}
