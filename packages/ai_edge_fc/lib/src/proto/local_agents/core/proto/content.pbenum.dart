// This is a generated file - do not edit.
//
// Generated from local_agents/core/proto/content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Type contains the list of OpenAPI data types as defined by
/// https://spec.openapis.org/oas/v3.0.3#data-types
class Type extends $pb.ProtobufEnum {
  /// Not specified, should not be used.
  static const Type TYPE_UNSPECIFIED =
      Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');

  /// String type.
  static const Type STRING = Type._(1, _omitEnumNames ? '' : 'STRING');

  /// Number type.
  static const Type NUMBER = Type._(2, _omitEnumNames ? '' : 'NUMBER');

  /// Integer type.
  static const Type INTEGER = Type._(3, _omitEnumNames ? '' : 'INTEGER');

  /// Boolean type.
  static const Type BOOLEAN = Type._(4, _omitEnumNames ? '' : 'BOOLEAN');

  /// Array type.
  static const Type ARRAY = Type._(5, _omitEnumNames ? '' : 'ARRAY');

  /// Object type.
  static const Type OBJECT = Type._(6, _omitEnumNames ? '' : 'OBJECT');

  /// Null type.
  /// HACK: We use this to handle optional parameters, which users are specifying
  /// optional things by using a OneOf with a second type of NULL.
  static const Type NULL = Type._(7, _omitEnumNames ? '' : 'NULL');

  static const $core.List<Type> values = <Type>[
    TYPE_UNSPECIFIED,
    STRING,
    NUMBER,
    INTEGER,
    BOOLEAN,
    ARRAY,
    OBJECT,
    NULL,
  ];

  static final $core.List<Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Type._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
