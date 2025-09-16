// This is a generated file - do not edit.
//
// Generated from local_agents/function_calling/core/proto/constraint_options.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use constraintOptionsDescriptor instead')
const ConstraintOptions$json = {
  '1': 'ConstraintOptions',
  '2': [
    {
      '1': 'tool_call_only',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.odml.generativeai.ConstraintOptions.ToolCallOnly',
      '9': 0,
      '10': 'toolCallOnly'
    },
    {
      '1': 'text_and_or',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.odml.generativeai.ConstraintOptions.TextAndOr',
      '9': 0,
      '10': 'textAndOr'
    },
    {
      '1': 'text_until',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.odml.generativeai.ConstraintOptions.TextUntil',
      '9': 0,
      '10': 'textUntil'
    },
  ],
  '3': [
    ConstraintOptions_ToolCallOnly$json,
    ConstraintOptions_TextAndOr$json,
    ConstraintOptions_TextUntil$json
  ],
  '8': [
    {'1': 'response_type'},
  ],
};

@$core.Deprecated('Use constraintOptionsDescriptor instead')
const ConstraintOptions_ToolCallOnly$json = {
  '1': 'ToolCallOnly',
  '2': [
    {
      '1': 'constraint_suffix',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'constraintSuffix'
    },
    {
      '1': 'constraint_prefix',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'constraintPrefix'
    },
  ],
};

@$core.Deprecated('Use constraintOptionsDescriptor instead')
const ConstraintOptions_TextAndOr$json = {
  '1': 'TextAndOr',
  '2': [
    {
      '1': 'stop_phrase_prefix',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'stopPhrasePrefix'
    },
    {
      '1': 'stop_phrase_suffix',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'stopPhraseSuffix'
    },
    {
      '1': 'constraint_suffix',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'constraintSuffix'
    },
  ],
};

@$core.Deprecated('Use constraintOptionsDescriptor instead')
const ConstraintOptions_TextUntil$json = {
  '1': 'TextUntil',
  '2': [
    {'1': 'stop_phrase', '3': 1, '4': 1, '5': 9, '10': 'stopPhrase'},
    {
      '1': 'constraint_suffix',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'constraintSuffix'
    },
  ],
};

/// Descriptor for `ConstraintOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List constraintOptionsDescriptor = $convert.base64Decode(
    'ChFDb25zdHJhaW50T3B0aW9ucxJZCg50b29sX2NhbGxfb25seRgBIAEoCzIxLm9kbWwuZ2VuZX'
    'JhdGl2ZWFpLkNvbnN0cmFpbnRPcHRpb25zLlRvb2xDYWxsT25seUgAUgx0b29sQ2FsbE9ubHkS'
    'UAoLdGV4dF9hbmRfb3IYAiABKAsyLi5vZG1sLmdlbmVyYXRpdmVhaS5Db25zdHJhaW50T3B0aW'
    '9ucy5UZXh0QW5kT3JIAFIJdGV4dEFuZE9yEk8KCnRleHRfdW50aWwYAyABKAsyLi5vZG1sLmdl'
    'bmVyYXRpdmVhaS5Db25zdHJhaW50T3B0aW9ucy5UZXh0VW50aWxIAFIJdGV4dFVudGlsGmgKDF'
    'Rvb2xDYWxsT25seRIrChFjb25zdHJhaW50X3N1ZmZpeBgBIAEoCVIQY29uc3RyYWludFN1ZmZp'
    'eBIrChFjb25zdHJhaW50X3ByZWZpeBgCIAEoCVIQY29uc3RyYWludFByZWZpeBqUAQoJVGV4dE'
    'FuZE9yEiwKEnN0b3BfcGhyYXNlX3ByZWZpeBgBIAEoCVIQc3RvcFBocmFzZVByZWZpeBIsChJz'
    'dG9wX3BocmFzZV9zdWZmaXgYAiABKAlSEHN0b3BQaHJhc2VTdWZmaXgSKwoRY29uc3RyYWludF'
    '9zdWZmaXgYAyABKAlSEGNvbnN0cmFpbnRTdWZmaXgaWQoJVGV4dFVudGlsEh8KC3N0b3BfcGhy'
    'YXNlGAEgASgJUgpzdG9wUGhyYXNlEisKEWNvbnN0cmFpbnRfc3VmZml4GAIgASgJUhBjb25zdH'
    'JhaW50U3VmZml4Qg8KDXJlc3BvbnNlX3R5cGU=');
