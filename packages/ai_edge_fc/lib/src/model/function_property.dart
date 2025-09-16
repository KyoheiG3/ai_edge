import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

/// Defines a single parameter property for a function declaration.
///
/// Each property represents a parameter that can be passed to a function,
/// including its name, type, description, and whether it's required.
///
/// Example:
/// ```dart
/// final locationParam = FunctionProperty(
///   name: 'location',
///   type: pb.Type.STRING,
///   description: 'The city name to get weather for',
///   required: true,
/// );
/// ```
final class FunctionProperty {
  /// The parameter name.
  ///
  /// This name is used as the key when passing arguments to the function.
  final String name;
  
  /// The data type of this parameter.
  ///
  /// Defaults to [pb.Type.STRING]. Other common types include
  /// [pb.Type.NUMBER], [pb.Type.BOOLEAN], [pb.Type.OBJECT], and [pb.Type.ARRAY].
  final pb.Type type;
  
  /// A description of what this parameter is for.
  ///
  /// This helps the model understand how to use the parameter correctly.
  final String description;
  
  /// Whether this parameter is required or optional.
  ///
  /// Defaults to false (optional). Required parameters must be provided
  /// when the function is called.
  final bool required;

  /// Creates a new [FunctionProperty].
  ///
  /// The [name] and [description] are required. The [type] defaults to
  /// STRING and [required] defaults to false.
  const FunctionProperty({
    required this.name,
    this.type = pb.Type.STRING,
    required this.description,
    this.required = false,
  });

  /// Converts this property to a Protocol Buffer map entry.
  ///
  /// Returns a map entry with the property name as key and its schema
  /// as value, suitable for inclusion in a function declaration.
  MapEntry<String, pb.Schema> build() {
    return MapEntry(name, pb.Schema(type: type, description: description));
  }
}
