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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/struct.pb.dart' as $0;
import 'content.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'content.pbenum.dart';

/// The base structured datatype containing multi-part content of a message.
///
/// A `Content` includes a `role` field designating the producer of the `Content`
/// and a `parts` field containing multi-part data that contains the content of
/// the message turn.
class Content extends $pb.GeneratedMessage {
  factory Content({
    $core.Iterable<Part>? parts,
    $core.String? role,
  }) {
    final result = create();
    if (parts != null) result.parts.addAll(parts);
    if (role != null) result.role = role;
    return result;
  }

  Content._();

  factory Content.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Content.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Content',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..pc<Part>(1, _omitFieldNames ? '' : 'parts', $pb.PbFieldType.PM,
        subBuilder: Part.create)
    ..aOS(2, _omitFieldNames ? '' : 'role')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content clone() => Content()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Content copyWith(void Function(Content) updates) =>
      super.copyWith((message) => updates(message as Content)) as Content;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Content create() => Content._();
  @$core.override
  Content createEmptyInstance() => create();
  static $pb.PbList<Content> createRepeated() => $pb.PbList<Content>();
  @$core.pragma('dart2js:noInline')
  static Content getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Content>(create);
  static Content? _defaultInstance;

  /// Ordered `Parts` that constitute a single message. Parts may have different
  /// MIME types.
  @$pb.TagNumber(1)
  $pb.PbList<Part> get parts => $_getList(0);

  /// The producer of the content. Must be either 'user' or 'model'.
  ///
  /// Useful to set for multi-turn conversations, otherwise can be left blank
  /// or unset.
  @$pb.TagNumber(2)
  $core.String get role => $_getSZ(1);
  @$pb.TagNumber(2)
  set role($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearRole() => $_clearField(2);
}

enum Part_Data { text, functionCall, functionResponse, notSet }

/// A datatype containing media that is part of a multi-part `Content` message.
///
/// A `Part` consists of data which has an associated datatype. A `Part` can only
/// contain one of the accepted types in `Part.data`.
///
/// A `Part` must have a fixed IANA MIME type identifying the type and subtype
/// of the media if the `inline_data` field is filled with raw bytes.
class Part extends $pb.GeneratedMessage {
  factory Part({
    $core.String? text,
    FunctionCall? functionCall,
    FunctionResponse? functionResponse,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (functionCall != null) result.functionCall = functionCall;
    if (functionResponse != null) result.functionResponse = functionResponse;
    return result;
  }

  Part._();

  factory Part.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Part.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Part_Data> _Part_DataByTag = {
    2: Part_Data.text,
    4: Part_Data.functionCall,
    5: Part_Data.functionResponse,
    0: Part_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Part',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..oo(0, [2, 4, 5])
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOM<FunctionCall>(4, _omitFieldNames ? '' : 'functionCall',
        subBuilder: FunctionCall.create)
    ..aOM<FunctionResponse>(5, _omitFieldNames ? '' : 'functionResponse',
        subBuilder: FunctionResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Part clone() => Part()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Part copyWith(void Function(Part) updates) =>
      super.copyWith((message) => updates(message as Part)) as Part;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Part create() => Part._();
  @$core.override
  Part createEmptyInstance() => create();
  static $pb.PbList<Part> createRepeated() => $pb.PbList<Part>();
  @$core.pragma('dart2js:noInline')
  static Part getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Part>(create);
  static Part? _defaultInstance;

  Part_Data whichData() => _Part_DataByTag[$_whichOneof(0)]!;
  void clearData() => $_clearField($_whichOneof(0));

  /// Inline text.
  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  /// A predicted `FunctionCall` returned from the model that contains
  /// a string representing the `FunctionDeclaration.name` with the
  /// arguments and their values.
  @$pb.TagNumber(4)
  FunctionCall get functionCall => $_getN(1);
  @$pb.TagNumber(4)
  set functionCall(FunctionCall value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFunctionCall() => $_has(1);
  @$pb.TagNumber(4)
  void clearFunctionCall() => $_clearField(4);
  @$pb.TagNumber(4)
  FunctionCall ensureFunctionCall() => $_ensure(1);

  /// The result output of a `FunctionCall` that contains a string
  /// representing the `FunctionDeclaration.name` and a structured JSON
  /// object containing any output from the function is used as context to
  /// the model.
  @$pb.TagNumber(5)
  FunctionResponse get functionResponse => $_getN(2);
  @$pb.TagNumber(5)
  set functionResponse(FunctionResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFunctionResponse() => $_has(2);
  @$pb.TagNumber(5)
  void clearFunctionResponse() => $_clearField(5);
  @$pb.TagNumber(5)
  FunctionResponse ensureFunctionResponse() => $_ensure(2);
}

/// Tool details that the model may use to generate response.
///
/// A `Tool` is a piece of code that enables the system to interact with
/// external systems to perform an action, or set of actions, outside of
/// knowledge and scope of the model.
class Tool extends $pb.GeneratedMessage {
  factory Tool({
    $core.Iterable<FunctionDeclaration>? functionDeclarations,
  }) {
    final result = create();
    if (functionDeclarations != null)
      result.functionDeclarations.addAll(functionDeclarations);
    return result;
  }

  Tool._();

  factory Tool.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tool.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tool',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..pc<FunctionDeclaration>(
        1, _omitFieldNames ? '' : 'functionDeclarations', $pb.PbFieldType.PM,
        subBuilder: FunctionDeclaration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tool clone() => Tool()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tool copyWith(void Function(Tool) updates) =>
      super.copyWith((message) => updates(message as Tool)) as Tool;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tool create() => Tool._();
  @$core.override
  Tool createEmptyInstance() => create();
  static $pb.PbList<Tool> createRepeated() => $pb.PbList<Tool>();
  @$core.pragma('dart2js:noInline')
  static Tool getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tool>(create);
  static Tool? _defaultInstance;

  /// A list of `FunctionDeclarations` available to the model that can be used
  /// for function calling.
  ///
  /// The model or system does not execute the function. Instead the defined
  /// function may be returned as a [FunctionCall][Part.function_call]
  /// with arguments to the client side for execution. The model may decide to
  /// call a subset of these functions by populating
  /// [FunctionCall][Part.function_call] in the response. The next
  /// conversation turn may contain a
  /// [FunctionResponse][Part.function_response]
  /// with the [Content.role][] "function" generation context for the next model
  /// turn.
  @$pb.TagNumber(1)
  $pb.PbList<FunctionDeclaration> get functionDeclarations => $_getList(0);
}

/// Structured representation of a function declaration as defined by the
/// [OpenAPI 3.03 specification](https://spec.openapis.org/oas/v3.0.3). Included
/// in this declaration are the function name and parameters. This
/// FunctionDeclaration is a representation of a block of code that can be used
/// as a `Tool` by the model and executed by the client.
class FunctionDeclaration extends $pb.GeneratedMessage {
  factory FunctionDeclaration({
    $core.String? name,
    $core.String? description,
    Schema? parameters,
    Schema? response,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (parameters != null) result.parameters = parameters;
    if (response != null) result.response = response;
    return result;
  }

  FunctionDeclaration._();

  factory FunctionDeclaration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FunctionDeclaration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FunctionDeclaration',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<Schema>(3, _omitFieldNames ? '' : 'parameters',
        subBuilder: Schema.create)
    ..aOM<Schema>(4, _omitFieldNames ? '' : 'response',
        subBuilder: Schema.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionDeclaration clone() => FunctionDeclaration()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionDeclaration copyWith(void Function(FunctionDeclaration) updates) =>
      super.copyWith((message) => updates(message as FunctionDeclaration))
          as FunctionDeclaration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FunctionDeclaration create() => FunctionDeclaration._();
  @$core.override
  FunctionDeclaration createEmptyInstance() => create();
  static $pb.PbList<FunctionDeclaration> createRepeated() =>
      $pb.PbList<FunctionDeclaration>();
  @$core.pragma('dart2js:noInline')
  static FunctionDeclaration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FunctionDeclaration>(create);
  static FunctionDeclaration? _defaultInstance;

  /// The name of the function.
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// A brief description of the function.
  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  /// Describes the parameters to this function. Reflects the Open API 3.03
  /// Parameter Object string Key: the name of the parameter. Parameter names are
  /// case sensitive. Schema Value: the Schema defining the type used for the
  /// parameter.
  @$pb.TagNumber(3)
  Schema get parameters => $_getN(2);
  @$pb.TagNumber(3)
  set parameters(Schema value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasParameters() => $_has(2);
  @$pb.TagNumber(3)
  void clearParameters() => $_clearField(3);
  @$pb.TagNumber(3)
  Schema ensureParameters() => $_ensure(2);

  /// Describes the output from this function in JSON Schema format. Reflects the
  /// Open API 3.03 Response Object. The Schema defines the type used for the
  /// response value of the function.
  @$pb.TagNumber(4)
  Schema get response => $_getN(3);
  @$pb.TagNumber(4)
  set response(Schema value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasResponse() => $_has(3);
  @$pb.TagNumber(4)
  void clearResponse() => $_clearField(4);
  @$pb.TagNumber(4)
  Schema ensureResponse() => $_ensure(3);
}

/// A predicted `FunctionCall` returned from the model that contains
/// a string representing the `FunctionDeclaration.name` with the
/// arguments and their values.
class FunctionCall extends $pb.GeneratedMessage {
  factory FunctionCall({
    $core.String? name,
    $0.Struct? args,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (args != null) result.args = args;
    return result;
  }

  FunctionCall._();

  factory FunctionCall.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FunctionCall.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FunctionCall',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'args',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionCall clone() => FunctionCall()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionCall copyWith(void Function(FunctionCall) updates) =>
      super.copyWith((message) => updates(message as FunctionCall))
          as FunctionCall;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FunctionCall create() => FunctionCall._();
  @$core.override
  FunctionCall createEmptyInstance() => create();
  static $pb.PbList<FunctionCall> createRepeated() =>
      $pb.PbList<FunctionCall>();
  @$core.pragma('dart2js:noInline')
  static FunctionCall getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FunctionCall>(create);
  static FunctionCall? _defaultInstance;

  /// The name of the function to call.
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// The function parameters and values in JSON object format.
  @$pb.TagNumber(2)
  $0.Struct get args => $_getN(1);
  @$pb.TagNumber(2)
  set args($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasArgs() => $_has(1);
  @$pb.TagNumber(2)
  void clearArgs() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureArgs() => $_ensure(1);
}

/// The result output from a `FunctionCall` that contains a string
/// representing the `FunctionDeclaration.name` and a structured JSON
/// object containing any output from the function is used as context to
/// the model. This should contain the result of a`FunctionCall` made
/// based on model prediction.
class FunctionResponse extends $pb.GeneratedMessage {
  factory FunctionResponse({
    $core.String? name,
    $0.Struct? response,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (response != null) result.response = response;
    return result;
  }

  FunctionResponse._();

  factory FunctionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FunctionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FunctionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'response',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionResponse clone() => FunctionResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FunctionResponse copyWith(void Function(FunctionResponse) updates) =>
      super.copyWith((message) => updates(message as FunctionResponse))
          as FunctionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FunctionResponse create() => FunctionResponse._();
  @$core.override
  FunctionResponse createEmptyInstance() => create();
  static $pb.PbList<FunctionResponse> createRepeated() =>
      $pb.PbList<FunctionResponse>();
  @$core.pragma('dart2js:noInline')
  static FunctionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FunctionResponse>(create);
  static FunctionResponse? _defaultInstance;

  /// The name of the function to call.
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// The function response in JSON object format.
  @$pb.TagNumber(2)
  $0.Struct get response => $_getN(1);
  @$pb.TagNumber(2)
  set response($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasResponse() => $_has(1);
  @$pb.TagNumber(2)
  void clearResponse() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureResponse() => $_ensure(1);
}

/// (-- Next ID: 25 --)
/// The `Schema` object allows the definition of input and output data types.
/// These types can be objects, but also primitives and arrays.
/// Represents a select subset of an [OpenAPI 3.0 schema
/// object](https://spec.openapis.org/oas/v3.0.3#schema).
class Schema extends $pb.GeneratedMessage {
  factory Schema({
    Type? type,
    $core.String? format,
    $core.String? description,
    $core.bool? nullable,
    $core.Iterable<$core.String>? enum_5,
    Schema? items,
    $core.Iterable<$core.MapEntry<$core.String, Schema>>? properties,
    $core.Iterable<$core.String>? required,
    $core.double? minimum,
    $core.double? maximum,
    $core.Iterable<Schema>? anyOf,
    $fixnum.Int64? maxItems,
    $fixnum.Int64? minItems,
    $core.Iterable<$core.String>? propertyOrdering,
    $core.String? title,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (format != null) result.format = format;
    if (description != null) result.description = description;
    if (nullable != null) result.nullable = nullable;
    if (enum_5 != null) result.enum_5.addAll(enum_5);
    if (items != null) result.items = items;
    if (properties != null) result.properties.addEntries(properties);
    if (required != null) result.required.addAll(required);
    if (minimum != null) result.minimum = minimum;
    if (maximum != null) result.maximum = maximum;
    if (anyOf != null) result.anyOf.addAll(anyOf);
    if (maxItems != null) result.maxItems = maxItems;
    if (minItems != null) result.minItems = minItems;
    if (propertyOrdering != null)
      result.propertyOrdering.addAll(propertyOrdering);
    if (title != null) result.title = title;
    return result;
  }

  Schema._();

  factory Schema.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Schema.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Schema',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..e<Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: Type.TYPE_UNSPECIFIED,
        valueOf: Type.valueOf,
        enumValues: Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'format')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOB(4, _omitFieldNames ? '' : 'nullable')
    ..pPS(5, _omitFieldNames ? '' : 'enum')
    ..aOM<Schema>(6, _omitFieldNames ? '' : 'items', subBuilder: Schema.create)
    ..m<$core.String, Schema>(7, _omitFieldNames ? '' : 'properties',
        entryClassName: 'Schema.PropertiesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Schema.create,
        valueDefaultOrMaker: Schema.getDefault,
        packageName: const $pb.PackageName('odml.genai_modules.core.proto'))
    ..pPS(8, _omitFieldNames ? '' : 'required')
    ..a<$core.double>(11, _omitFieldNames ? '' : 'minimum', $pb.PbFieldType.OD)
    ..a<$core.double>(12, _omitFieldNames ? '' : 'maximum', $pb.PbFieldType.OD)
    ..pc<Schema>(18, _omitFieldNames ? '' : 'anyOf', $pb.PbFieldType.PM,
        subBuilder: Schema.create)
    ..aInt64(21, _omitFieldNames ? '' : 'maxItems')
    ..aInt64(22, _omitFieldNames ? '' : 'minItems')
    ..pPS(23, _omitFieldNames ? '' : 'propertyOrdering')
    ..aOS(24, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Schema clone() => Schema()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Schema copyWith(void Function(Schema) updates) =>
      super.copyWith((message) => updates(message as Schema)) as Schema;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Schema create() => Schema._();
  @$core.override
  Schema createEmptyInstance() => create();
  static $pb.PbList<Schema> createRepeated() => $pb.PbList<Schema>();
  @$core.pragma('dart2js:noInline')
  static Schema getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Schema>(create);
  static Schema? _defaultInstance;

  /// Data type.
  @$pb.TagNumber(1)
  Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  /// The format of the data. This is used only for primitive datatypes.
  /// Supported formats:
  ///  for NUMBER type: float, double
  ///  for INTEGER type: int32, int64
  ///  for STRING type: enum, date-time
  @$pb.TagNumber(2)
  $core.String get format => $_getSZ(1);
  @$pb.TagNumber(2)
  set format($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);

  /// A brief description of the parameter. This could contain examples of use.
  /// Parameter description may be formatted as Markdown.
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// Indicates if the value may be null.
  @$pb.TagNumber(4)
  $core.bool get nullable => $_getBF(3);
  @$pb.TagNumber(4)
  set nullable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNullable() => $_has(3);
  @$pb.TagNumber(4)
  void clearNullable() => $_clearField(4);

  /// Possible values of the element of Type.STRING with enum format.
  /// For example we can define an Enum Direction as :
  /// {type:STRING, format:enum, enum:["EAST", NORTH", "SOUTH", "WEST"]}
  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get enum_5 => $_getList(4);

  /// Schema of the elements of Type.ARRAY.
  @$pb.TagNumber(6)
  Schema get items => $_getN(5);
  @$pb.TagNumber(6)
  set items(Schema value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasItems() => $_has(5);
  @$pb.TagNumber(6)
  void clearItems() => $_clearField(6);
  @$pb.TagNumber(6)
  Schema ensureItems() => $_ensure(5);

  /// Properties of Type.OBJECT.
  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, Schema> get properties => $_getMap(6);

  /// Required properties of Type.OBJECT.
  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get required => $_getList(7);

  /// SCHEMA FIELDS FOR TYPE INTEGER and NUMBER
  /// Minimum value of the Type.INTEGER and Type.NUMBER
  @$pb.TagNumber(11)
  $core.double get minimum => $_getN(8);
  @$pb.TagNumber(11)
  set minimum($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(11)
  $core.bool hasMinimum() => $_has(8);
  @$pb.TagNumber(11)
  void clearMinimum() => $_clearField(11);

  /// Maximum value of the Type.INTEGER and Type.NUMBER
  @$pb.TagNumber(12)
  $core.double get maximum => $_getN(9);
  @$pb.TagNumber(12)
  set maximum($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(12)
  $core.bool hasMaximum() => $_has(9);
  @$pb.TagNumber(12)
  void clearMaximum() => $_clearField(12);

  /// The value should be validated against any (one or more) of the subschemas
  /// in the list.
  @$pb.TagNumber(18)
  $pb.PbList<Schema> get anyOf => $_getList(10);

  /// Maximum number of the elements for Type.ARRAY.
  @$pb.TagNumber(21)
  $fixnum.Int64 get maxItems => $_getI64(11);
  @$pb.TagNumber(21)
  set maxItems($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(21)
  $core.bool hasMaxItems() => $_has(11);
  @$pb.TagNumber(21)
  void clearMaxItems() => $_clearField(21);

  /// Minimum number of the elements for Type.ARRAY.
  @$pb.TagNumber(22)
  $fixnum.Int64 get minItems => $_getI64(12);
  @$pb.TagNumber(22)
  set minItems($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(22)
  $core.bool hasMinItems() => $_has(12);
  @$pb.TagNumber(22)
  void clearMinItems() => $_clearField(22);

  /// The order of the properties.
  /// Not a standard field in open api spec. Used to determine the order of the
  /// properties in the response.
  /// (-- This is necessary as protos do not preserve the order in which the
  /// properties are defined in the request. --)
  @$pb.TagNumber(23)
  $pb.PbList<$core.String> get propertyOrdering => $_getList(13);

  /// The title of the schema.
  @$pb.TagNumber(24)
  $core.String get title => $_getSZ(14);
  @$pb.TagNumber(24)
  set title($core.String value) => $_setString(14, value);
  @$pb.TagNumber(24)
  $core.bool hasTitle() => $_has(14);
  @$pb.TagNumber(24)
  void clearTitle() => $_clearField(24);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
