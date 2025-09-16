// This is a generated file - do not edit.
//
// Generated from local_agents/function_calling/core/proto/constraint_options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Only allow tool calls in the response.
///
/// With the config below
///   constraint_prefix: "```TOOL_CALL\n"
///   constraint_suffix: "\n```"
///
/// Example allowed response:
///   1. "```TOOL_CALL
///      function_call()
///      ```"
///
/// Example disallowed response:
///   1. "A normal text"
///
///   2. "function_call()"
///
///   3. "```TOOL_CALL
///      wrong_function_name()
///      ```"
class ConstraintOptions_ToolCallOnly extends $pb.GeneratedMessage {
  factory ConstraintOptions_ToolCallOnly({
    $core.String? constraintSuffix,
    $core.String? constraintPrefix,
  }) {
    final result = create();
    if (constraintSuffix != null) result.constraintSuffix = constraintSuffix;
    if (constraintPrefix != null) result.constraintPrefix = constraintPrefix;
    return result;
  }

  ConstraintOptions_ToolCallOnly._();

  factory ConstraintOptions_ToolCallOnly.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConstraintOptions_ToolCallOnly.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConstraintOptions.ToolCallOnly',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'odml.generativeai'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'constraintSuffix')
    ..aOS(2, _omitFieldNames ? '' : 'constraintPrefix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_ToolCallOnly clone() =>
      ConstraintOptions_ToolCallOnly()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_ToolCallOnly copyWith(
          void Function(ConstraintOptions_ToolCallOnly) updates) =>
      super.copyWith(
              (message) => updates(message as ConstraintOptions_ToolCallOnly))
          as ConstraintOptions_ToolCallOnly;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_ToolCallOnly create() =>
      ConstraintOptions_ToolCallOnly._();
  @$core.override
  ConstraintOptions_ToolCallOnly createEmptyInstance() => create();
  static $pb.PbList<ConstraintOptions_ToolCallOnly> createRepeated() =>
      $pb.PbList<ConstraintOptions_ToolCallOnly>();
  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_ToolCallOnly getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConstraintOptions_ToolCallOnly>(create);
  static ConstraintOptions_ToolCallOnly? _defaultInstance;

  /// Suffix of the function call constraint.
  @$pb.TagNumber(1)
  $core.String get constraintSuffix => $_getSZ(0);
  @$pb.TagNumber(1)
  set constraintSuffix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConstraintSuffix() => $_has(0);
  @$pb.TagNumber(1)
  void clearConstraintSuffix() => $_clearField(1);

  /// Prefix of the function call constraint.
  @$pb.TagNumber(2)
  $core.String get constraintPrefix => $_getSZ(1);
  @$pb.TagNumber(2)
  set constraintPrefix($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConstraintPrefix() => $_has(1);
  @$pb.TagNumber(2)
  void clearConstraintPrefix() => $_clearField(2);
}

/// Allow text only, tool calls only, or both in the response. Tool call only
/// after the stop phrase.
///
/// With the config below
///   stop_phrase_prefix: "\n"
///   stop_phrase_suffix: "```TOOL_CALL\n"
///   constraint_suffix: "\n```"
///
/// Example allowed response:
///   1. "A normal text"
///
///   2. "```TOOL_CALL
///      function_call()
///      ```"
///
///   3. "Some text before tool call
///      ```TOOL_CALL
///      function_call()
///      ```"
///
/// Example disallowed response:
///   1. "```TOOL_CALL
///      function_call()
///      ```
///      extra text"
///
///   2. "```TOOL_CALL
///      wrong_function_name()
///      ```"
///
///   3. "missed constraint suffix
///      ```TOOL_CALL
///      function_call()"
class ConstraintOptions_TextAndOr extends $pb.GeneratedMessage {
  factory ConstraintOptions_TextAndOr({
    $core.String? stopPhrasePrefix,
    $core.String? stopPhraseSuffix,
    $core.String? constraintSuffix,
  }) {
    final result = create();
    if (stopPhrasePrefix != null) result.stopPhrasePrefix = stopPhrasePrefix;
    if (stopPhraseSuffix != null) result.stopPhraseSuffix = stopPhraseSuffix;
    if (constraintSuffix != null) result.constraintSuffix = constraintSuffix;
    return result;
  }

  ConstraintOptions_TextAndOr._();

  factory ConstraintOptions_TextAndOr.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConstraintOptions_TextAndOr.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConstraintOptions.TextAndOr',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'odml.generativeai'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stopPhrasePrefix')
    ..aOS(2, _omitFieldNames ? '' : 'stopPhraseSuffix')
    ..aOS(3, _omitFieldNames ? '' : 'constraintSuffix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_TextAndOr clone() =>
      ConstraintOptions_TextAndOr()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_TextAndOr copyWith(
          void Function(ConstraintOptions_TextAndOr) updates) =>
      super.copyWith(
              (message) => updates(message as ConstraintOptions_TextAndOr))
          as ConstraintOptions_TextAndOr;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_TextAndOr create() =>
      ConstraintOptions_TextAndOr._();
  @$core.override
  ConstraintOptions_TextAndOr createEmptyInstance() => create();
  static $pb.PbList<ConstraintOptions_TextAndOr> createRepeated() =>
      $pb.PbList<ConstraintOptions_TextAndOr>();
  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_TextAndOr getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConstraintOptions_TextAndOr>(create);
  static ConstraintOptions_TextAndOr? _defaultInstance;

  /// Prefix of the stop phrase. Could be empty.
  @$pb.TagNumber(1)
  $core.String get stopPhrasePrefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set stopPhrasePrefix($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStopPhrasePrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearStopPhrasePrefix() => $_clearField(1);

  /// Suffix of the stop phrase. Once the stop_phrase_prefix +
  /// stop_phrase_suffix is matched, the function call constraint applies.
  @$pb.TagNumber(2)
  $core.String get stopPhraseSuffix => $_getSZ(1);
  @$pb.TagNumber(2)
  set stopPhraseSuffix($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStopPhraseSuffix() => $_has(1);
  @$pb.TagNumber(2)
  void clearStopPhraseSuffix() => $_clearField(2);

  /// Suffix of the function call constraint.
  @$pb.TagNumber(3)
  $core.String get constraintSuffix => $_getSZ(2);
  @$pb.TagNumber(3)
  set constraintSuffix($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConstraintSuffix() => $_has(2);
  @$pb.TagNumber(3)
  void clearConstraintSuffix() => $_clearField(3);
}

/// Allow tool calls only, or text before tool calls. And tool call only after
/// stop phrase.
///
/// With the config below
///   stop_phrase: "\n```TOOL_CALL\n"
///   constraint_suffix: "\n```"
///
/// Example allowed response:
///
///   1. "
///      ```TOOL_CALL
///      function_call()
///      ```"
///
///   2. "Some text before tool call
///      ```TOOL_CALL
///      function_call()
///      ```"
///
/// Example disallowed response:
///   1. "A normal text"
///
///   2. "
///      ```TOOL_CALL
///      wrong_function_name()
///      ```"
///
///   3. "missed constraint suffix
///      ```TOOL_CALL
///      function_call()"
class ConstraintOptions_TextUntil extends $pb.GeneratedMessage {
  factory ConstraintOptions_TextUntil({
    $core.String? stopPhrase,
    $core.String? constraintSuffix,
  }) {
    final result = create();
    if (stopPhrase != null) result.stopPhrase = stopPhrase;
    if (constraintSuffix != null) result.constraintSuffix = constraintSuffix;
    return result;
  }

  ConstraintOptions_TextUntil._();

  factory ConstraintOptions_TextUntil.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConstraintOptions_TextUntil.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConstraintOptions.TextUntil',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'odml.generativeai'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stopPhrase')
    ..aOS(2, _omitFieldNames ? '' : 'constraintSuffix')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_TextUntil clone() =>
      ConstraintOptions_TextUntil()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions_TextUntil copyWith(
          void Function(ConstraintOptions_TextUntil) updates) =>
      super.copyWith(
              (message) => updates(message as ConstraintOptions_TextUntil))
          as ConstraintOptions_TextUntil;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_TextUntil create() =>
      ConstraintOptions_TextUntil._();
  @$core.override
  ConstraintOptions_TextUntil createEmptyInstance() => create();
  static $pb.PbList<ConstraintOptions_TextUntil> createRepeated() =>
      $pb.PbList<ConstraintOptions_TextUntil>();
  @$core.pragma('dart2js:noInline')
  static ConstraintOptions_TextUntil getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConstraintOptions_TextUntil>(create);
  static ConstraintOptions_TextUntil? _defaultInstance;

  /// Stop phrase. Once the stop_phrase is matched, the function call
  /// constraint applies.
  @$pb.TagNumber(1)
  $core.String get stopPhrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set stopPhrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStopPhrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearStopPhrase() => $_clearField(1);

  /// Suffix of the function call constraint.
  @$pb.TagNumber(2)
  $core.String get constraintSuffix => $_getSZ(1);
  @$pb.TagNumber(2)
  set constraintSuffix($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConstraintSuffix() => $_has(1);
  @$pb.TagNumber(2)
  void clearConstraintSuffix() => $_clearField(2);
}

enum ConstraintOptions_ResponseType {
  toolCallOnly,
  textAndOr,
  textUntil,
  notSet
}

/// Options for building a constraint regex.
class ConstraintOptions extends $pb.GeneratedMessage {
  factory ConstraintOptions({
    ConstraintOptions_ToolCallOnly? toolCallOnly,
    ConstraintOptions_TextAndOr? textAndOr,
    ConstraintOptions_TextUntil? textUntil,
  }) {
    final result = create();
    if (toolCallOnly != null) result.toolCallOnly = toolCallOnly;
    if (textAndOr != null) result.textAndOr = textAndOr;
    if (textUntil != null) result.textUntil = textUntil;
    return result;
  }

  ConstraintOptions._();

  factory ConstraintOptions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConstraintOptions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ConstraintOptions_ResponseType>
      _ConstraintOptions_ResponseTypeByTag = {
    1: ConstraintOptions_ResponseType.toolCallOnly,
    2: ConstraintOptions_ResponseType.textAndOr,
    3: ConstraintOptions_ResponseType.textUntil,
    0: ConstraintOptions_ResponseType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConstraintOptions',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'odml.generativeai'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<ConstraintOptions_ToolCallOnly>(
        1, _omitFieldNames ? '' : 'toolCallOnly',
        subBuilder: ConstraintOptions_ToolCallOnly.create)
    ..aOM<ConstraintOptions_TextAndOr>(2, _omitFieldNames ? '' : 'textAndOr',
        subBuilder: ConstraintOptions_TextAndOr.create)
    ..aOM<ConstraintOptions_TextUntil>(3, _omitFieldNames ? '' : 'textUntil',
        subBuilder: ConstraintOptions_TextUntil.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions clone() => ConstraintOptions()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConstraintOptions copyWith(void Function(ConstraintOptions) updates) =>
      super.copyWith((message) => updates(message as ConstraintOptions))
          as ConstraintOptions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConstraintOptions create() => ConstraintOptions._();
  @$core.override
  ConstraintOptions createEmptyInstance() => create();
  static $pb.PbList<ConstraintOptions> createRepeated() =>
      $pb.PbList<ConstraintOptions>();
  @$core.pragma('dart2js:noInline')
  static ConstraintOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConstraintOptions>(create);
  static ConstraintOptions? _defaultInstance;

  ConstraintOptions_ResponseType whichResponseType() =>
      _ConstraintOptions_ResponseTypeByTag[$_whichOneof(0)]!;
  void clearResponseType() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ConstraintOptions_ToolCallOnly get toolCallOnly => $_getN(0);
  @$pb.TagNumber(1)
  set toolCallOnly(ConstraintOptions_ToolCallOnly value) =>
      $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasToolCallOnly() => $_has(0);
  @$pb.TagNumber(1)
  void clearToolCallOnly() => $_clearField(1);
  @$pb.TagNumber(1)
  ConstraintOptions_ToolCallOnly ensureToolCallOnly() => $_ensure(0);

  @$pb.TagNumber(2)
  ConstraintOptions_TextAndOr get textAndOr => $_getN(1);
  @$pb.TagNumber(2)
  set textAndOr(ConstraintOptions_TextAndOr value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTextAndOr() => $_has(1);
  @$pb.TagNumber(2)
  void clearTextAndOr() => $_clearField(2);
  @$pb.TagNumber(2)
  ConstraintOptions_TextAndOr ensureTextAndOr() => $_ensure(1);

  @$pb.TagNumber(3)
  ConstraintOptions_TextUntil get textUntil => $_getN(2);
  @$pb.TagNumber(3)
  set textUntil(ConstraintOptions_TextUntil value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTextUntil() => $_has(2);
  @$pb.TagNumber(3)
  void clearTextUntil() => $_clearField(3);
  @$pb.TagNumber(3)
  ConstraintOptions_TextUntil ensureTextUntil() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
