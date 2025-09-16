// This is a generated file - do not edit.
//
// Generated from local_agents/core/proto/generative_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'content.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Request to generate a completion from the model.
class GenerateContentRequest extends $pb.GeneratedMessage {
  factory GenerateContentRequest({
    $core.String? model,
    $core.Iterable<$0.Content>? contents,
    $core.Iterable<$0.Tool>? tools,
    $0.Content? systemInstruction,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (contents != null) result.contents.addAll(contents);
    if (tools != null) result.tools.addAll(tools);
    if (systemInstruction != null) result.systemInstruction = systemInstruction;
    return result;
  }

  GenerateContentRequest._();

  factory GenerateContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateContentRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'model')
    ..pc<$0.Content>(2, _omitFieldNames ? '' : 'contents', $pb.PbFieldType.PM,
        subBuilder: $0.Content.create)
    ..pc<$0.Tool>(5, _omitFieldNames ? '' : 'tools', $pb.PbFieldType.PM,
        subBuilder: $0.Tool.create)
    ..aOM<$0.Content>(8, _omitFieldNames ? '' : 'systemInstruction',
        subBuilder: $0.Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateContentRequest clone() =>
      GenerateContentRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateContentRequest copyWith(
          void Function(GenerateContentRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateContentRequest))
          as GenerateContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateContentRequest create() => GenerateContentRequest._();
  @$core.override
  GenerateContentRequest createEmptyInstance() => create();
  static $pb.PbList<GenerateContentRequest> createRepeated() =>
      $pb.PbList<GenerateContentRequest>();
  @$core.pragma('dart2js:noInline')
  static GenerateContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateContentRequest>(create);
  static GenerateContentRequest? _defaultInstance;

  /// The name of the `Model` to use for generating the completion.
  ///
  /// Format: `models/{model}`.
  @$pb.TagNumber(1)
  $core.String get model => $_getSZ(0);
  @$pb.TagNumber(1)
  set model($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  /// The content of the current conversation with the model.
  ///
  /// For single-turn queries, this is a single instance. For multi-turn queries
  /// like [chat](https://ai.google.dev/gemini-api/docs/text-generation#chat),
  /// this is a repeated field that contains the conversation history and the
  /// latest request.
  @$pb.TagNumber(2)
  $pb.PbList<$0.Content> get contents => $_getList(1);

  /// A list of `Tools` the `Model` may use to generate the next response.
  ///
  /// A `Tool` is a piece of code that enables the system to interact with
  /// external systems to perform an action, or set of actions, outside of
  /// knowledge and scope of the `Model`. Supported `Tool`s are `Function` and
  /// `code_execution`. Refer to the [Function
  /// calling](https://ai.google.dev/gemini-api/docs/function-calling) and the
  /// [Code execution](https://ai.google.dev/gemini-api/docs/code-execution)
  /// guides to learn more.
  @$pb.TagNumber(5)
  $pb.PbList<$0.Tool> get tools => $_getList(2);

  /// Developer set [system
  /// instruction(s)](https://ai.google.dev/gemini-api/docs/system-instructions).
  /// Currently, text only.
  @$pb.TagNumber(8)
  $0.Content get systemInstruction => $_getN(3);
  @$pb.TagNumber(8)
  set systemInstruction($0.Content value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasSystemInstruction() => $_has(3);
  @$pb.TagNumber(8)
  void clearSystemInstruction() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Content ensureSystemInstruction() => $_ensure(3);
}

/// Response from the model supporting multiple candidate responses.
///
/// Safety ratings and content filtering are reported for both
/// prompt in `GenerateContentResponse.prompt_feedback` and for each candidate
/// in `finish_reason` and in `safety_ratings`. The API:
///  - Returns either all requested candidates or none of them
///  - Returns no candidates at all only if there was something wrong with the
///    prompt (check `prompt_feedback`)
///  - Reports feedback on each candidate in `finish_reason` and
///    `safety_ratings`.
class GenerateContentResponse extends $pb.GeneratedMessage {
  factory GenerateContentResponse({
    $core.Iterable<Candidate>? candidates,
  }) {
    final result = create();
    if (candidates != null) result.candidates.addAll(candidates);
    return result;
  }

  GenerateContentResponse._();

  factory GenerateContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateContentResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..pc<Candidate>(1, _omitFieldNames ? '' : 'candidates', $pb.PbFieldType.PM,
        subBuilder: Candidate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateContentResponse clone() =>
      GenerateContentResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateContentResponse copyWith(
          void Function(GenerateContentResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateContentResponse))
          as GenerateContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateContentResponse create() => GenerateContentResponse._();
  @$core.override
  GenerateContentResponse createEmptyInstance() => create();
  static $pb.PbList<GenerateContentResponse> createRepeated() =>
      $pb.PbList<GenerateContentResponse>();
  @$core.pragma('dart2js:noInline')
  static GenerateContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateContentResponse>(create);
  static GenerateContentResponse? _defaultInstance;

  /// Candidate responses from the model.
  @$pb.TagNumber(1)
  $pb.PbList<Candidate> get candidates => $_getList(0);
}

/// A response candidate generated from the model.
class Candidate extends $pb.GeneratedMessage {
  factory Candidate({
    $0.Content? content,
  }) {
    final result = create();
    if (content != null) result.content = content;
    return result;
  }

  Candidate._();

  factory Candidate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Candidate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Candidate',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'odml.genai_modules.core.proto'),
      createEmptyInstance: create)
    ..aOM<$0.Content>(1, _omitFieldNames ? '' : 'content',
        subBuilder: $0.Content.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Candidate clone() => Candidate()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Candidate copyWith(void Function(Candidate) updates) =>
      super.copyWith((message) => updates(message as Candidate)) as Candidate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Candidate create() => Candidate._();
  @$core.override
  Candidate createEmptyInstance() => create();
  static $pb.PbList<Candidate> createRepeated() => $pb.PbList<Candidate>();
  @$core.pragma('dart2js:noInline')
  static Candidate getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Candidate>(create);
  static Candidate? _defaultInstance;

  /// Generated content returned from the model.
  @$pb.TagNumber(1)
  $0.Content get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($0.Content value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Content ensureContent() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
