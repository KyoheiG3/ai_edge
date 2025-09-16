import 'package:ai_edge_fc/src/proto/google/protobuf/struct.pb.dart' as pb;

/// Represents a structured data object that can contain various types of values.
/// 
/// A [Struct] is a flexible data structure similar to a JSON object that can
/// contain nested values of different types including primitives (strings, numbers,
/// booleans), lists, and other structs. This class provides conversion between
/// Dart's native data types and Protocol Buffer Struct format.
/// 
/// Supported value types:
/// - `null` values
/// - `bool` values  
/// - `num` values (converted to double)
/// - `String` values
/// - `List` values (with recursive conversion)
/// - `Map<String, dynamic>` values (nested structs)
/// 
/// Example usage:
/// ```dart
/// final struct = Struct(fields: {
///   'name': 'John Doe',
///   'age': 30,
///   'active': true,
///   'address': {
///     'street': '123 Main St',
///     'city': 'New York'
///   },
///   'hobbies': ['reading', 'swimming']
/// });
/// 
/// final protoStruct = struct.build();
/// final fromProto = Struct.fromProto(protoStruct);
/// ```
final class Struct {
  /// The fields contained in this struct as key-value pairs.
  /// 
  /// Keys are always strings, while values can be any supported type:
  /// null, bool, num, String, List, or `Map<String, dynamic>`.
  final Map<String, dynamic> fields;

  /// Creates a new [Struct] with the given fields.
  /// 
  /// [fields] - A map of field names to their values. Values must be
  /// of supported types (null, bool, num, String, List, or `Map<String, dynamic>`).
  const Struct({required this.fields});

  /// Creates a [Struct] from a protobuf message.
  /// 
  /// [proto] - The protobuf representation of the struct.
  /// Returns a new [Struct] instance with converted field values.
  factory Struct.fromProto(pb.Struct proto) {
    return Struct(fields: _convertStruct(proto));
  }

  /// Builds and returns the protobuf representation of this struct.
  /// 
  /// Converts this [Struct] into a [pb.Struct] protobuf object that can be
  /// serialized and transmitted. All field values are recursively converted
  /// to their appropriate protobuf representations.
  /// 
  /// Returns a [pb.Struct] protobuf message.
  /// 
  /// Throws [ArgumentError] if any field contains an unsupported value type.
  pb.Struct build() {
    return _buildStruct(fields);
  }

  /// Builds a protobuf struct from a map of fields.
  /// 
  /// [fields] - The map of fields to convert.
  /// Returns a [pb.Struct] with all values converted to protobuf format.
  pb.Struct _buildStruct(Map<String, dynamic> fields) {
    return pb.Struct(
      fields: fields.entries.map((e) => MapEntry(e.key, _buildValue(e.value))),
    );
  }

  /// Builds a protobuf value from a dynamic Dart value.
  /// 
  /// [value] - The Dart value to convert.
  /// Returns a [pb.Value] with the appropriate protobuf representation.
  /// 
  /// Throws [ArgumentError] if the value type is not supported.
  pb.Value _buildValue(dynamic value) {
    if (value == null) {
      return pb.Value(nullValue: pb.NullValue.NULL_VALUE);
    } else if (value is bool) {
      return pb.Value(boolValue: value);
    } else if (value is num) {
      return pb.Value(numberValue: value.toDouble());
    } else if (value is String) {
      return pb.Value(stringValue: value);
    } else if (value is List) {
      return pb.Value(
        listValue: pb.ListValue(values: value.map(_buildValue).toList()),
      );
    } else if (value is Map<String, dynamic>) {
      return pb.Value(structValue: _buildStruct(value));
    } else {
      throw ArgumentError('Unsupported value type: ${value.runtimeType}');
    }
  }

  /// Converts a protobuf struct to a Dart map.
  /// 
  /// [struct] - The protobuf struct to convert.
  /// Returns a map with all values converted to Dart types.
  static Map<String, dynamic> _convertStruct(pb.Struct struct) {
    return Map.fromEntries(
      struct.fields.entries.map((e) => MapEntry(e.key, _convertValue(e.value))),
    );
  }

  /// Converts a protobuf value to a Dart value.
  /// 
  /// [value] - The protobuf value to convert.
  /// Returns the appropriate Dart representation of the value.
  /// 
  /// Throws [ArgumentError] if the value type is unknown.
  static dynamic _convertValue(pb.Value value) {
    if (value.hasNullValue()) {
      return null;
    } else if (value.hasBoolValue()) {
      return value.boolValue;
    } else if (value.hasNumberValue()) {
      return value.numberValue;
    } else if (value.hasStringValue()) {
      return value.stringValue;
    } else if (value.hasListValue()) {
      return value.listValue.values.map(_convertValue).toList();
    } else if (value.hasStructValue()) {
      return _convertStruct(value.structValue);
    } else {
      throw ArgumentError('Unknown value type in protobuf Value');
    }
  }
}
