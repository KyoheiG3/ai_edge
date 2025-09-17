import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

/// Simplified type enum for function properties.
///
/// This enum provides a more user-friendly way to specify property types
/// without needing to import protocol buffer definitions.
///
/// Example:
/// ```dart
/// FunctionProperty(
///   name: 'count',
///   type: PropertyType.number,
///   description: 'Number of items',
/// )
/// ```
enum PropertyType {
  /// String type for text values.
  string(pb.Type.STRING),

  /// Number type for floating-point numeric values.
  number(pb.Type.NUMBER),

  /// Integer type for whole number values.
  integer(pb.Type.INTEGER),

  /// Boolean type for true/false values.
  boolean(pb.Type.BOOLEAN),

  /// Object type for complex structures.
  object(pb.Type.OBJECT),

  /// Array type for lists of values.
  array(pb.Type.ARRAY);

  /// The underlying Protocol Buffer type.
  final pb.Type pbType;

  /// Creates a PropertyType with its corresponding Protocol Buffer type.
  const PropertyType(this.pbType);
}

/// Defines a single parameter property for a function declaration.
///
/// Each property represents a parameter that can be passed to a function,
/// including its name, type, description, and whether it's required.
///
/// Example:
/// ```dart
/// final locationParam = FunctionProperty(
///   name: 'location',
///   type: PropertyType.string,
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
  /// Defaults to [PropertyType.string].
  final PropertyType type;

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
  /// [PropertyType.string] and [required] defaults to false.
  ///
  /// Example:
  /// ```dart
  /// FunctionProperty(
  ///   name: 'count',
  ///   type: PropertyType.number,
  ///   description: 'Number of items',
  ///   required: true,
  /// )
  /// ```
  const FunctionProperty({
    required this.name,
    this.type = PropertyType.string,
    required this.description,
    this.required = false,
  });

  /// Converts this property to a Protocol Buffer map entry.
  ///
  /// Returns a map entry with the property name as key and its schema
  /// as value, suitable for inclusion in a function declaration.
  MapEntry<String, pb.Schema> build() {
    return MapEntry(
      name,
      pb.Schema(type: type.pbType, description: description),
    );
  }
}
