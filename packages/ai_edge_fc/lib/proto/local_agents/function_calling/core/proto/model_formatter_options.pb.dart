// This is a generated file - do not edit.
//
// Generated from local_agents/function_calling/core/proto/model_formatter_options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ModelFormatterOptions extends $pb.GeneratedMessage {
  factory ModelFormatterOptions({
    $core.bool? addPromptTemplate,
    $core.String? agentRole,
  }) {
    final result = create();
    if (addPromptTemplate != null) result.addPromptTemplate = addPromptTemplate;
    if (agentRole != null) result.agentRole = agentRole;
    return result;
  }

  ModelFormatterOptions._();

  factory ModelFormatterOptions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ModelFormatterOptions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ModelFormatterOptions',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'odml.generativeai'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'addPromptTemplate')
    ..aOS(2, _omitFieldNames ? '' : 'agentRole')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModelFormatterOptions clone() =>
      ModelFormatterOptions()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ModelFormatterOptions copyWith(
          void Function(ModelFormatterOptions) updates) =>
      super.copyWith((message) => updates(message as ModelFormatterOptions))
          as ModelFormatterOptions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModelFormatterOptions create() => ModelFormatterOptions._();
  @$core.override
  ModelFormatterOptions createEmptyInstance() => create();
  static $pb.PbList<ModelFormatterOptions> createRepeated() =>
      $pb.PbList<ModelFormatterOptions>();
  @$core.pragma('dart2js:noInline')
  static ModelFormatterOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ModelFormatterOptions>(create);
  static ModelFormatterOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get addPromptTemplate => $_getBF(0);
  @$pb.TagNumber(1)
  set addPromptTemplate($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddPromptTemplate() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddPromptTemplate() => $_clearField(1);

  /// The role of the model agent in the conversation. This is used to start
  /// the model's turn in the prompt.
  /// If not set, the default role is dependent on the model.
  @$pb.TagNumber(2)
  $core.String get agentRole => $_getSZ(1);
  @$pb.TagNumber(2)
  set agentRole($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAgentRole() => $_has(1);
  @$pb.TagNumber(2)
  void clearAgentRole() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
